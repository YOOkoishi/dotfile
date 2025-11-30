-- ============================================================================
-- YOO_koishi 的 Neovim 配置
-- 适用于 Arch Linux + C++ / Python / Shell 开发
-- 使用 lazy.nvim 插件管理器
-- ============================================================================

-- ============================================================================
-- 基础设置
-- ============================================================================

vim.opt.compatible = false

-- 语法和文件类型
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

-- 行号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.wildmenu = true

vim.opt.backspace = 'indent,eol,start'
vim.opt.hidden = true

-- ============================================================================
-- 搜索
-- ============================================================================

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ============================================================================
-- 缩进 (4 空格)
-- ============================================================================

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true

-- ============================================================================
-- 界面
-- ============================================================================

vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- 光标形状
vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'

-- 显示空白字符
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '·' }

-- ============================================================================
-- 性能
-- ============================================================================

vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.updatetime = 300

-- ============================================================================
-- 备份与撤销
-- ============================================================================

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- 持久化撤销
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')
vim.fn.mkdir(vim.opt.undodir:get()[1], 'p', '0700')

-- ============================================================================
-- 其他
-- ============================================================================

vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.errorbells = false
vim.opt.visualbell = true
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- ============================================================================
-- 快捷键 (Leader = 空格)
-- ============================================================================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 保存/退出
vim.keymap.set('n', '<Leader>w', ':w<CR>', { desc = '保存文件' })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { desc = '退出' })

-- 取消搜索高亮
vim.keymap.set('n', '<Leader>/', ':nohlsearch<CR>', { desc = '取消搜索高亮' })

-- 窗口切换
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = '切换到左窗口' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = '切换到下窗口' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = '切换到上窗口' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = '切换到右窗口' })

-- 保持选中缩进
vim.keymap.set('v', '<', '<gv', { desc = '减少缩进' })
vim.keymap.set('v', '>', '>gv', { desc = '增加缩进' })

-- ============================================================================
-- 自动命令
-- ============================================================================

local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

-- 记住上次位置
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 不同文件类型缩进
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'python' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'cpp', 'c', 'h' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'sh', 'bash', 'zsh', 'yaml', 'json' },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ============================================================================
-- 快捷命令
-- ============================================================================

vim.api.nvim_create_user_command('Vimrc', ':edit $MYVIMRC', {})
vim.api.nvim_create_user_command('Source', ':source $MYVIMRC', {})

-- ============================================================================
-- lazy.nvim 插件管理器安装
-- ============================================================================

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 插件配置
-- ============================================================================

require('lazy').setup({
  -- 外观 - gruvbox 配色
  {
    'morhetz/gruvbox',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme gruvbox')
    end,
  },

  -- 状态栏 - lualine (比 vim-airline 更轻量的 Lua 替代)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', optional = true },
    opts = {
      options = {
        theme = 'gruvbox',
        icons_enabled = false,
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
      },
    },
  },

  -- 文件树 - nvim-tree (NERDTree 的现代替代)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<Leader>e', ':NvimTreeToggle<CR>', desc = '切换文件树' },
    },
    opts = {
      view = {
        width = 30,
      },
      renderer = {
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
    },
  },

  -- Git 标记
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
        topdelete = { text = '-' },
        changedelete = { text = '~' },
      },
    },
  },

  -- 快速注释 - gcc
  {
    'numToStr/Comment.nvim',
    opts = {},
  },

  -- 自动括号
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- 缩进线
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '┊',
      },
    },
  },

  -- 语法高亮 - treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'c', 'cpp', 'python', 'bash', 'lua', 'vim', 'vimdoc', 'json', 'yaml' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}, {
  -- lazy.nvim 配置
  checker = { enabled = false },
  change_detection = { notify = false },
})
