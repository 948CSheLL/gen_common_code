if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:ReleaseCapsAndBs() 
  try
    iunmap A
    iunmap B
    iunmap C
    iunmap D
    iunmap E
    iunmap F
    iunmap G
    iunmap H
    iunmap I
    iunmap J
    iunmap K
    iunmap L
    iunmap M
    iunmap N
    iunmap O
    iunmap P
    iunmap Q
    iunmap R
    iunmap S
    iunmap T
    iunmap U
    iunmap V
    iunmap W
    iunmap X
    iunmap Y
    iunmap Z
    iunmap <BS>
  catch "E31.*"
    return
  endtry
endfunction

function! s:InitVariable()
  let s:algorithm_file = ''
  let s:algorithm = ''
  let s:index = 0
  let s:cur_pos = []
  imap <silent> A <C-o><Plug>gen_algorithmGenerate
  imap <silent> B <C-o><Plug>gen_algorithmGenerate
  imap <silent> C <C-o><Plug>gen_algorithmGenerate
  imap <silent> D <C-o><Plug>gen_algorithmGenerate
  imap <silent> E <C-o><Plug>gen_algorithmGenerate
  imap <silent> F <C-o><Plug>gen_algorithmGenerate
  imap <silent> G <C-o><Plug>gen_algorithmGenerate
  imap <silent> H <C-o><Plug>gen_algorithmGenerate
  imap <silent> I <C-o><Plug>gen_algorithmGenerate
  imap <silent> J <C-o><Plug>gen_algorithmGenerate
  imap <silent> K <C-o><Plug>gen_algorithmGenerate
  imap <silent> L <C-o><Plug>gen_algorithmGenerate
  imap <silent> M <C-o><Plug>gen_algorithmGenerate
  imap <silent> N <C-o><Plug>gen_algorithmGenerate
  imap <silent> O <C-o><Plug>gen_algorithmGenerate
  imap <silent> P <C-o><Plug>gen_algorithmGenerate
  imap <silent> Q <C-o><Plug>gen_algorithmGenerate
  imap <silent> R <C-o><Plug>gen_algorithmGenerate
  imap <silent> S <C-o><Plug>gen_algorithmGenerate
  imap <silent> T <C-o><Plug>gen_algorithmGenerate
  imap <silent> U <C-o><Plug>gen_algorithmGenerate
  imap <silent> V <C-o><Plug>gen_algorithmGenerate
  imap <silent> W <C-o><Plug>gen_algorithmGenerate
  imap <silent> X <C-o><Plug>gen_algorithmGenerate
  imap <silent> Y <C-o><Plug>gen_algorithmGenerate
  imap <silent> Z <C-o><Plug>gen_algorithmGenerate
  imap <silent> <BS> <C-o><Plug>gen_algorithmRemove
endfunction

function! s:DeleteVariable()
  if exists("s:algorithm_file")
    unlet s:algorithm_file
  endif
  if exists("s:algorithm")
    unlet s:algorithm
  endif
  if exists("s:index")
    unlet s:index
  endif
  if exists("s:cur_pos")
    unlet s:cur_pos
  endif

  inoremap <silent> A <ESC>
  inoremap <silent> B <ESC>
  inoremap <silent> C <ESC>
  inoremap <silent> D <ESC>
  inoremap <silent> E <ESC>
  inoremap <silent> F <ESC>
  inoremap <silent> G <ESC>
  inoremap <silent> H <ESC>
  inoremap <silent> I <ESC>
  inoremap <silent> J <ESC>
  inoremap <silent> K <ESC>
  inoremap <silent> L <ESC>
  inoremap <silent> M <ESC>
  inoremap <silent> N <ESC>
  inoremap <silent> O <ESC>
  inoremap <silent> P <ESC>
  inoremap <silent> Q <ESC>
  inoremap <silent> R <ESC>
  inoremap <silent> S <ESC>
  inoremap <silent> T <ESC>
  inoremap <silent> U <ESC>
  inoremap <silent> V <ESC>
  inoremap <silent> W <ESC>
  inoremap <silent> X <ESC>
  inoremap <silent> Y <ESC>
  inoremap <silent> Z <ESC>
  inoremap <silent> <BS> <ESC>
endfunction

function! s:FindFile()
  call s:DeleteVariable()
  let user_input = inputsecret("")
  let algorithm_name = join(split(substitute(user_input, '\A', ' ', 'g'), ' '), '')
  if !empty(algorithm_name)
    call s:InitVariable()
    let s:algorithm_file = fnamemodify(glob(s:third_part_path . '/algorithm_code/*' . algorithm_name . '*/' . &filetype . '/*.' . s:filetype_suffix[&filetype]), ":p")
  endif
endfunction

function! s:FindAlgorithm()
  if !empty(s:algorithm_file) && !isdirectory(s:algorithm_file)
    let s:algorithm = system('cat ' .  s:algorithm_file)
  else
    let s:algorithm = ''
  endif
endfunction

function! s:GenerateAlgorithm()
  if empty(s:algorithm)
    call s:FindAlgorithm()
    if empty(s:algorithm)
      call s:DeleteVariable()
      redraw!
      return
    endif
  endif
  let first = 1
  while first || (s:algorithm[s:index] =~# '\s' && s:algorithm[s:index - 1] =~# '\s')
    if first
      let first = 0
    endif
    let save_reg_a = getreginfo('a')
    let @a = s:algorithm[s:index]
    execute 'normal "ap'
    let curpos = getpos('.')
    let lnum = curpos[1]
    let column = curpos[2]
    if !empty(s:cur_pos) && s:index < len(s:cur_pos)
      let s:cur_pos[s:index][0] = lnum
      let s:cur_pos[s:index][1] = column
    else
      call add(s:cur_pos, [lnum, column])
    endif
    let s:index = s:index + 1
    if s:index >= len(s:algorithm)
      call s:DeleteVariable()
      break
    endif 
  endwhile
  call setreg('a', save_reg_a)
  redraw!
endfunction

function! s:RemoveAlgorithm()
  if !empty(s:algorithm)
    let s:index = max([s:index - 1, 0])
    let lnum = s:cur_pos[s:index][0]
    let column = s:cur_pos[s:index][1]
    call cursor(lnum, column)
    execute 'normal x'
  endif
endfunction

function! s:GetThirdPartPath()
  for var in split(&runtimepath, ',')
    if isdirectory(var . '/.third_part')
      return var . '/.third_part'
    endif
  endfor
endfunction

let s:third_part_path = s:GetThirdPartPath()
let s:filetype_suffix = {
      \ 'c': 'c', 
      \ 'cpp': 'cpp', 
      \ 'java': 'java', 
      \ 'python': 'py', 
      \ }

augroup gen_algorithm
  autocmd!
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmGenerate :<C-u>call <SID>GenerateAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRemove :<C-u>call <SID>RemoveAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmFindFile :<C-u>call <SID>FindFile()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRelease :<C-u>call <SID>ReleaseCapsAndBs()<CR>
  autocmd FileType c,cpp,python,java 
	\ imap <leader>a <C-o><Plug>gen_algorithmGenerate
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F4> <Plug>gen_algorithmFindFile
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F5> <Plug>gen_algorithmRelease
augroup END
