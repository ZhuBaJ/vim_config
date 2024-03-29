if filereadable(expand("~/.vimrc.bundles"))
      source ~/.vimrc.bundles
endif

execute pathogen#infect()

set t_Co=256
set guifont=FangSong:h12
colorscheme molokai
set background=dark


"要使用扩展很多功能，需要先设置这两个参数
set nocompatible
filetype plugin on

"设置 * 进行 visual 模式下选择的文本搜索
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch()
	let temp = @s
	norm! gv"sy
	let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
	let @s = temp
endfunction

"设置使用 Qargs 命令将 quickfix 列表中的文件加入 args 列表中
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
	let buffer_numbers = {}
	for quickfix_item in getqflist()
		let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
	endfor
	return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction

"定义更新 ctags 文件
function! UpdateCtags()
	let curdir=getcwd()
	while !filereadable("./tags")
		cd ..
		if getcwd() == "/"
			break
		endif
	endwhile
	if filewritable("./tags")
		!ctags -R --file-scope=yes --langmap=c:+.h --languages=c,c++ --links=yes --c-kinds=+p --c++-kinds=+p --fields=+ialS --extra=+q
		TlistUpdate
	endif
	execute ":cd " . curdir
endfunction
"映射 <F10> 作为 ctags 更新按键
nmap <F10> :call UpdateCtags()<CR>

"定义更新 cscope 文件
function! UpdateCscope()
	let curdir=getcwd()
	while !filereadable("./cscope.out")
		cd ..
		if getcwd() == "/"
			break
		endif
	endwhile
	if filewritable("./cscope.out")
        !rm cscope.in.out 
        !cscope -Rbq
        !cscope reset
	endif
	execute ":cd " . curdir
endfunction
"映射 <F11> 作为 ctags 更新按键
nmap <F11> :call UpdateCscope()<CR>

