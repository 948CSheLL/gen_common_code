if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:Iunmap(mapping) abort
  try
    execute 'iunmap ' . a:mapping
  catch "E31.*"
    return
  endtry
endfunction

function! s:ExecuteMap(map_index, join_string) abort
  let mapping = join(s:GenerateOper[a:map_index], '' . a:join_string)
  execute '' . mapping
  if exists('s:algorithm')
    let s:save_keyboard_oper[a:join_string] = mapping
  endif
  return mapping
endfunction

function! s:GetAlgorithmName(name) abort
  let name = join(split(substitute(a:name, '\A', ' ', 'g'), ' '), '')
  return name
endfunction

function! s:InitGetUserPrompt() abort
  let s:secret_user_prompt = ''
  for keyboard in s:keyboard_pick_list
    if keyboard =~# '^\a'
      call s:ExecuteMap(6, keyboard)
    elseif keyboard ==# '"'
      call s:ExecuteMap(7, keyboard)
    endif
  endfor
endfunction

function! s:DeleteGetUserPrompt() abort
  if exists('s:secret_user_prompt')
    unlet s:secret_user_prompt
  endif
  for keyboard in s:keyboard_pick_list
    if keyboard =~# '^\a'
      call s:Iunmap(keyboard)
    elseif keyboard ==# '"'
      call s:Iunmap(keyboard)
    endif
  endfor
endfunction

function! s:BeginGetUserPrompt() abort
  if !exists('s:is_algorithm_code_exist')
    call s:ExchangeAlgorithmPath()
    return
  endif
  call s:DeleteGetUserPrompt()
  call s:InitGetUserPrompt()
endfunction

function! s:GettingUserPrompt(input_letter) abort
  if !exists('s:secret_user_prompt')
    call s:InitGetUserPrompt()
  endif
  let s:secret_user_prompt = s:secret_user_prompt . a:input_letter
  return " \b"
endfunction

function! s:GettedUserPrompt() abort
  if exists('s:secret_user_prompt')
    let user_input = s:secret_user_prompt
  else
    let user_input = ''
  endif
  call s:DeleteGetUserPrompt()
  call s:FindFile(user_input)
  return " \b"
endfunction

function! s:FindFile(secret_user_prompt) abort
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

function! s:FindAlgorithm() abort
  if !empty(s:algorithm_file) && !isdirectory(s:algorithm_file)
    let s:algorithm = system('cat ' .  s:algorithm_file)
  else
    let s:algorithm = ''
  endif
endfunction

function! s:InitVariable() abort
  let s:algorithm_file = ''
  let s:algorithm = ''
  let s:index = 0
  let s:last_pos = []
  let s:current_char = ''
  let s:stack = []
  let s:next_char = ''
  let s:save_keyboard_oper = {}
  let s:pair_right_indent = 0
  for keyboard in s:keyboard_ban_list
    call s:ExecuteMap(10, keyboard)
  endfor
  for keyboard in s:keyboard_pick_list
    if keyboard ==# '"'
      call s:ExecuteMap(0, keyboard)
    else
      call s:ExecuteMap(1, keyboard)
    endif
  endfor
endfunction

function! s:DeleteVariable() abort
  if exists('s:algorithm')
    unlet s:algorithm_file
    unlet s:algorithm
    unlet s:index
    unlet s:last_pos
    unlet s:current_char
    unlet s:stack
    unlet s:next_char
    unlet s:save_keyboard_oper
    unlet s:pair_right_indent
  endif
  for keyboard in s:keyboard_pick_list
    call s:ExecuteMap(8, keyboard)
  endfor
  for keyboard in s:keyboard_ban_list
    call s:Iunmap(keyboard)
  endfor
endfunction

function! s:RecoverKeyboard() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  for keyboard_oper in values(s:save_keyboard_oper)
    execute '' . keyboard_oper
  endfor
  return " \b"
endfunction

function! s:LockKeyBoard() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  call s:RecoverKeyboard()
  return " \b"
endfunction

function! s:ReleaseKeyBoard() abort
  for keyboard in s:keyboard_pick_list
    call s:Iunmap(keyboard)
  endfor
  for keyboard in s:keyboard_ban_list
    call s:Iunmap(keyboard)
  endfor
  if !exists('s:algorithm')
    return " \b"
  endif
  return " \b"
endfunction

function! s:BackToLastPos() abort
  if !exists('s:is_algorithm_code_exist')
    call s:ExchangeAlgorithmPath()
    return
  endif
  if exists('s:algorithm')
    call s:LockKeyBoard()
    if !empty(get(s:pairs, s:TopStack()[0], ''))
      call cursor(s:last_pos[0], s:last_pos[1] - 1)
    else
      call cursor(s:last_pos[0], s:last_pos[1])
    endif
  endif
