if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:Iunmap(mapping)
  try
    execute 'iunmap ' . a:mapping
  catch "E31.*"
    return
  endtry
endfunction

function! s:LockKeyBoard()
  if !exists('s:algorithm')
    return ''
  endif
  let s:is_release = 0
  call cursor(s:toggle_lnum, s:toggle_col)
  for keyboard in s:keyboards
    execute 'inoremap <silent> ' . keyboard . ' <C-r>=<SID>GenerateAlgorithm()<CR>'
  endfor
endfunction

function! s:ReleaseKeyBoard() 
  for keyboard in s:keyboards
    call s:Iunmap(keyboard)
  endfor
  if !exists('s:algorithm')
    return ''
  endif
  let s:is_release = 1
  let cur_pos = getpos('.')
  let s:toggle_lnum = cur_pos[1]
  let s:toggle_col = cur_pos[2]
  return ''
endfunction

function! s:GenerateToggle()
  if exists("s:algorithm")
    if s:is_release == 0
      call s:ReleaseKeyBoard()
    else
      call s:LockKeyBoard()
    endif
  endif
  return ''
endfunction

function! s:InitVariable()
  let s:algorithm_file = ''
  let s:algorithm = ''
  let s:index = 0
  let s:last_pos = []
  let s:last_result = ''
  let s:is_release = 0
  let s:toggle_lnum = 0
  let s:toggle_col = 0
  call s:LockKeyBoard()
endfunction

function! s:DeleteVariable()
  if exists("s:algorithm")
    unlet s:algorithm_file
    unlet s:algorithm
    unlet s:index
    unlet s:last_pos
    unlet s:last_result
    unlet s:is_release
    unlet s:toggle_lnum
    unlet s:toggle_col
  endif
  for keyboard in s:keyboards
    execute 'inoremap <silent> ' . keyboard . ' <ESC>:<C-u>call <SID>ReleaseKeyBoard()<CR>'
  endfor
endfunction

function! s:BackToLastPos()
  if exists('s:algorithm')
    call cursor(s:last_pos[0], s:last_pos[1])
  endif
endfunction

function! s:GetAlgorithmName(name)
  return join(split(substitute(a:name, '\A', ' ', 'g'), ' '), '')
endfunction

