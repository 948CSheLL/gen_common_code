if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:InitVariable()
  let s:algorithm_file = ''
  let s:algorithm = ''
  let s:index = 0
  let s:cur_pos = []
endfunction

function! s:DeleteVariable()
  unlet s:algorithm_file
  unlet s:algorithm
  unlet s:index
  unlet s:cur_pos
endfunction

function! s:FindFile()
  if exists('s:algorithm_file') && !empty(s:algorithm_file)
    return
  endif
  call s:InitVariable()
  let save_reg_z = getreginfo('z')
  execute 'normal "zyy'
  let algorithm_name = join(split(substitute(@z, '\A', ' ', 'g'), ' '), '')
  if !empty(algorithm_name)
    let s:algorithm_file = fnamemodify(glob(s:third_part_path . '/algorithm_code/*' . algorithm_name . '*/' . &filetype . '/*.' . s:filetype_suffix[&filetype]), ":p")
  endif
  call setreg('z', save_reg_z)
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
      redraw!
      return
    endif
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
  call setreg('a', save_reg_a)
  let s:index = s:index + 1
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
  autocmd InsertLeave *.c,*.cpp,*.py,*.java 
	\ call s:FindFile()
augroup END

noremap <silent> <Plug>gen_algorithmGenerate :<C-u>call <SID>GenerateAlgorithm()<CR>
noremap <silent> <Plug>gen_algorithmRemove :<C-u>call <SID>RemoveAlgorithm()<CR>

imap <F5> <C-o><Plug>gen_algorithmGenerate
imap <F6> <C-o><Plug>gen_algorithmGenerate
imap <leader>a <C-o><Plug>gen_algorithmGenerate

imap <F7> <C-o><Plug>gen_algorithmRemove
imap <F8> <C-o><Plug>gen_algorithmRemove
