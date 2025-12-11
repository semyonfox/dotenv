-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- vim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- sync with system clipboard

-- Plugins
require("lazy").setup({
  -- Theme: Catppuccin (Matches your WezTerm/Ghostty config)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = true, -- Enable if you want opacity from terminal
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- Status Line: Lualine (Matches your Starship config)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Load custom theme
      local custom_theme = require('starship_theme')
      
      require('lualine').setup {
        options = {
          theme = custom_theme,
          component_separators = '',
          section_separators = { left = '', right = '' }, -- Matches Starship flow
          globalstatus = true,
        },
        sections = {
          -- Left: Mode (BrightBlack) -> Branch/File (Black)
          lualine_a = { { 'mode', separator = { left = '', right = '' }, right_padding = 2 } }, 
          lualine_b = { 'filename', 'branch' },
          lualine_c = { 'diff' },
          
          -- Right: FileType -> Progress -> Location (Matches User/Host flow)
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { { 'location', separator = { left = '', right = '' }, left_padding = 2 } },
        },
      }
    end
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function() 
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "bash", "python", "javascript" },
        highlight = { enable = true },
      }
    end
  }
})
