local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local utils = require('telescope.previewers.utils')
local config = require('telescope.config').values

---@class TDModule
---@field config TDConfig
---@field setup fun(TDConfig): TDModule

---@class TDConfig

local M = {}

M.images = function (opts)
    pickers
        .new(opts, {
            finder = finders.new_async_job({
                command_generator = function ()
                    return {"docker", "images", "--format", "json"}
                end,

                entry_maker = function (entry)
                    local image = vim.json.decode(entry)
                    if image then
                        return {
                            value = image,
                            display = image.Repository,
                            ordinal = image.Repository .. ':' .. image.Tag,
                        }
                    end
                end,
            }),

        sorter = config.generic_sorter(opts),

        previewer = previewers.new_buffer_previewer ({
            title = 'Imagens Docker',
            define_preview = function (self, entry)
                local data = {
                    '```lua',
                    '# ' .. entry.display,
                    '',
                    '*ID*: ' .. entry.value.ID,
                    '*Tag*: ' .. entry.value.Tag,
                    '*Containers*: ' .. entry.value.Containers,
                    '*Size*: ' .. entry.value.Size,
                    '```',
                }
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    0,
                    0, 
                    true, 
                    data
                )
                utils.highlighter(self.state.bufnr, 'markdown')
            end,
        }),

        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
            end)
            return true 
        end,
    })
    :find()
end

M.containers = function (opts)
    pickers
        .new(opts, {
            finder = finders.new_async_job({
                command_generator = function ()
                    -- return {"docker", "ps", "-a", "--format", "json"}
                    -- return {"sh", "-c", "docker ps -a --format '{{json .}}'", "|", "jq -r .[]", "|", "{Name: .Names, ID: .ID}"}
                    return {"sh", "-c", "./lua/script.sh"}
                end,

                entry_maker = function (entry)
                    local container = vim.json.decode(entry)
                    if container then
                        return {
                            value = container,
                            display = 'dsds',
                            ordinal = 'dsds',
                            -- display = entry.value.ID 
                            -- ordinal = entry.value.ID
                            -- display = "dsds",
                            -- ordinal = "xxx"
                        }
                    end
                end,
            }),

        sorter = config.generic_sorter(opts),

        previewer = previewers.new_buffer_previewer ({
            title = 'Docker Containers',
            define_preview = function (self, entry)
                local data = {
                    '```lua',
                    '# ' .. entry.display,
                    -- '',
                    '*ID*: ' .. entry.value.ID,
                    '*IpAddress*: ' .. entry.value.Name,
                    '*Status*: ' .. entry.value.IPAddress,
                    '```',
                }
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    0,
                    0, 
                    true, 
                    data
                )
                utils.highlighter(self.state.bufnr, 'markdown')
            end,
        }),

        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
            end)
            return true 
        end,
    })
    :find()
end

-- Função de autocompletar
local function dockerComplete(ArgLead, CmdLine, CursorPos)
    local completions = {"Images"}
    local matches = {}
    for _, opt in ipairs(completions) do
        if opt:match("^" .. ArgLead) then
            table.insert(matches, opt)
        end
    end
    return matches
end

-- Lista de comandos disponíveis
vim.api.nvim_create_user_command(
  'Docker',
  function(opts)
      local args = opts.fargs
      local command = table.concat(args, " ")
      
      if command == "Images" then  
        M.images()
      else
        print("Comando não encontrado")
      end
  end,
  {nargs = "?", complete = dockerComplete}
)

-- Mapeamento de teclas
vim.api.nvim_set_keymap('n', '<Leader>di', ':Docker Images<CR>', { noremap = true, silent = true })

M.setup = function(config)
    M.config = config
end

M.containers()

return M
