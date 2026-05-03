return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = vim.fn.filereadable(vim.fn.expand("~/.cache/win365")) == 1 and "catppuccin-mocha" or "catppuccin",
    },
  },

  -- Catppuccin theme as primary colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = vim.fn.filereadable(vim.fn.expand("~/.cache/win365")) == 0,
      background = {
        light = "latte",
        dark = "mocha",
      },
      integrations = {
        bufferline = true,
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        telescope = true,
        which_key = true,
      },
    },
  },

  -- Keep Tokyo Night as alternative option
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },

  -- Auto theme switching (disabled on Windows 365)
  {
    "f-person/auto-dark-mode.nvim",
    cond = vim.fn.filereadable(vim.fn.expand("~/.cache/win365")) == 0,
    lazy = false,
    priority = 1000,
    opts = {
      update_interval = 1000,
      get_auto_dark_mode = function()
        local f = io.open(vim.fn.expand("~/.cache/current-theme"), "r")
        if f then
          local theme = f:read("*l")
          f:close()
          return theme ~= "light"
        end
        return true
      end,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd("colorscheme catppuccin-mocha")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd("colorscheme catppuccin-latte")
      end,
    },
  },
}
