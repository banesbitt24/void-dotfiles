return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "hcl",
        "terraform",
        "dockerfile",
        "yaml",
        "json",
        "lua",
        "markdown",
        "vim",
        "regex",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      -- Add this to help with installation issues
      install = {
        prefer_git = false,
      },
    })
  end,
}
