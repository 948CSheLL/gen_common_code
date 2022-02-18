if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:ReleaseCapsAndBs() 
  try
    for cap in s:caps
      execute 'iunmap ' . cap
    endfor
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
  for cap in s:caps
    execute 'imap <silent> ' . cap . ' <C-o><Plug>gen_algorithmGenerate'
  endfor
  imap <silent> <BS> <C-o><Plug>gen_algorithmRollBack
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

  for cap in s:caps
    execute 'inoremap <silent> ' . cap . ' <ESC>:<C-u>call <SID>ReleaseCapsAndBs()<CR>'
  endfor
  inoremap <silent> <BS> <ESC>:<C-u>call <SID>ReleaseCapsAndBs()<CR>
endfunction

function! s:GetAlgorithmName(name)
  return join(split(substitute(a:name, '\A', ' ', 'g'), ' '), '')
endfunction

function! s:FindFile()
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  call s:DeleteVariable()
  let user_input = inputsecret("")
  let algorithm_name = s:GetAlgorithmName(user_input)
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

function! s:RollBackAlgorithm()
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
let s:caps = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
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
	\ noremap <silent> <Plug>gen_algorithmGenerate :<C-u>call <SID>GenerateAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRollBack :<C-u>call <SID>RollBackAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmFindFile :<C-u>call <SID>FindFile()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmSearchAlgorithm :<C-u>call <SID>SearchAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRemoveAlgorithm :<C-u>call <SID>RemoveAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmRenameAlgorithm :<C-u>call <SID>RenameAlgorithm()<CR>
  autocmd FileType c,cpp,python,java 
	\ noremap <silent> <Plug>gen_algorithmDisplayAlgorithm :<C-u>call <SID>DisplayAlgorithmList()<CR>
  autocmd FileType c,cpp,python,java 
	\ imap <leader>a <C-o><Plug>gen_algorithmGenerate
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F5> <Plug>gen_algorithmFindFile
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F1> <Plug>gen_algorithmSearchAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F2> <Plug>gen_algorithmRenameAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F3> <Plug>gen_algorithmRemoveAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F4> <Plug>gen_algorithmDisplayAlgorithm
augroup END
