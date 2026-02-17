return {
    -- GitHub Copilot (simplified)
    {
        "github/copilot.vim",
        config = function()
            -- Disable default tab mapping
            vim.g.copilot_no_tab_map = true

            -- Basic keybindings
            vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
                expr = true,
                replace_keycodes = false,
                desc = "Accept CoPilot suggestion"
            })

            vim.keymap.set("i", "<C-L>", '<Plug>(copilot-accept-word)', {
                desc = "Accept CoPilot word"
            })

            vim.keymap.set("i", "<C-N>", '<Plug>(copilot-next)', {
                desc = "Next CoPilot suggestion"
            })

            vim.keymap.set("i", "<C-P>", '<Plug>(copilot-previous)', {
                desc = "Previous CoPilot suggestion"
            })

            vim.keymap.set("i", "<C-D>", '<Plug>(copilot-dismiss)', {
                desc = "Dismiss CoPilot suggestion"
            })
        end,
    },

    -- CoPilot Chat for interactive AI conversations
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "github/copilot.vim" },    -- or github/copilot.lua
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        config = function()
            require("CopilotChat").setup({
                debug = false, -- Enable debugging
                -- See Configuration section for rest
                window = {
                    layout = 'vertical',    -- 'vertical', 'horizontal', 'float', 'replace'
                    width = 0.3,            -- fractional width of parent, or absolute width in columns when > 1
                    height = 0.5,           -- fractional height of parent, or absolute height in rows when > 1
                    -- Options below only apply to floating windows
                    relative = 'editor',    -- 'editor', 'win', 'cursor', 'mouse'
                    border = 'single',      -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
                    row = nil,              -- row position of the window, default is centered
                    col = nil,              -- column position of the window, default is centered
                    title = 'Copilot Chat', -- title of chat window
                    footer = nil,           -- footer of chat window
                    zindex = 1,             -- determines if window is on top or below other floating windows
                },
            })

            -- Keybindings
            vim.keymap.set('n', '<leader>cc', ':CopilotChat<CR>', { desc = 'Open CoPilot Chat' })
            vim.keymap.set('v', '<leader>ce', ':CopilotChatExplain<CR>', { desc = 'Explain selected code' })
            vim.keymap.set('v', '<leader>cr', ':CopilotChatReview<CR>', { desc = 'Review selected code' })
            vim.keymap.set('v', '<leader>cf', ':CopilotChatFix<CR>', { desc = 'Fix selected code' })
            vim.keymap.set('v', '<leader>co', ':CopilotChatOptimize<CR>', { desc = 'Optimize selected code' })
            vim.keymap.set('v', '<leader>cd', ':CopilotChatDocs<CR>', { desc = 'Generate docs for selected code' })
            vim.keymap.set('v', '<leader>ct', ':CopilotChatTests<CR>', { desc = 'Generate tests for selected code' })
            vim.keymap.set('n', '<leader>cq', ':CopilotChatToggle<CR>', { desc = 'Toggle CoPilot Chat' })
        end,
    },

    -- Alternative: Codeium (free)
    --{
    --  "Exafunction/codeium.vim",
    --   event = "BufEnter",
    --   config = function()
    --     vim.keymap.set("i", "<C-J>", function()
    --       return vim.fn["codeium#Accept"]()
    --     end, { expr = true })
    --   end,
    --},

    -- ChatGPT integration
    -- {
    --   "jackMort/ChatGPT.nvim",
    --   event = "VeryLazy",
    --   config = function()
    --     require("chatgpt").setup({
    --       -- You'll need to set your API key
    --       -- api_key_cmd = "echo $OPENAI_API_KEY"
    --     })
    --   end,
    --   dependencies = {
    --     "MunifTanjim/nui.nvim",
    --     "nvim-lua/plenary.nvim",
    --     "nvim-telescope/telescope.nvim"
    --   }
    -- },
}