function! s:InitGetUserPrompt()
  let s:secret_user_prompt = ''
  for keyboard in s:keyboards
    if keyboard =~# '^\a'
      execute 'inoremap <silent> ' . keyboard . ' <C-r>=<SID>GettingUserPrompt(''' . keyboard . ''')<CR>'
    elseif keyboard ==# '<CR>'
      execute 'inoremap <silent> ' . keyboard . ' <C-r>=<SID>GettedUserPrompt()<CR><ESC>'
    endif
  endfor
endfunction

function! s:DeleteGetUserPrompt()
  if exists('s:secret_user_prompt')
    unlet s:secret_user_prompt
  endif
  for keyboard in s:keyboards
    if keyboard =~# '^\a'
      call s:Iunmap(keyboard)
    elseif keyboard ==# '<CR>'
      call s:Iunmap(keyboard)
    endif
  endfor
endfunction

function! s:BeginGetUserPrompt()
  call s:DeleteGetUserPrompt()
  call s:InitGetUserPrompt()
endfunction

function! s:GettingUserPrompt(input_letter)
  if !exists('s:secret_user_prompt')
    call s:InitGetUserPrompt()
  endif
  let s:secret_user_prompt = s:secret_user_prompt . a:input_letter
  return ''
endfunction

function! s:GettedUserPrompt()
  if exists('s:secret_user_prompt')
    let user_input = s:secret_user_prompt
  else
    let user_input = ''
  endif
  call s:DeleteGetUserPrompt()
  call s:FindFile(user_input)
  return ''
endfunction

function! s:FindFile(secret_user_prompt)
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  call s:DeleteVariable()
  let user_input = a:secret_user_prompt
  let algorithm_name = s:GetAlgorithmName(user_input)
  if empty(algorithm_name)
    call s:DeleteVariable()
    return
  endif
  call s:InitVariable()
  let temp = algorithm_name
  let algorithm_name = ''
  for char in temp
    let algorithm_name = algorithm_name . char . '*'
  endfor
  let s:algorithm_file = get(split(glob(
        \ s:third_part_path . '/algorithm_code/' . algorithm_name . '/' . 
        \ &filetype . '/*.' . s:filetype_suffix[&filetype]), "\n"), 0, '')
  if empty(s:algorithm_file)
    call s:DeleteVariable()
    return
  endif
  let s:algorithm_file = fnamemodify(s:algorithm_file, ":p")
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
      return ''
    endif
  endif
  let cur_pos = getpos('.')
  if s:last_result ==# "\n"
    call setline('.', '')
    call cursor(cur_pos[1], 1)
  endif
  let first = 1
  let result = ''
  while first || (s:algorithm[s:index] =~# '\s' && s:algorithm[s:index - 1] =~# '\s')
    if first
      let first = 0
    endif
    let result = result . s:algorithm[s:index]
    let s:index = s:index + 1
    if s:index >= len(s:algorithm)
      call s:DeleteVariable()
      break
    endif 
  endwhile
  redraw!
  if result ==# "\n"
    let s:last_pos = [cur_pos[1] + 1, 1]
  else
    let s:last_pos = [cur_pos[1], cur_pos[2]]
  endif
  let s:last_result = result
  return result
endfunction

function! s:GetThirdPartPath()
  for var in split(&runtimepath, ',')
    if isdirectory(var . '/.third_part')
      return var . '/.third_part'
    endif
  endfor
endfunction

function! s:UpdateAlgorithmList()
  let s:algorithm_list = {}
  let full_directory_list = split(glob(s:third_part_path . "/algorithm_code/*"),"\n")
  for full_directory_name in full_directory_list
    let algorithm_name = s:GetAlgorithmName(fnamemodify(full_directory_name, ":t"))
    let s:algorithm_list[algorithm_name] = {
	  \ 'directory_name': fnamemodify(full_directory_name, ":t"), 
	  \ 'full_directory_name': full_directory_name, 
	  \ }
  endfor
endfunction

function! s:DisplayAlgorithmList()
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  let algorithm_names = sort(keys(s:algorithm_list))
  for algorithm_name in algorithm_names
    echo s:algorithm_list[algorithm_name]['directory_name']
  endfor
endfunction

function! s:RenameAlgorithm()
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  let user_input = input('Please input algorithm you want to rename: ')
  while empty(user_input) || empty(get(s:algorithm_list, s:GetAlgorithmName(user_input), ''))
    let user_input = input('Please input a valid string: ')
  endwhile
  let algorithm_name = s:GetAlgorithmName(user_input)
  let find_result = get(s:algorithm_list, algorithm_name, '')
  let new_name = input('Please input new name: ')
  while empty(new_name)
    let new_find_result = get(s:algorithm_list, s:GetAlgorithmName(new_name), '')
    if !empty(new_find_result) && new_find_result['directory_name'] !=# new_name
      break
    endif
    let new_name = input('Please input a valid string: ')
  endwhile
  let directory_name = s:third_part_path . '/algorithm_code/'
  let old_algorithm_name = find_result['full_directory_name']
  let new_algorithm_name = directory_name . new_name
  for file_type in keys(s:filetype_suffix)
    let old_src_filename = find_result['full_directory_name'] . '/' . file_type . '/' . algorithm_name . '.' . s:filetype_suffix[file_type]
    let new_src_filename = find_result['full_directory_name'] . '/' . file_type . '/' . s:GetAlgorithmName(new_name) . '.' . s:filetype_suffix[file_type]
    let old_doc_filename = find_result['full_directory_name'] . '/' . file_type . '/doc/' . algorithm_name . '.txt'
    let new_doc_filename = find_result['full_directory_name'] . '/' . file_type . '/doc/' . s:GetAlgorithmName(new_name) . '.txt'
    call rename(old_src_filename, new_src_filename)
    call rename(old_doc_filename, new_doc_filename)
  endfor
  call rename(old_algorithm_name, new_algorithm_name)
  let s:is_algorithm_update = 1
endfunction

function! s:RemoveAlgorithm()
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  let user_input = input('Please input algorithm you want to remove: ')
  while empty(user_input) || empty(get(s:algorithm_list, s:GetAlgorithmName(user_input), ''))
    let user_input = input('Please input a valid string: ')
  endwhile
  let algorithm_name = s:GetAlgorithmName(user_input)
  let response = input('Are you sure? [default: no]: ')
  if !empty(response) && (response ==? 'yes' || response ==? 'y')
    let s:is_algorithm_update = 1
    let find_result = get(s:algorithm_list, algorithm_name, '')
    if !empty(find_result)
      call delete(find_result['full_directory_name'], "rf")
    endif
  endif
endfunction

function! s:SearchAlgorithm()
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  let type = input('Which file type do you want to search? [src/doc, default: src]: ')
  if empty(type) || type ==? 'src'
    let type = 'src'
  else
    let type = 'doc'
  endif
  let user_input = input('Please input algorithm you want to search: ')
  while empty(user_input)
    let user_input = input('Please input a valid string: ')
  endwhile
  let algorithm_name = s:GetAlgorithmName(user_input)
  let find_result = get(s:algorithm_list, algorithm_name, '')
  if empty(find_result)
    let response = input('Not find algorithm ''' . user_input . ''', do you want to add it? [default: yes]: ')
    if empty(response) || response ==? 'yes' || response ==? 'y'
      for file_type in keys(s:filetype_suffix)
	let directory_name = s:third_part_path . '/algorithm_code/' . user_input . "/" . file_type . "/doc"
	call mkdir(directory_name, 'p', 0700)
      endfor
      call s:UpdateAlgorithmList()
      let find_result = get(s:algorithm_list, algorithm_name, '')
    else
      return
    endif
  endif
  if type ==# 'src'
    let file_name = s:third_part_path . '/algorithm_code/' . find_result['directory_name'] . '/' . &filetype . '/' . algorithm_name . '.' . s:filetype_suffix[&filetype]
    let directory_name = fnamemodify(file_name, ':h')
    if !isdirectory(directory_name)
      call mkdir(directory_name, 'p', 0700)
    endif
    execute 'vsplit ' . file_name
  elseif type ==# 'doc'
    let file_name = s:third_part_path . '/algorithm_code/' . find_result['directory_name'] . '/' . &filetype . '/doc/' . algorithm_name . '.txt'
    let directory_name = fnamemodify(file_name, ':h')
    if !isdirectory(directory_name)
      call mkdir(directory_name, 'p', 0700)
    endif
    execute 'vsplit ' . file_name
  endif
endfunction

let s:is_algorithm_update = 0
let s:algorithm_list = {}
" except '|'
let s:keyboards = [
      \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 
      \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 
      \ 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 
      \ 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '[', ']', '{', '}', 
      \ '1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', 
      \ '\', ';', ':', '''', '"', ',', '<', '.', '>', '/', '?', '`', '~', 
      \ '8', '*', '9', '(', '0', ')', '-', '_', '=', '+', 
      \ '<BS>', '<TAB>', '<CR>', '<SPACE>', ]
let s:third_part_path = s:GetThirdPartPath()
let s:filetype_suffix = {
      \ 'c': 'c', 
      \ 'cpp': 'cpp', 
      \ 'java': 'java', 
      \ 'python': 'py', 
      \ }

call s:UpdateAlgorithmList()

augroup gen_algorithm
  autocmd!
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmFindFile :<C-u>call <SID>BeginGetUserPrompt()<CR>i
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmSearchAlgorithm :<C-u>call <SID>SearchAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRemoveAlgorithm :<C-u>call <SID>RemoveAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRenameAlgorithm :<C-u>call <SID>RenameAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmDisplayAlgorithm :<C-u>call <SID>DisplayAlgorithmList()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmBackToLastPos :<C-u>call <SID>BackToLastPos()<CR>a
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F7> <Plug>gen_algorithmBackToLastPos
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F5> <Plug>gen_algorithmFindFile
  autocmd FileType c,cpp,python,java 
	\ inoremap <silent> <F6> <C-r>=<SID>GenerateToggle()<CR><ESC>
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F1> <Plug>gen_algorithmSearchAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F2> <Plug>gen_algorithmRenameAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F3> <Plug>gen_algorithmRemoveAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F4> <Plug>gen_algorithmDisplayAlgorithm
augroup END
