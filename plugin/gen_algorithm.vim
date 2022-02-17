if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:InitVariable()
  let s:algorithm_file = ''
  let s:algorithm = ''
  let s:index = 0
  let s:cur_pos = []
  imap <F5> <C-o><Plug>gen_algorithmGenerate
  imap <F6> <C-o><Plug>gen_algorithmGenerate

  imap <F7> <C-o><Plug>gen_algorithmRemove
  imap <F8> <C-o><Plug>gen_algorithmRemove
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

  inoremap <F5> <C-[>
  inoremap <F6> <C-[>
  inoremap <F7> <C-[>
  inoremap <F8> <C-[>
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
  while first || s:algorithm[s:index] =~# '\s'
    if first
      let first = 0
    endif
    let save_reg_a = getreginfo('a')
    let @a = s:algorithm[s:index]
    execute 'normal "ap'
    let curpos = getpos('.')
    let lnum = curpos[1]
    let col = curpos[2]
    if !empty(s:cur_pos) && s:index < len(s:cur_pos)
      let lnum = s:cur_pos[s:index][0]
      let col = s:cur_pos[s:index][1]
      call cursor(lnum, col)
    else
      call add(s:cur_pos, [lnum, col])
    endif
    let s:index = s:index + 1
  endwhile
  call setreg('a', save_reg_a)
  if s:index >= len(s:algorithm)
    call s:DeleteVariable()
  endif 
  redraw!
endfunction

function! s:RemoveAlgorithm()
  if !empty(s:algorithm)
    let s:index = max([s:index - 1, 0])
    let lnum = s:cur_pos[s:index][0]
    let col = s:cur_pos[s:index][1]
    call cursor(lnum, col)
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
	\ imap <leader>a <C-o><Plug>gen_algorithmGenerate
  autocmd FileType c,cpp,python,java 
	\ imap <F4> <C-o><Plug>gen_algorithmFindFile
  autocmd FileType c,cpp,python,java 
	\ inoremap <F5> <C-[>
  autocmd FileType c,cpp,python,java 
	\ inoremap <F6> <C-[>
  autocmd FileType c,cpp,python,java 
	\ inoremap <F7> <C-[>
  autocmd FileType c,cpp,python,java 
	\ inoremap <F8> <C-[>
augroup END
