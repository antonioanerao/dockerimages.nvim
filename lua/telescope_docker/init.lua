local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local utils = require('telescope.previewers.utils')
local config = require('telescope.config').values

local M = {}

M.show_docker_images = function (opts)
    pickers.
        new(opts, {
            finder = finders.new_async_job({
                command_generator = function ()
                    return {"docker", "images", "--format", "json"}
                end,


                entry_maker = function (entry)
                    local parsed = vim.json.decode(entry)
                    if parsed then
                        return {
                            value = parsed,
                            display = parsed.Repository,
                            ordinal = parsed.Repository .. ':' .. parsed.Tag,
                        }
                    end
                end,
            }),

        sorter = config.generic_sorter(opts),

        previewer = previewers.new_buffer_previewer ({
            title = 'Docker Images Previewer',
            define_preview = function (self, entry)
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    0,
                    0, 
                    true, 
                    vim.tbl_flatten({
                        "# " .. entry.value.ID,
                        "",
                        "```lua",
                        vim.split(vim.inspect(entry.value), "\n"),
                        "```",
                    })
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

M.show_docker_images()

return M