endfunction

function! s:EmptyStack() abort
  if !exists('s:algorithm')
    return 1
  endif
  if len(s:stack) > 0
    return 0
  else
    return 1
  endif
endfunction

function! s:PushStack(entry) abort
  if !exists('s:algorithm')
    return ['', 0]
  endif
  call add(s:stack, a:entry)
endfunction

function! s:PopStack() abort
  if !exists('s:algorithm')
    return ['', 0]
  endif
  if len(s:stack) ># 0
    let pop_content = remove(s:stack, -1)
    return pop_content
  else
    return ['', 0]
  endif
endfunction

function! s:TopStack() abort
  if !exists('s:algorithm')
    return ['', 0]
  endif
  if len(s:stack) >=# 1
    let top_content = s:stack[-1]
    return top_content
  else
    return ['', 0]
  endif
endfunction

function! s:TopTwoStack() abort
  if !exists('s:algorithm')
    return ['', 0]
  endif
  if len(s:stack) >=# 2
    let top_two_content = s:stack[-2]
    return top_two_content
  else
    return ['', 0]
  endif
endfunction

function! s:SetIndexAddOne() abort
  if !exists('s:algorithm')
    return
  endif
  let s:index = s:index + 1
  if s:index >=# len(s:algorithm)
    call s:DeleteVariable()
  else
    let s:next_char = s:algorithm[s:index]
  endif
endfunction

