local M = {}
local current = nil

local transparent_groups = {
  "Normal", "NormalNC", "NormalFloat", "NormalSB", "Pmenu",
  "TabLine", "TabLineFill", "StatusLine", "StatusLineNC",
  "WinBar", "WinBarNC",
  "BufferLineFill", "BufferLineBackground", "BufferLineBufferSelected",
  "BufferLineBufferVisible", "BufferLineTabSelected", "BufferLineTab",
  "BufferLineTabClose", "BufferLineIndicatorSelected",
}

local function apply_transparency()
  for _, group in ipairs(transparent_groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
    hl.bg = nil
    hl.ctermbg = nil
    vim.api.nvim_set_hl(0, group, hl)
  end
  -- Clear bg only from lualine filler sections (c/x); preserve colored a/b/y/z pills
  for _, prefix in ipairs({ "lualine_c_", "lualine_x_" }) do
    for _, group in ipairs(vim.fn.getcompletion(prefix .. "*", "highlight")) do
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
      hl.bg = nil
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

local function is_wsl()
  local f = io.open("/proc/version", "r")
  if not f then return false end
  local content = f:read("*a")
  f:close()
  return content:lower():find("microsoft") ~= nil or content:lower():find("wsl") ~= nil
end

local function apply_appearance(appearance)
  if appearance == current then return end
  current = appearance
  vim.schedule(function()
    vim.o.background = appearance == "dark" and "dark" or "light"
    vim.cmd("colorscheme " .. (appearance == "dark" and "catppuccin-mocha" or "catppuccin-latte"))
  end)
end

local function check()
  if vim.loop.os_uname().sysname == "Darwin" then
    vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, function(out)
      apply_appearance(out.stdout == "Dark\n" and "dark" or "light")
    end)
  elseif is_wsl() then
    vim.system(
      { "reg.exe", "query", "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize", "/v", "AppsUseLightTheme" },
      { text = true },
      function(out)
        -- 0x0 = dark, 0x1 = light
        local appearance = (out.stdout and out.stdout:find("0x1")) and "light" or "dark"
        apply_appearance(appearance)
      end
    )
  end
end

local marker = vim.fn.stdpath("data") .. "/auto-theme-disabled"

function M.start()
  if vim.g._auto_theme_timer then return end
  vim.fn.delete(marker)
  current = nil
  check()
  vim.g._auto_theme_timer = vim.fn.timer_start(1000, check, { ["repeat"] = -1 })
end

function M.stop()
  if vim.g._auto_theme_timer then
    vim.fn.timer_stop(vim.g._auto_theme_timer)
    vim.g._auto_theme_timer = nil
  end
  vim.fn.writefile({}, marker)
end

function M.init()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      apply_transparency()
      vim.schedule(apply_transparency)
      vim.defer_fn(apply_transparency, 100)
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      if vim.fn.filereadable(marker) == 1 then return end
      M.start()
    end,
  })
end

return M