set nu
syntax on
set incsearch
set backspace=indent,eol,start
set autoindent
set complete=k,.
set ignorecase "搜索模式里忽略大小写
set smartcase  "如果搜索模式包含大写字母，不使用 ignorecase 选项
set autowrite  "自动把内容写入文件，如果文件被修改过，跳转到其他文件的时候自动写入
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab  "TAB 扩展为 4 个空格
set cindent    "使用 C/C++ 语言的自动缩进方式
set cinoptions={0,1s,t0,n-2,p2s,(03s,=.5s,>1s,=1s,:1s "设置C/C++语言的具体缩进方式
set showmatch  "设置匹配模式，显示匹配的括号
set linebreak  "整词换行
"set whichwrap=b,s,<,>,[,] "光标从行首和行末可以跳到另一行去
set mouse=a   "使用鼠标
"set previewwindow "标识预览窗口
set laststatus=2 "总是显示最后一个窗口的状态行
set showcmd
set showmode "命令行显示 vim 当前模式
set ruler "显示光标位置在状态行
set hlsearch
filetype plugin indent on
set cmdheight=2
set smartindent " 设置智能缩进

" 设置注释并不会换行时自动添加
set formatoptions-=c
set formatoptions-=r
set formatoptions-=o
set formatoptions-=t

"设置命令自动补全命令方式与 bash shell 的行为一致
set wildmenu
set wildmode=longest,list

"映射命令行回溯历史按键
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

"设置多个文件的快速切换组合键映射，避免使用命令的方式
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

"实用 %% 扩展当前缓冲区所在目录的路径
cnoremap <expr>%% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" 设置文件编码方式自动识别打开
set fileencodings=cp936,ucs-bom,utf-8,utf-16,gbk,big5,gb18030,latin1

" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

set nobackup
let NERDTreeWinPos='right'
map <F6> :NERDTreeToggle<CR>
map <F5> :TlistToggle<CR>

"避免出现跳转 tags 时出现重复的标签
set tags=./tags,tags
"set tags+=/home/water-moon/zgm-work/MC-I12/software/kernel/linux-4.1-r0/tags

if has("cscope")
	set csprg=cscope
	set csto=0 "设置 ctags 命令查找次序：0 先找 cscope 数据库再找 tags 文件，1 先找 tags 文件再找 cscope 库
	set cst "同时找 tags 文件和 cscope 数据库
	set nocsverb
	if filereadable("cscope.out")
		cs add cscope.out
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
	set cscopequickfix=s-,c-,d-,i-,t-,e- "使用 Quickfix 窗口显示 cscope 查找结果
	nmap <C-n> :cnext<CR>
	nmap <C-p> :cprev<CR>
endif

function QfMakeConv()
	let qflist = getqflist()
	for i in qflist
		let i.text = iconv(i.text, "cp936", "utf-8")
	endfor
	call setqflist(qflist)
endfunction

au QuickfixCmdPost make call QfMakeConv()

" 支持自动命令的情况下，reopen 文件的时候使用上一次的位置
if has("autocmd")
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"have Vim load indentation rules and plugins according to the detected filetype
filetype plugin indent on
endif

"自动补全的一些设置
"set completeopt=menu,menuone " 关掉智能补全时的预览窗口
let OmniCpp_MayCompleteDot = 1 " autocomplete with .
let OmniCpp_MayCompleteArrow = 1 " autocomplete with ->
let OmniCpp_MayCompleteScope = 1 " autocomplete with ::
let OmniCpp_SelectFirstItem = 2 " select first item (but don't insert)
let OmniCpp_NamespaceSearch = 2 " search namespaces in this and included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function prototype in popup window
let OmniCpp_GlobalScopeSearch=1 " enable the global scope search
let OmniCpp_DisplayMode=1 " Class scope completion mode: always show all members
"let OmniCpp_DefaultNamespaces=["std"]
let OmniCpp_ShowScopeInAbbr=1 " show scope in abbreviation and remove the last column
let OmniCpp_ShowAccess=1

"Tlist 控件设置
"let Tlist_Ctags_Cmd='ctags' 
let Tlist_Use_Right_Window=0 "让窗口显示在右边，0的话就是显示在左边
let Tlist_Show_One_File=0 "让taglist可以同时展示多个文件的函数列表
let Tlist_File_Fold_Auto_Close=1 "非当前文件，函数列表折叠隐藏
let Tlist_Exit_OnlyWindow=1 "当taglist是最后一个分割窗口时，自动退出vim 是否一直处理tags.1:处理;0:不处理
let Tlist_Process_File_Always=1 "实时更新tags
let Tlist_Inc_Winwidth=0

"折叠设置
set foldmethod=syntax " 用语法高亮来定义折叠
set foldlevel=100 " 启动vim时不要自动折叠代码
set foldcolumn=0 " 设置折叠栏宽度

"cscope 设置
" 将:cs find c等Cscope查找命令映射为<C-_>c等快捷键（按法是先按Ctrl+Shift+-, 然后很快再按下c）
nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR> :copen<CR><CR>
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR> :copen<CR><CR>
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR> :copen<CR><CR>
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR> :copen<CR><CR>
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR> :copen<CR><CR>
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :cs find i <C-R>=expand("<cfile>")<CR><CR> :copen<CR><CR>

"-- QuickFix setting --
" 按下F2，执行make clean
map <F2> :make clean<CR><CR><CR>
" 按下F3，执行make编译程序，并打开quickfix窗口，显示编译信息
map <F7> :make<CR><CR><CR> :copen<CR><CR>
" 以下的映射是使上面的快捷键在插入模式下也能用
imap <F2> <ESC>:make clean<CR><CR><CR>
imap <F3> <ESC>:make<CR><CR><CR> :copen<CR><CR>

"-- WinManager setting --
let g:winManagerWindowLayout='FileExplorer|TagList' " 设置我们要管理的插件
"let g:persistentBehaviour=0 " 如果所有编辑文件都关闭了，退出vim
nmap wm :WMToggle<cr>

" -- MiniBufferExplorer --
let g:miniBufExplMapWindowNavVim = 1 " 按下Ctrl+h/j/k/l，可以切换到当前窗口的上下左右窗口
let g:miniBufExplMapWindowNavArrows = 1 " 按下Ctrl+箭头，可以切换到当前窗口的上下左右窗口
let g:miniBufExplMapCTabSwitchBufs = 1 " 启用以下两个功能：Ctrl+tab移到下一个buffer并在当前窗口打开；Ctrl+Shift+tab移到上一个buffer并在当前窗口打开；ubuntu好像不支持
"let g:miniBufExplMapCTabSwitchWindows = 1 " 启用以下两个功能：Ctrl+tab移到下一个窗口；Ctrl+Shift+tab移到上一个窗口；ubuntu好像不支持
let g:miniBufExplModSelTarget = 1 " 不要在不可编辑内容的窗口（如TagList窗口）中打开选中的buffer
