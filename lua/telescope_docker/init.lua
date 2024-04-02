local pickers = require("telescope.pickers")
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local utils = require('telescope.previewers.utils')
local config = require('telescope.config').values

local M = {}

M.show_docker_images = function (opts)
    pickers.
        new(opts, {
            finder = finders.new_table({
                results = {
                    {name = "Yes", value = {1,2,3,45} },
                    {name = "No", value = {1,2,3,45} },
                    {name = "Maybe", value = {1,2,3,45} },
                },

                entry_maker = function (entry)
                    return {
                        value = entry,
                        display = entry.name,
                        ordinal = entry.name,
                    }
                end,
            }),

        sorter = config.generic_sorter(opts),

        previewer = previewers.new_buffer_previewer ({
            title = 'Docker Images',
            define_preview = function (self, entry)
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    0,
                    0, 
                    true, 
                    vim.tbl_flatten({
                        "Hello", 
                        "Everyone",
                        "",
                        "```lua",
                        vim.split(vim.inspect(entry.value), "\n"),
                        "```",
                    })
                )
                utils.highlighter(self.state.bufnr, 'markdown')
            end,
        }),
    })
    :find()
end

M.show_docker_images()

return M
