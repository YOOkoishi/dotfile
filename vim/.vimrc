" ============================================================================
" YOO_koishi 的 Vim 配置 - 精简版
" 适用于 Arch Linux + C++ / Python / Shell 开发
" ============================================================================

set nocompatible

" ============================================================================
" 插件管理 - vim-plug
" ============================================================================
" 首次使用请运行: curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" 然后在 Vim 中运行 :PlugInstall

call plug#begin('~/.vim/plugged')

" 外观
Plug 'morhetz/gruvbox'                    " 护眼配色
Plug 'vim-airline/vim-airline'            " 状态栏

" 文件浏览
Plug 'preservim/nerdtree'                 " 文件树

" Git
Plug 'airblade/vim-gitgutter'             " Git diff 标记

" 代码编辑
Plug 'tpope/vim-commentary'               " gcc 快速注释
Plug 'jiangmiao/auto-pairs'               " 自动括号
Plug 'Yggdroot/indentLine'                " 缩进线

" 语法高亮
Plug 'sheerun/vim-polyglot'               " 多语言语法

call plug#end()

" ============================================================================
" 基础设置
" ============================================================================

syntax on
filetype plugin indent on

set number                  " 显示行号
set relativenumber          " 相对行号
set cursorline              " 高亮当前行
set laststatus=2            " 始终显示状态栏
set showcmd                 " 显示命令
set showmatch               " 显示匹配括号
set wildmenu                " 命令行补全菜单

set backspace=indent,eol,start
set hidden                  " 允许隐藏未保存的 buffer

" ============================================================================
" 搜索
" ============================================================================

set ignorecase              " 忽略大小写
set smartcase               " 智能大小写
set incsearch               " 增量搜索
set hlsearch                " 高亮搜索结果

" ============================================================================
" 缩进 (4 空格)
" ============================================================================

set expandtab               " 空格代替 Tab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smartindent
set autoindent

" ============================================================================
" 界面
" ============================================================================

set t_Co=256
set background=dark

" 尝试加载 gruvbox，失败则用 desert
try
  colorscheme gruvbox
catch
  colorscheme desert
endtry

" 真彩色支持
if has('termguicolors')
  set termguicolors
endif

" 光标形状
let &t_SI = "\e[6 q"        " 插入模式: 竖线
let &t_EI = "\e[2 q"        " 普通模式: 方块

" 显示空白字符
set list
set listchars=tab:▸\ ,trail:·

" ============================================================================
" 性能
" ============================================================================

set ttyfast
set lazyredraw
set updatetime=300

" ============================================================================
" 备份与撤销
" ============================================================================

set nobackup
set nowritebackup
set noswapfile

" 持久化撤销
set undofile
set undodir=~/.vim/undo
silent! call mkdir(&undodir, 'p', 0700)

" ============================================================================
" 其他
" ============================================================================

set mouse=a                 " 鼠标支持
set clipboard=unnamedplus   " 系统剪贴板
set noerrorbells visualbell t_vb=
set encoding=utf-8
set fileencoding=utf-8

" ============================================================================
" 快捷键 (Leader = 空格)
" ============================================================================

let mapleader = " "

" 保存/退出
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" 取消搜索高亮
nnoremap <Leader>/ :nohlsearch<CR>

" 窗口切换
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" NERDTree
nnoremap <Leader>e :NERDTreeToggle<CR>

" 保持选中缩进
vnoremap < <gv
vnoremap > >gv

" ============================================================================
" 插件配置
" ============================================================================

" Airline
let g:airline_powerline_fonts = 0

" NERDTree
let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1

" IndentLine
let g:indentLine_char = '┊'

" GitGutter
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'

" ============================================================================
" 自动命令
" ============================================================================

" 记住上次位置
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" 不同文件类型缩进
autocmd FileType python setlocal ts=4 sw=4 sts=4
autocmd FileType cpp,c,h setlocal ts=4 sw=4 sts=4
autocmd FileType sh,bash,zsh setlocal ts=2 sw=2 sts=2
autocmd FileType yaml,json setlocal ts=2 sw=2 sts=2

" ============================================================================
" 快捷命令
" ============================================================================

" 编辑/重载配置
command! Vimrc :edit $MYVIMRC
command! Source :source $MYVIMRC
