" ~/.vimrc — managed from shell-config/vimrc (symlinked by install.sh)
" Minimal defaults, no plugins.
" The if-blocks are skipped by vim-tiny (no +eval), so it won't error.

set nocompatible

" ──────────────────────────────────────────────────────
" SYNTAX & FILETYPES
" ──────────────────────────────────────────────────────
if has('syntax')
  syntax on
endif
if has('autocmd')
  filetype plugin indent on
endif

" ──────────────────────────────────────────────────────
" UI
" ──────────────────────────────────────────────────────
set number                      " Line numbers
set ruler                       " Cursor position in the status line
set showcmd                     " Show partial commands
set laststatus=2                " Always show the status line
set wildmenu                    " Menu for command-line completion
set scrolloff=3                 " Keep 3 lines visible above/below the cursor
set backspace=indent,eol,start  " Backspace over everything in insert mode

" ──────────────────────────────────────────────────────
" INDENTATION
" ──────────────────────────────────────────────────────
set expandtab                   " Spaces, not tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent

" ──────────────────────────────────────────────────────
" SEARCH
" ──────────────────────────────────────────────────────
set incsearch                   " Jump to matches while typing
set hlsearch                    " Highlight matches (:noh to clear)
set ignorecase                  " Case-insensitive...
set smartcase                   " ...unless the pattern has a capital letter
