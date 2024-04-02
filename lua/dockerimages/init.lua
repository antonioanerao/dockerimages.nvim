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
            title = 'Image Details',
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

vim.api.nvim_create_user_command(
  'DockerImages',
  function()
      M.images()
  end,
  {desc = "Retorna uma lista com suas imagens Docker"}
)

M.setup = function(config)
    M.config = config
end

return M
