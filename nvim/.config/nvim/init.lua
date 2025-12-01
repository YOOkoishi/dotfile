-- ============================================================================
-- YOO_koishi 的 Neovim 配置 (LSP 集成版)
-- 适用于 Arch Linux + C++ / Python / Shell 开发
-- ============================================================================

-- ============================================================================
-- 基础设置
-- ============================================================================

vim.opt.compatible = false
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

-- 行号与显示
vim.opt.number = true
vim.opt.relativenumber = true -- 相对行号，方便 hjkl 跳转
vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.opt.showcmd = true
vim.opt.wildmenu = true
vim.opt.hidden = true
vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- 缩进 (4 空格)
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- 搜索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- 性能与体验
vim.opt.updatetime = 300 -- 减少更新时间，为了 LSP 响应更快
vim.opt.timeoutlen = 500
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus' -- 也就是系统剪贴板
vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'

-- 持久化撤销
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')
vim.fn.mkdir(vim.opt.undodir:get()[1], 'p', '0700')

-- ============================================================================
-- 快捷键 (Leader = 空格)
-- ============================================================================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 保存/退出
vim.keymap.set('n', '<Leader>w', ':w<CR>', { desc = '保存文件' })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { desc = '退出' })
vim.keymap.set('n', '<Leader>/', ':nohlsearch<CR>', { desc = '取消高亮' })

-- 窗口操作 (hjkl)
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- 缩进调整
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

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

-- 特殊文件类型缩进
vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'sh', 'bash', 'zsh', 'yaml', 'json', 'lua' },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
    end,
})

-- ============================================================================
-- 插件管理器 (Lazy.nvim)
-- ============================================================================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 插件列表与配置
-- ============================================================================
require('lazy').setup({
    -- 1. 配色方案
    {
        'morhetz/gruvbox',
        lazy = false,
        priority = 1000,
        config = function() vim.cmd('colorscheme gruvbox') end,
    },

    -- 2. 状态栏
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', optional = true },
        opts = {
            options = {
                theme = 'gruvbox',
                icons_enabled = true,
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    -- 3. 文件树
    {
        'nvim-tree/nvim-tree.lua',
        keys = { { '<Leader>e', ':NvimTreeToggle<CR>', desc = '文件树' } },
        opts = {
            view = { width = 30 },
            renderer = { group_empty = true },
            filters = { dotfiles = false },
        },
    },

    -- 4. 语法高亮 (Treesitter)
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { 'c', 'cpp', 'python', 'bash', 'lua', 'vim', 'json' },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- 5. 辅助工具 (注释/括号/Git)
    { 'numToStr/Comment.nvim', opts = {} },
    { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
    { 'lewis6991/gitsigns.nvim', opts = {} },
    { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

    -- ========================================================================
    -- [重点] LSP (语言服务器) 与 CMP (自动补全) 集成 (修复版)
    -- ========================================================================
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            -- 1. 准备工作：定义通用配置 (capabilities 和 on_attach)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            
            local on_attach = function(client, bufnr)
                local opts = { buffer = bufnr, noremap = true, silent = true }
                -- 按键绑定
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<Leader>cf', function() vim.lsp.buf.format { async = true } end, opts)
                vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            end

            -- 2. 初始化 Mason
            require('mason').setup()

            -- 3. 使用 Handlers 自动配置 LSP (这是修复报错的关键)
            require('mason-lspconfig').setup({
                ensure_installed = { 'clangd', 'pyright', 'bashls', 'lua_ls' },
                
                -- handlers 会自动处理所有安装的 Server，不用再手写 for 循环了
                handlers = {
                    -- 默认处理器：适用于大多数语言 (C++, Python, Bash 等)
                    function(server_name)
                        require('lspconfig')[server_name].setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                        })
                    end,

                    -- 特殊处理器：Lua (需要额外的 settings)
                    ["lua_ls"] = function()
                        require('lspconfig').lua_ls.setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = { globals = { 'vim' } },
                                },
                            },
                        })
                    end,
                },
            })

            -- 4. 配置 CMP 补全引擎 (保持不变)
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                })
            })
        end,
    },
    { 'wakatime/vim-wakatime', lazy = false },
    
})
