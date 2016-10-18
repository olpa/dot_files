scriptencoding utf-8
set encoding=utf-8

map <F2> <Esc>:1,$!xmllint --format -<CR>
map <F3> <Esc>:'<,'>!wt2db<CR>
map <F8> <Esc>:set tabstop=8<CR>
map <F9> <Esc>:1,$s/\t/ /g<CR>

set lines=24
set columns=80

set smartindent
set softtabstop=2
set shiftwidth=2
set tabstop=8
set expandtab
" Disable for current file
" setl noai nocin nosi inde=
if has("win32")
  set guifont=Courier_New:h12
elseif has("mac")
  set guifont=Monaco:h13
else
  "set guifont=Luxi\ Mono\ 12
  set guifont=Liberation\ Mono\ 12
endif
colorscheme murphy
set hls

" Detect SCons files
" autocmd BufRead SConscript* :setfiletype python
autocmd BufRead SConstruct* :setfiletype python

if !exists("syntax_on")
  syntax on
endif

map! <S-F1> <C-^>
" set keymap=russian-jcuken-z
set keymap=typewriter-z
set imsearch=-1
set iminsert=0

if version<700
  set lcs=tab:··,trail:·
else
  set lcs=tab:··,trail:·,nbsp:·
endif
set list

au BufRead access_log* setf httplog