function! s:Is_valid_pair_left(char) abort
  if !exists('s:algorithm')
    return 0
  endif
  let judge_result = ((a:char ==# '(' 
	\ || a:char ==# '[' 
	\ || a:char ==# '{' 
	\ || (a:char ==# '''' && (s:TopStack()[0] !=# '''' && s:TopTwoStack()[0] !=# '''')) 
	\ || (a:char ==# '"' && (s:TopStack()[0] !=# '"' && s:TopTwoStack()[0] !=# '"'))) 
	\ && s:TopStack()[0] !=# '\')
  return judge_result
endfunction

function! s:Is_valid_backslash_n_pair_right(char) abort
  if !exists('s:algorithm')
    return 0
  endif
  let judge_result = ((a:char ==# ')' 
	\ || a:char ==# ']' 
	\ || a:char ==# '}' 
	\ || (a:char ==# '"' && s:TopTwoStack()[0] ==# a:char) 
	\ || (a:char ==# '''' && s:TopTwoStack()[0] ==# a:char)) 
	\ && s:TopStack()[0] ==# "\n")
  return judge_result
endfunction

function! s:Is_valid_pair_right(char) abort
  if !exists('s:algorithm')
    return 0
  endif
  let judge_result = (a:char ==# ')' 
	\ || a:char ==# ']' 
	\ || a:char ==# '}' 
	\ || (a:char ==# '"' && s:TopStack()[0] ==# a:char) 
	\ || (a:char ==# '''' && s:TopStack()[0] ==# a:char))
  return judge_result
endfunction

" 处理空白
function! s:HandleWhiteSpace() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let result = ''
  while 1
    let result = result . s:algorithm[s:index]
    if s:TopStack()[0] ==# '\'
      call s:PopStack()
    endif
    if (s:index + 1) >=# len(s:algorithm) 
	  \ || s:algorithm[s:index + 1] =~# '\S'
      break
    else
      let s:index = s:index + 1
    endif
  endwhile
  if (s:index + 1) <# len(s:algorithm) 
	\ && s:Is_valid_backslash_n_pair_right(s:algorithm[s:index + 1])
    let result = ''
  endif
  return result
endfunction

" 处理pair左边
function! s:HandlePairLeft() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  if s:TopStack()[0] ==# '\'
    call s:PopStack()
  else
    call s:PushStack([s:algorithm[s:index], indent('.')])
  endif
  let result = s:algorithm[s:index] . get(s:pairs, s:algorithm[s:index], " \b")
  return result
endfunction

" 处理\npairs 右边
function! s:HandleBackslashNPairRight() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let result = ''
  if s:TopStack()[0] ==# '\'
    call s:PopStack()
    let result = s:algorithm[s:index]
  else
    call s:PopStack()
    let s:pair_right_indent = s:PopStack()[1]
    let result = " \b"
  endif
  return result
endfunction

" 处理pairs 右边
function! s:HandlePairRight() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let result = ''
  if s:TopStack()[0] ==# '\'
    call s:PopStack()
    let result = s:algorithm[s:index]
  else
    call s:PopStack()
    let result = " \b"
  endif
  return result
endfunction

" 处理\n
function! s:HandleBackslashN() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let result = s:algorithm[s:index]
  if (!s:EmptyStack() && s:TopStack()[0] !=# "\n")
	\ && s:TopStack()[0] ==# '\'
    call s:PopStack()
  " 判断栈顶是否为pairs 左边
  elseif (!s:EmptyStack() && s:TopStack()[0] !=# "\n")
  	\ && s:TopStack()[0] !=# '\'
    let result = s:algorithm[s:index] . s:algorithm[s:index]
    call s:PushStack([s:algorithm[s:index], indent('.')])
  endif
  " 需要添加换行延时
  return result
endfunction

" 处理字母
function! s:HandleAlpha(press_tab) abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let result = ''
  while 1
    if s:TopStack()[0] ==# '\'
      call s:PopStack()
    endif
    let result = result . s:algorithm[s:index]
    if a:press_tab ==# 0 
	  \ || (s:index + 1) >=# len(s:algorithm) 
	  \ || (s:algorithm[s:index + 1] =~# '\A'
	  \ && s:algorithm[s:index + 1] !=# '_')
      break
    else
      let s:index = s:index + 1
    endif
  endwhile
  return result
endfunction

" 处理反斜
function! s:HandleBackslash() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  if s:TopStack()[0] ==# '\'
    call s:PopStack()
  else
    call s:PushStack('\')
  endif
  let result = s:algorithm[s:index]
  return result
endfunction

" 处理其他
function! s:HandleOther() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  if s:TopStack()[0] ==# '\'
    call s:PopStack()
  endif
  let result = s:algorithm[s:index]
  return result
endfunction

function! s:DecideNextOper() abort
  if !exists('s:algorithm')
    return
  endif
  for keyboard in s:keyboard_pick_list
    if s:Is_valid_pair_left(s:next_char)
      call s:ExecuteMap(2, keyboard)
    elseif s:next_char ==# "\n" && !empty(get(s:pairs, s:TopStack()[0], ''))
      call s:ExecuteMap(3, keyboard)
    elseif s:next_char ==# "\n"
      call s:ExecuteMap(9, keyboard)
    elseif s:Is_valid_backslash_n_pair_right(s:next_char)
      call s:ExecuteMap(4, keyboard)
    elseif s:Is_valid_pair_right(s:next_char)
      call s:ExecuteMap(5, keyboard)
    endif
  endfor
endfunction

function! s:BeforeHandlePairs() abort
  if !exists('s:algorithm')
    return
  endif
  for keyboard in s:keyboard_ban_list
    call s:ExecuteMap(10, keyboard)
  endfor
  for keyboard in s:keyboard_pick_list
    if keyboard ==# '"'
      call s:ExecuteMap(0, keyboard)
    else
      call s:ExecuteMap(1, keyboard)
    endif
  endfor
endfunction

function! s:SetPairLeftPos() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let cur_pos = getpos('.')
  call cursor(cur_pos[1], cur_pos[2] - 1)
  call s:BeforeHandlePairs()
  call s:DecideNextOper()
  return " \b"
endfunction

function! s:SetPairLeftBackslashNPos() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let cur_pos = getpos('.')
  let line_content = repeat(' ', s:TopTwoStack()[1]) . get(s:pairs, s:TopTwoStack()[0], '')
  call setline(cur_pos[1], line_content)
  call cursor(cur_pos[1] - 1, 1)
  call s:BeforeHandlePairs()
  call s:DecideNextOper()
  return " \b"
endfunction

function! s:SetBackslashNPairRightPos() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let cur_pos = getpos('.')
  call cursor(cur_pos[1] + 1, s:pair_right_indent + 2)
  let s:last_pos = [cur_pos[1] + 1, s:pair_right_indent + 2]
  call s:BeforeHandlePairs()
  call s:DecideNextOper()
  if s:next_char != "\n" 
	\ && !s:Is_valid_pair_right(s:next_char) 
	\ && !s:Is_valid_backslash_n_pair_right(s:next_char)
    call s:BackslashBanKeyboard()
  endif
  return " \b"
endfunction

function! s:SetPairRightPos() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let cur_pos = getpos('.')
  call cursor(cur_pos[1], cur_pos[2] + 1)
  call s:BeforeHandlePairs()
  call s:DecideNextOper()
  return " \b"
endfunction

function! s:SetBackslashNPos() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  let result = ''
  if s:algorithm[s:index] =~# '\s'
    let result = s:HandleWhiteSpace()
    call s:SetIndexAddOne()
  endif
  call setline('.', '')
  if exists('s:algorithm') 
	\ && s:Is_valid_backslash_n_pair_right(s:algorithm[s:index])
    let result = "\b"
  endif
  call s:BeforeHandlePairs()
  call s:DecideNextOper()
  return result
endfunction

function! s:BackslashBanKeyboard()
  if !exists('s:algorithm')
    return
  endif
  for keyboard in s:keyboard_pick_list
    if keyboard ==# '"'
      execute 'inoremap <silent> ' . keyboard . ' <C-r>=<SID>RecoverKeyboard()<CR>'
    else
      execute 'inoremap <silent> ' . keyboard . ' <NOP>'
    endif
  endfor
endfunction

function! s:SetLastPos() abort
  if !exists('s:algorithm')
    return " \b"
  endif
  if s:current_char ==# "\n" 
	\ && s:algorithm[s:index] !=# "\n" 
	\ && !s:Is_valid_pair_right(s:algorithm[s:index])
	\ && !s:Is_valid_backslash_n_pair_right(s:algorithm[s:index])
    call s:BackslashBanKeyboard()
  endif
  let cur_pos = getpos('.')
  let s:last_pos = [cur_pos[1], cur_pos[2]]
  return " \b"
endfunction

function! s:GenerateAlgorithm(press_tab) abort
  if empty(s:algorithm)
    call s:FindAlgorithm()
    if empty(s:algorithm)
      redraw!
      return " \b"
    endif
  endif
  let s:current_char = s:algorithm[s:index]
  let result = ''
  " 当前在pairs 左边
  if s:Is_valid_pair_left(s:current_char)
    let result = s:HandlePairLeft()
  " 当前是\npairs 右边
  elseif s:Is_valid_backslash_n_pair_right(s:current_char)
    let result = s:HandleBackslashNPairRight()
  " 当前是pairs 右边
  elseif s:Is_valid_pair_right(s:current_char)
    let result = s:HandlePairRight()
  " 当前是换行
  elseif s:current_char ==# "\n"
    let result = s:HandleBackslashN()
  " 当前是反斜
  elseif s:current_char ==# '\'
    let result = s:HandleBackslash()
  " 当前是空白
  elseif s:current_char =~# '\s'
    let result = s:HandleWhiteSpace()
  " 当前是字母
  elseif s:current_char =~# '\a' || s:current_char ==# '_'
    let result = s:HandleAlpha(a:press_tab)
  else
    let result = s:HandleOther()
  endif
  call s:SetIndexAddOne()
  call s:DecideNextOper()
  redraw!
  return result
endfunction

function! s:GetThirdPartPath() abort
  for path in split(&runtimepath, ',')
    if isdirectory(path . '/.third_part')
      let result = path . '/.third_part'
      return result
    endif
  endfor
endfunction

function! s:ExchangeAlgorithmPath() abort
  if !isdirectory(s:third_part_path . '/algorithm_code')
    let user_input = input('Algorithm code do not exist, do you want to add it? [default: yes]:')
    if !empty(user_input) && (user_input ==? 'no' || user_input ==? 'n')
      return
    endif
  else
    let user_input = input('Algorithm code exists, do you want to exchange? [default: no]:')
    if empty(user_input) || user_input ==? 'no' || user_input ==? 'n'
      return
    else
      call delete(s:third_part_path . '/algorithm_code', "rf")
    endif
  endif
  let user_input = input('Please input algorithm code path: ')
  if empty(user_input)
    call delete(s:third_part_path . '/algorithm_code', "rf")
    call s:UpdateAlgorithmList()
    redraw!
    return
  endif
  while !isdirectory(fnamemodify(user_input, ":p"))
    if exists('s:is_algorithm_code_exist')
      unlet s:is_algorithm_code_exist
    endif
    let user_input = input('Please input a valid path: ')
    if empty(user_input)
      call delete(s:third_part_path . '/algorithm_code', "rf")
      call s:UpdateAlgorithmList()
      redraw!
      return
    endif
  endwhile
  call system('ln -s ' . fnamemodify(user_input, ":p") . ' ' . s:third_part_path . '/algorithm_code')
  let s:is_algorithm_code_exist = 1
  call s:UpdateAlgorithmList()
  redraw!
endfunction

function! s:UpdateAlgorithmList() abort
  if isdirectory(s:third_part_path . '/algorithm_code')
    let s:is_algorithm_code_exist = 1
  else
    return
  endif
  let s:algorithm_list = {}
  let full_directory_list = split(glob(s:third_part_path . '/algorithm_code/*'),"\n")
  for full_directory_name in full_directory_list
    let algorithm_name = s:GetAlgorithmName(fnamemodify(full_directory_name, ":t"))
    let s:algorithm_list[algorithm_name] = {
	  \ 'directory_name': fnamemodify(full_directory_name, ":t"), 
	  \ 'full_directory_name': full_directory_name, 
	  \ }
  endfor
endfunction

function! s:DisplayAlgorithmList() abort
  if !exists('s:is_algorithm_code_exist')
    call s:ExchangeAlgorithmPath()
    return
  endif
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  let algorithm_names = sort(keys(s:algorithm_list))
  for algorithm_name in algorithm_names
    echo s:algorithm_list[algorithm_name]['directory_name']
  endfor
endfunction

function! s:RenameAlgorithm() abort
  if !exists('s:is_algorithm_code_exist')
    call s:ExchangeAlgorithmPath()
    return
  endif
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

function! s:RemoveAlgorithm() abort
  if !exists('s:is_algorithm_code_exist')
    call s:ExchangeAlgorithmPath()
    return
  endif
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

function! s:SearchAlgorithm() abort
  if !exists('s:is_algorithm_code_exist')
    call s:ExchangeAlgorithmPath()
    return
  endif
  if s:is_algorithm_update
    let s:is_algorithm_update = 0
    call s:UpdateAlgorithmList()
  endif
  let type = input('Which file type do you want to search? [src/doc, default: src]: ')
  if type ==? 'src' || empty(type)
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
let s:pairs = {
      \ '(': ')', 
      \ '\': '\', 
      \ '[': ']', 
      \ '{': '}', 
      \ '''': '''', 
      \ '"': '"', 
      \ }
let s:GenerateOper = [
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(1)<CR><C-r>=<SID>SetLastPos()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(0)<CR><C-r>=<SID>SetLastPos()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(0)<CR><C-r>=<SID>SetPairLeftPos()<CR><C-r>=<SID>SetLastPos()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(0)<CR><C-r>=<SID>SetPairLeftBackslashNPos()<CR><C-r>=<SID>SetBackslashNPos()<CR><C-r>=<SID>SetLastPos()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(0)<CR><C-r>=<SID>SetBackslashNPairRightPos()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(0)<CR><C-r>=<SID>SetPairRightPos()<CR><C-r>=<SID>SetLastPos()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GettingUserPrompt(''', ''')<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GettedUserPrompt()<CR><ESC>'], 
      \ ['inoremap <silent> ', ' <ESC>:<C-u>call <SID>ReleaseKeyBoard()<CR>'], 
      \ ['inoremap <silent> ', ' <C-r>=<SID>GenerateAlgorithm(0)<CR><C-r>=<SID>SetBackslashNPos()<CR><C-r>=<SID>SetLastPos()<CR>'],
      \ ['inoremap <silent> ', ' <NOP>'], ]
" except '|'
let s:keyboard_ban_list = ['<BS>', '<TAB>', '<CR>', '<SPACE>', ]
let s:keyboard_pick_list = [
      \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 
      \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 
      \ 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 
      \ 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '[', ']', '{', '}', 
      \ '1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', 
      \ '\', ';', ':', '''', '"', ',', '<', '.', '>', '/', '?', '`', '~', 
      \ '8', '*', '9', '(', '0', ')', '-', '_', '=', '+', ]
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
	\ noremap <silent> <Plug>gen_algorithmExchangeAlgorithmPath :<C-u>call <SID>ExchangeAlgorithmPath()<CR>
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F5> <Plug>gen_algorithmExchangeAlgorithmPath
  autocmd FileType c,cpp,python,java 
	\ imap <silent> <F5> <ESC><Plug>gen_algorithmExchangeAlgorithmPath
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F8> <Plug>gen_algorithmBackToLastPos
  autocmd FileType c,cpp,python,java 
	\ imap <silent> <F8> <ESC><Plug>gen_algorithmBackToLastPos
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F6> <Plug>gen_algorithmFindFile
  autocmd FileType c,cpp,python,java 
	\ imap <silent> <F6> <ESC><Plug>gen_algorithmFindFile
  autocmd FileType c,cpp,python,java 
	\ inoremap <silent> <F7> <C-r>=<SID>ReleaseKeyBoard()<CR><ESC>
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F1> <Plug>gen_algorithmSearchAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F2> <Plug>gen_algorithmRenameAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F3> <Plug>gen_algorithmRemoveAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F4> <Plug>gen_algorithmDisplayAlgorithm
augroup END
