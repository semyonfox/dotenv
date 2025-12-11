local colors = {
  base       = '#1e1e2e', -- black
  mantle     = '#181825', -- darker black
  surface0   = '#313244', -- bright-black
  surface1   = '#45475a',
  text       = '#cdd6f4', -- white
  rosewater  = '#f5e0dc',
  lavender   = '#b4befe',
  red        = '#f38ba8',
  peach      = '#fab387',
  yellow     = '#f9e2af',
  green      = '#a6e3a1',
  teal       = '#94e2d5',
  blue       = '#89b4fa',
  mauve      = '#cba6f7',
  flamingo   = '#f2cdcd',
}

local theme = {
  normal = {
    a = { fg = colors.text, bg = colors.surface0, gui = 'bold' }, -- Mode: bright-black bg (Directory style)
    b = { fg = colors.text, bg = colors.base },   -- Branch: black bg (Git style)
    c = { fg = colors.text, bg = colors.base },   -- File: black bg
  },
  insert = {
    a = { fg = colors.base, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.text, bg = colors.surface0 },
    c = { fg = colors.text, bg = colors.base },
  },
  visual = {
    a = { fg = colors.base, bg = colors.mauve, gui = 'bold' },
    b = { fg = colors.text, bg = colors.surface0 },
    c = { fg = colors.text, bg = colors.base },
  },
  replace = {
    a = { fg = colors.base, bg = colors.red, gui = 'bold' },
    b = { fg = colors.text, bg = colors.surface0 },
    c = { fg = colors.text, bg = colors.base },
  },
  command = {
    a = { fg = colors.base, bg = colors.peach, gui = 'bold' },
    b = { fg = colors.text, bg = colors.surface0 },
    c = { fg = colors.text, bg = colors.base },
  },
  inactive = {
    a = { fg = colors.text, bg = colors.base },
    b = { fg = colors.text, bg = colors.base },
    c = { fg = colors.text, bg = colors.base },
  },
}

return theme
