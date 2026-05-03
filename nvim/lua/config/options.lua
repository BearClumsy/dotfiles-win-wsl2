-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.showtabline = 2
vim.opt.termguicolors = true


-- Set background and colorscheme based on current Windows theme
local f = io.open(vim.fn.expand("~/.cache/current-theme"), "r")
if f then
  local theme = f:read("*l")
  f:close()
  if theme == "light" then
    vim.opt.background = "light"
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.cmd("colorscheme catppuccin-latte")
      end,
    })
  else
    vim.opt.background = "dark"
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.cmd("colorscheme catppuccin-mocha")
      end,
    })
  end
end
