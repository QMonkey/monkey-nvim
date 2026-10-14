local M = {}

-- Tags: gutentags (ctags) + gtags/gtags-cscope + branch-aware rebuild + ctags navigation (gd/g])
M.spec = {
  {
    -- Plain globals instead of a spec `init`: zpack runs init hooks during
    -- setup(), but gutentags lazy-loads on the first BufReadPre/BufNewFile,
    -- so the globals set in M.config below are in place by load time.
    src = 'https://github.com/ludovicchabant/vim-gutentags',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  {
    src = 'https://github.com/dhananjaylatkar/cscope_maps.nvim',
    cmd = { 'Cscope', 'Cs', 'Cstag', 'CsPrompt' },
    config = function()
      require("cscope_maps").setup({
        disable_maps = true,
        cscope = {
          exec = 'gtags-cscope',
          picker = "quickfix",
          project_rooter = { enable = false },
          tag = { keymap = false },
        },
      })
      -- setup() resets vim.g.cscope_maps_db_file, so set it after setup for
      -- the current buffer's project; the GTags BufEnter autocmd keeps it in
      -- sync on project changes.
      local root = require('util').project_root()
      vim.g.cscope_maps_db_file = require('util').gtags_dbpath(root) .. '/GTAGS::' .. root
    end,
  },
}

M.config = function()
  local util = require('util')

  -- gutentags
  vim.g.gutentags_modules = { 'ctags' }
  vim.g.gutentags_project_root = util.root_patterns
  vim.g.gutentags_cache_dir = vim.fn.stdpath('data') .. '/tags/'
  vim.g.gutentags_ctags_tagfile = '.tags'
  vim.g.gutentags_ctags_auto_set_tags = 1
  vim.g.gutentags_ctags_extra_args = {
    '--fields=+liaS',
    '--extras=+q',
    '--langmap=c:.c.h,vim:.vim.vimrc',
    '--c-kinds=+p',
    '--c++-kinds=+p',
    '--python-kinds=+i',
  }
  vim.g.gutentags_generate_on_missing = 1
  vim.g.gutentags_generate_on_new = 0
  vim.g.gutentags_generate_on_write = 1
  vim.g.gutentags_background_update = 1
  vim.g.gutentags_resolve_symlinks = 1
  vim.g.gutentags_define_advanced_commands = 1

  -- cscope_maps.nvim + gtags
  vim.env.GTAGSLABEL = 'native-pygments'

  local candidates = {
    '/etc/gtags.conf',
    '/etc/gtags/gtags.conf',
    '/usr/share/gtags/gtags.conf',
    '/usr/local/etc/gtags.conf',
    '/usr/local/share/gtags/gtags.conf',
    '/home/linuxbrew/.linuxbrew/etc/gtags.conf',
    '/home/linuxbrew/.linuxbrew/share/gtags/gtags.conf',
    '/usr/local/opt/global/share/gtags/gtags.conf',
    '/opt/homebrew/etc/gtags.conf',
    '/opt/homebrew/share/gtags/gtags.conf',
    '/opt/homebrew/opt/global/share/gtags/gtags.conf',
  }
  -- Derive more candidates from the `global` binary's location so custom
  -- install prefixes (HOMEBREW_PREFIX overrides, user-local builds) are covered as well.
  local global_path = vim.fn.exepath('global')
  if global_path ~= '' then
    local prefix = global_path:match('^(.*)/bin/global$')
    if prefix then
      for _, suffix in ipairs({ '/etc/gtags.conf', '/share/gtags/gtags.conf' }) do
        local conf = prefix .. suffix
        if not vim.list_contains(candidates, conf) then
          candidates[#candidates + 1] = conf
        end
      end
    end
  end
  if vim.env.GTAGSCONF and vim.env.GTAGSCONF ~= '' and not vim.list_contains(candidates, vim.env.GTAGSCONF) then
    table.insert(candidates, 1, vim.env.GTAGSCONF)
  end
  local function patch_gtags_conf(conf, content)
    -- gtags's plugin parser measures lines with strlen(), so a NUL byte in
    -- parser output truncates the line and the rest leaks into the next read
    -- ("gtags: unexpected type string"). The stock config maps binary gettext
    -- .mo files to the Modelica lexer, which produces exactly such bytes.
    -- Strip every langmap mapping of .mo so the lexer never sees such files.
    local has_mo = false  -- a langmap maps .mo at all (any line format)
    local changed = false -- at least one mapping was successfully stripped
    local out = {}
    for line in (content .. '\n'):gmatch('([^\n]*)\n') do
      local indent, lang, exts, cont = line:match('^([\t ]*):langmap=([%w-]+)\\:([^:]-):(\\)$')
      if lang and (exts:match('%.mo%.') or exts:match('%.mo$')) then
        has_mo, changed = true, true
        local rest = exts:gsub('%.mo%.', '.', 1):gsub('%.mo$', '', 1)
        if rest ~= '' then
          out[#out + 1] = indent .. ':langmap=' .. lang .. '\\:' .. rest .. ':' .. cont
        end
      else
        -- .mo mapped in an unrecognized format: token-boundary check
        -- (.mo but not .mod/.moo/.monkey); flags the warn path below
        if line:find(':langmap=') and (line:find('%.mo[^%w]') or line:find('%.mo$')) then
          has_mo = true
        end
        out[#out + 1] = line
      end
    end
    if not has_mo or not changed then
      if has_mo then
        vim.notify('gtags.conf: could not strip the .mo langmap from ' .. conf, vim.log.levels.WARN)
      end
      return conf
    end
    local patched = vim.fn.stdpath('data') .. '/gtags.conf'
    local f = io.open(patched, 'w')
    if not f then
      return conf
    end
    f:write(table.concat(out, '\n'))
    f:close()
    return patched
  end

  for _, conf in ipairs(candidates) do
    local f = io.open(conf, 'r')
    if f then
      local content = f:read('*a')
      f:close()
      if content:find('native%-pygments:') then
        vim.env.GTAGSCONF = patch_gtags_conf(conf, content)
        break
      end
    end
  end

  -- Resolve the project root per buffer so files from other projects get
  -- their own gtags DB, branch tracking and cscope connection.
  local function switch_cscope_conn(root)
    local dbpath = util.gtags_dbpath(root)
    -- gtags-cscope resolves the DB via env vars and ignores cscope_maps' -f/-P
    -- args, so the env must point at the current buffer's project.
    vim.env.GTAGSROOT = root
    vim.env.GTAGSDBPATH = dbpath
    -- cscope_maps re-reads vim.g.cscope_maps_db_file on every query and honors
    -- it over its internal connections ("db_file::pre_path" format), so this
    -- works regardless of when the lazy-loaded plugin actually loads.
    vim.g.cscope_maps_db_file = dbpath .. '/GTAGS::' .. root
  end

  vim.keymap.set('n', 'gs', '<Cmd>Cscope find s<CR>', { silent = true })
  vim.keymap.set('n', 'gD', '<Cmd>Cstag<CR>', { silent = true })
  vim.keymap.set('n', 'gR', '<Cmd>Cscope find c<CR>', { silent = true })

  local gtags_building = {} -- root -> true while a gtags job runs
  local function gtags_build(root)
    if gtags_building[root] then return false end
    gtags_building[root] = true
    local dbpath = util.gtags_dbpath(root)
    vim.fn.mkdir(dbpath, 'p')
    vim.system({ 'gtags', dbpath }, { cwd = root, text = true }, function(obj)
      vim.schedule(function()
        gtags_building[root] = nil
        if obj.code ~= 0 then
          vim.notify('gtags: build failed in ' .. root, vim.log.levels.ERROR)
        end
      end)
    end)
    return true
  end

  local function gtags_update(root)
    if gtags_building[root] then return end
    local dbpath = util.gtags_dbpath(root)
    if vim.fn.glob(dbpath .. '/GTAGS') == '' then
      gtags_build(root)
      return
    end
    gtags_building[root] = true
    vim.system({ 'gtags', '--incremental', dbpath }, { cwd = root, text = true }, function(obj)
      vim.schedule(function()
        gtags_building[root] = nil
        if obj.code ~= 0 then
          vim.notify('gtags: update failed in ' .. root, vim.log.levels.ERROR)
        end
      end)
    end)
  end

  local gtags_group = vim.api.nvim_create_augroup('GTags', { clear = true })

  -- Switch the cscope DB to the entered buffer's project and build GTAGS when missing
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = gtags_group,
    callback = function(e)
      if vim.bo[e.buf].buftype ~= '' or not vim.bo[e.buf].modifiable then return end
      if vim.fn.expand('#' .. e.buf .. ':p') == '' then return end
      local root = util.project_root()
      switch_cscope_conn(root)
      if vim.fn.glob(util.gtags_dbpath(root) .. '/GTAGS') == '' then
        gtags_build(root)
      end
    end,
    desc = 'switch cscope DB and build GTAGS on BufEnter when missing',
  })

  -- Incremental update on BufWritePost
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = gtags_group,
    callback = function(e)
      if vim.bo[e.buf].buftype ~= '' or not vim.bo[e.buf].modifiable then return end
      if vim.fn.expand('#' .. e.buf .. ':p') == '' then return end
      gtags_update(util.project_root())
    end,
    desc = 'incremental GTAGS update on save',
  })

  -- Branch-aware gtags rebuild. Detect a branch switch by comparing the joint
  -- (branch, HEAD) identity against a session baseline, then force a full
  -- rebuild; detached HEAD compares HEAD only. Incremental gtags updates can't
  -- handle deleted/renamed files after a branch switch.
  if vim.g.tags_branch_aware == nil then
    vim.g.tags_branch_aware = 1
  end
  local tags_branch_baseline = {} -- root -> { branch, head }

  local function tags_head_file(root)
    return util.gtags_dbpath(root) .. '/.tags-head'
  end

  local function tags_load_head(root)
    local f = io.open(tags_head_file(root), 'r')
    if not f then return '' end
    local head = f:read('*a')
    f:close()
    return vim.trim(head)
  end

  local function tags_save_head(root, head)
    vim.fn.mkdir(util.gtags_dbpath(root), 'p')
    local f = io.open(tags_head_file(root), 'w')
    if f then
      f:write(head)
      f:close()
    end
  end

  local function tags_branch_identity(root)
    local branch = vim.fn.system('git -C ' .. vim.fn.shellescape(root) .. ' branch --show-current')
    if vim.v.shell_error ~= 0 then return nil end
    local head = vim.fn.system('git -C ' .. vim.fn.shellescape(root) .. ' rev-parse HEAD')
    if vim.v.shell_error ~= 0 then return nil end
    return { branch = vim.fn.trim(branch), head = vim.fn.trim(head) }
  end

  local function tags_update_ctags(root)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.b[buf].gutentags_root == root and vim.b[buf].gutentags_files then
        -- Run in the project buffer without touching the visible buffer/window.
        -- GutentagsUpdate is buffer-local, so it must execute with that buffer
        -- current; nvim_buf_call restores the current buffer automatically.
        vim.api.nvim_buf_call(buf, function()
          if vim.fn.exists(':GutentagsUpdate') == 2 then
            vim.cmd('GutentagsUpdate!')
          end
        end)
        return
      end
    end
  end

  -- Full rebuild for one project. Returns false when a gtags job for that
  -- project is already running, so callers keep their stale baseline and
  -- retry on the next check instead of losing the rebuild.
  local function tags_do_rebuild(root)
    if not gtags_build(root) then return false end
    tags_update_ctags(root)
    return true
  end

  local function tags_check_branch()
    if not vim.g.tags_branch_aware then return end
    -- Require a buffer gutentags has set up for this project. On a bare
    -- startup (no args) no buffer is set up yet, so skip and let the
    -- BufEnter that follows the first file open do the real check. This keeps
    -- gtags and ctags rebuilt together (ctags needs a set-up buffer).
    local root = util.project_root()
    local has_buf = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.b[buf].gutentags_root == root and vim.b[buf].gutentags_files then
        has_buf = true
        break
      end
    end
    if not has_buf then return end

    local info = tags_branch_identity(root)
    if not info then return end

    local base = tags_branch_baseline[root]
    if base == nil then
      -- No in-memory baseline yet (fresh nvim). Rebuild only if the DB was
      -- generated for a different HEAD; trust the existing DB otherwise.
      local saved = tags_load_head(root)
      if saved == '' then
        tags_save_head(root, info.head)
        tags_branch_baseline[root] = info
      elseif saved ~= info.head then
        if tags_do_rebuild(root) then
          tags_save_head(root, info.head)
          tags_branch_baseline[root] = info
        end
        -- else: a gtags job is in flight; the stale baseline makes the next
        -- check retry the rebuild.
      else
        tags_branch_baseline[root] = info
      end
      return
    end

    if base.branch == info.branch and base.head == info.head then return end

    -- Rebuild on a real switch (branch+HEAD both changed) or a detached HEAD
    -- move. Same-branch commit is ignored; rename only refreshes the baseline.
    local rebuild = (base.branch ~= info.branch and base.head ~= info.head)
        or (info.branch == '' and base.head ~= info.head)
    if rebuild then
      if not tags_do_rebuild(root) then return end -- retry on next check
      tags_save_head(root, info.head)
      tags_branch_baseline[root] = info
    elseif base.branch ~= info.branch then
      tags_branch_baseline[root].branch = info.branch
    end
  end

  local function tags_rebuild()
    local root = util.project_root()
    if not tags_do_rebuild(root) then
      vim.notify('TagsRebuild: gtags job already running for ' .. root, vim.log.levels.WARN)
      return
    end
    -- Non-git roots have no (branch, HEAD) identity; rebuild without baseline.
    local info = tags_branch_identity(root)
    if info then
      tags_save_head(root, info.head)
      tags_branch_baseline[root] = info
    end
  end

  vim.api.nvim_create_user_command('TagsRebuild', tags_rebuild, {})

  local tags_group = vim.api.nvim_create_augroup('TagsBranchAware', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = tags_group,
    callback = function() tags_check_branch() end,
  })
  vim.api.nvim_create_autocmd('FocusGained', {
    group = tags_group,
    callback = function() tags_check_branch() end,
  })
  local tags_git_subcommands = {
    'branch', 'checkout', 'switch', 'restore', 'reset', 'merge', 'rebase', 'cherry-pick', 'revert', 'stash', 'pull',
  }
  vim.api.nvim_create_autocmd('User', {
    group = tags_group,
    pattern = 'MiniGitCommandDone',
    callback = function(args)
      if vim.list_contains(tags_git_subcommands, args.data.git_subcommand) then
        tags_check_branch()
      end
    end,
  })

  -- Ctags
  -- Resolve a tag's real line number by searching its pattern in the target buffer.
  local function ctags_resolve_lnum(t)
    local cmd = t.cmd or ''
    local pattern = cmd:match('^/(.*)/$')
    if not pattern then
      return tonumber(cmd:match('^(%d+)'))
    end
    local bufnr = vim.fn.bufnr(t.filename)
    if bufnr == -1 then
      bufnr = vim.fn.bufadd(t.filename)
    end
    vim.fn.bufload(bufnr)
    local re = vim.regex(pattern)
    for i = 1, vim.api.nvim_buf_line_count(bufnr) do
      local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
      if re:match_str(line) then
        return i
      end
    end
    return tonumber(cmd:match('^(%d+)'))
  end

  vim.keymap.set('n', 'gd', '<C-]>')
  vim.keymap.set('n', 'g]', function()
    local tagfunc = vim.bo.tagfunc
    vim.bo.tagfunc = nil
    local name = vim.fn.expand('<cword>')
    local tags = vim.fn.taglist('^' .. vim.fn.escape(name, '\\^$.') .. '$')
    local items = {}
    for _, t in ipairs(tags) do
      table.insert(items, {
        filename = t.filename,
        lnum = ctags_resolve_lnum(t) or 0,
        col = 1,
        text = t.name,
      })
    end

    local ok = pcall(vim.cmd, 'tag ' .. name)
    if not ok then
      vim.bo.tagfunc = tagfunc
      vim.notify('Tag not found: ' .. name, vim.log.levels.ERROR)
      return
    end
    vim.fn.setqflist(items, 'r')
    vim.fn.setqflist({}, 'a', { title = 'tag ' .. name })

    vim.bo.tagfunc = tagfunc
    vim.cmd('botright copen')
  end, { silent = true, desc = 'tag + open quickfix' })

  vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    group = vim.api.nvim_create_augroup('Ctags', { clear = true }),
    pattern = '*.tags',
    command = 'setfiletype tags',
  })
end

return M
