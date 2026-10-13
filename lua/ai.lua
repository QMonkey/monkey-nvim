local M = {}

-- minuet-ai.nvim: AI completion with env-driven provider presets
M.spec = {
  {
    src = 'https://github.com/milanglacier/minuet-ai.nvim',
    config = function()
      local minuet_presets = {}
      local minuet_preset_order = {}
      local minuet_current_preset = vim.env.NVIM_MINUET_PRESET

      local local_fim_name = vim.env.NVIM_MINUET_LOCAL_NAME or 'llama.cpp'
      local local_fim_options = {
        api_key = 'TERM',
        name = local_fim_name,
        end_point = (vim.env.NVIM_MINUET_LOCAL_BASE_URL or 'http://localhost:8080') .. '/v1/completions',
        model = vim.env.NVIM_MINUET_LOCAL_MODEL or 'qwen2.5-coder:7b',
        stream = false,
        optional = {
          max_tokens = 64,
          top_p = 0.9,
        },
      }

      if local_fim_name == 'llama.cpp' then
        local_fim_options.get_text_fn = {
          no_stream = function(json)
            return json.content
          end,
        }
        local_fim_options.transform = {
          function(data)
            -- llama.cpp /infill: prompt/suffix -> input_prefix/input_suffix
            data.end_point = data.end_point:gsub('/v1/completions$', '/infill')
            data.body.input_prefix = data.body.prompt
            data.body.input_suffix = data.body.suffix or ''
            data.body.prompt = nil
            data.body.suffix = nil
            return data
          end,
        }
      end

      minuet_presets.local_fim = {
        n_completions = 1,
        context_window = 4096,
        request_timeout = 30,
        throttle = 1000,
        debounce = 300,
        provider = 'openai_fim_compatible',
        provider_options = {
          openai_fim_compatible = local_fim_options,
        },
      }
      minuet_preset_order[#minuet_preset_order + 1] = 'local_fim'

      if vim.env.NVIM_MINUET_API_KEY
          and vim.env.NVIM_MINUET_BASE_URL
          and vim.env.NVIM_MINUET_MODEL
          and vim.env.NVIM_MINUET_NAME
      then
        minuet_presets.openai = {
          context_window = 4096,
          request_timeout = 15,
          throttle = 3000,
          debounce = 500,
          provider = 'openai_compatible',
          provider_options = {
            openai_compatible = {
              api_key = 'NVIM_MINUET_API_KEY',
              name = vim.env.NVIM_MINUET_NAME,
              end_point = vim.env.NVIM_MINUET_BASE_URL .. '/v1/chat/completions',
              model = vim.env.NVIM_MINUET_MODEL,
              stream = false,
              optional = {
                max_tokens = 512,
                reasoning_effort = 'none',
              },
            },
          },
        }
        minuet_preset_order[#minuet_preset_order + 1] = 'openai'
      end

      if minuet_presets[minuet_current_preset] then
        require('minuet').setup({
          n_completions = minuet_presets[minuet_current_preset].n_completions or 1,
          context_window = minuet_presets[minuet_current_preset].context_window,
          request_timeout = minuet_presets[minuet_current_preset].request_timeout,
          throttle = minuet_presets[minuet_current_preset].throttle,
          debounce = minuet_presets[minuet_current_preset].debounce,
          provider = minuet_presets[minuet_current_preset].provider,
          provider_options = minuet_presets[minuet_current_preset].provider_options,
          presets = minuet_presets,
          cmp = { enable_auto_complete = false },
          virtualtext = {
            auto_trigger_ft = { '*' },
            auto_trigger_ignore_ft = {
              'help', 'markdown', 'text', 'gitcommit', 'gitrebase', 'qf', 'TelescopePrompt', 'DressingInput', 'terminal',
            },
          },
        })

        vim.keymap.set('n', '<leader>ig', '<cmd>Minuet virtualtext toggle<cr>', {
          desc = 'Minuet: toggle virtual text auto-trigger',
        })
        vim.keymap.set('n', '<leader>ia', function()
          local next_name
          for i, name in ipairs(minuet_preset_order) do
            if name == minuet_current_preset then
              next_name = minuet_preset_order[i % #minuet_preset_order + 1]
              break
            end
          end
          next_name = next_name or minuet_preset_order[1]
          require('minuet').change_preset(next_name)
          minuet_current_preset = next_name
        end, { desc = 'Minuet: cycle provider preset' })

        local minuet_vt = require('minuet.virtualtext').action
        vim.keymap.set('i', '<A-a>', minuet_vt.accept, { desc = 'Minuet: accept suggestion' })
        vim.keymap.set('i', '<A-e>', minuet_vt.accept_line, { desc = 'Minuet: accept one line' })
        vim.keymap.set('i', '<A-y>', minuet_vt.accept_n_lines, { desc = 'Minuet: accept n lines' })
        vim.keymap.set('i', '<A-n>', minuet_vt.next, { desc = 'Minuet: next suggestion' })
        vim.keymap.set('i', '<A-p>', minuet_vt.prev, { desc = 'Minuet: prev suggestion' })
        vim.keymap.set('i', '<A-d>', minuet_vt.dismiss, { desc = 'Minuet: dismiss suggestion' })
      end
    end,
  },
}

return M
