local keymap = vim.keymap

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

-- Resize windows
keymap.set("n", "<C-Up>", ":resize +2<CR>")
keymap.set("n", "<C-Down>", ":resize -2<CR>")
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Move text up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Better paste
keymap.set("v", "p", '"_dP')

-- Stay in indent mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Save file
keymap.set("n", "<C-s>", ":w<CR>")

-- Close buffer
keymap.set("n", "<leader>q", ":bd<CR>")

-- CoPilot management
keymap.set("n", "<leader>ai", function()
    if vim.g.copilot_enabled == false then
        vim.cmd("Copilot enable")
        print("CoPilot enabled")
    else
        vim.cmd("Copilot disable")
        print("CoPilot disabled")
    end
end, { desc = "Toggle CoPilot" })

keymap.set("n", "<leader>ap", ":Copilot panel<CR>", { desc = "CoPilot panel" })
keymap.set("n", "<leader>as", ":Copilot status<CR>", { desc = "CoPilot status" })

-- CoPilot Chat
keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { desc = "Open CoPilot Chat" })
keymap.set("n", "<leader>cq", ":CopilotChatToggle<CR>", { desc = "Toggle CoPilot Chat" })
keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Explain selected code" })
keymap.set("v", "<leader>cr", ":CopilotChatReview<CR>", { desc = "Review selected code" })
keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Fix selected code" })
keymap.set("v", "<leader>co", ":CopilotChatOptimize<CR>", { desc = "Optimize selected code" })
keymap.set("v", "<leader>cd", ":CopilotChatDocs<CR>", { desc = "Generate docs for selected code" })
keymap.set("v", "<leader>ct", ":CopilotChatTests<CR>", { desc = "Generate tests for selected code" })
