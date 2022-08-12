if exists("g:loaded_algorithm") || &cp || v:version < 800
  finish
endif
let g:loaded_algorithm = 1

function! s:DeleteMap(cmd, mapping) abort
  try
    execute a:cmd . ' ' . a:mapping
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

function! s:InitGetUserPrompt() abort
  let s:secret_user_prompt = ''
  for keyboard in g:gcc_keyboard_pick_list
    if keyboard =~# '^\w'
      call s:ExecuteMap(6, keyboard)
    elseif keyboard ==# g:gcc_comfirm_or_continue
      call s:ExecuteMap(7, keyboard)
    endif
  endfor
endfunction

function! s:DeleteGetUserPrompt() abort
  if exists('s:secret_user_prompt')
    unlet s:secret_user_prompt
  endif
  for keyboard in g:gcc_keyboard_pick_list
    if keyboard =~# '^\w'
      call s:DeleteMap('iunmap', keyboard)
    elseif keyboard ==# g:gcc_comfirm_or_continue
      call s:DeleteMap('iunmap', keyboard)
    endif
  endfor
endfunction

function! s:BeginGetUserPrompt() abort
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
  call s:FindAlgorithm(user_input)
  return " \b"
endfunction

function! s:FindAlgorithm(secret_user_prompt) abort
  call s:DeleteVariable()
  if empty(a:secret_user_prompt)
    return
  endif
  call s:InitVariable()
  let s:algorithm = system('python3 ' . s:plugin_path . '/get.py --suffix=' .  a:secret_user_prompt)
  redraw!
  if s:algorithm =~? '.*None.*'
    let s:algorithm = ''
  endif
  if empty(s:algorithm)
    call s:DeleteVariable()
  endif
endfunction

function! s:InitVariable() abort
  let s:algorithm = ''
  let s:index = 0
  let s:last_pos = []
  let s:current_char = ''
  let s:stack = []
  let s:next_char = ''
  let s:save_keyboard_oper = {}
  let s:pair_right_indent = 0
  for keyboard in g:gcc_keyboard_ban_list
    call s:ExecuteMap(10, keyboard)
  endfor
  for keyboard in g:gcc_keyboard_pick_list
    if keyboard ==# g:gcc_comfirm_or_continue
      call s:ExecuteMap(0, keyboard)
    else
      call s:ExecuteMap(1, keyboard)
    endif
  endfor
  execute 'nmap <silent> ' . g:gcc_back_last_pos . ' <Plug>gen_algorithmBackToLastPos'
  execute 'nmap <silent> ' . g:gcc_release_key_board . ' <Plug>gen_algorithmReleaseKeyBoard'
  execute 'vmap <silent> ' . g:gcc_paste_algorithm . ' <Plug>gen_algorithmPasteAlgorithm'
endfunction

function! s:DeleteVariable() abort
  if exists('s:algorithm')
    unlet s:algorithm
    unlet s:index
    unlet s:last_pos
    unlet s:current_char
    unlet s:stack
    unlet s:next_char
    unlet s:save_keyboard_oper
    unlet s:pair_right_indent
  endif
  for keyboard in g:gcc_keyboard_pick_list
    call s:ExecuteMap(8, keyboard)
  endfor
  for keyboard in g:gcc_keyboard_ban_list
    call s:DeleteMap('iunmap', keyboard)
  endfor
  call s:DeleteMap('nunmap', g:gcc_back_last_pos)
  call s:DeleteMap('nunmap', g:gcc_release_key_board)
  call s:DeleteMap('vunmap', g:gcc_paste_algorithm)
endfunction

function! s:PasteAlgorithm() abort
  if !s:JudgeAlgorithmExists()
    return
  endif
  call deletebufline('%', line('''<'), line('''>'))
  let [save_reg_content, save_reg_type] = [getreg(v:register), getregtype(v:register)]
  call setreg(v:register, s:algorithm, 'l')
  exe 'normal! "' . v:register . 'p'
  call setreg(v:register, save_reg_content, save_reg_type)
  call s:DeleteVariable()
  redraw!
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
  for keyboard in g:gcc_keyboard_pick_list
    call s:DeleteMap('iunmap', keyboard)
  endfor
  for keyboard in g:gcc_keyboard_ban_list
    call s:DeleteMap('iunmap', keyboard)
  endfor
  if !exists('s:algorithm')
    return
  endif
  return
endfunction

function! s:BackToLastPos() abort
  if exists('s:algorithm')
    call s:LockKeyBoard()
    if !empty(s:last_pos)
      if !empty(get(s:pairs, s:TopStack()[0], ''))
        call cursor(s:last_pos[0], s:last_pos[1] - 1)
      else
        call cursor(s:last_pos[0], s:last_pos[1])
      endif
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
  for keyboard in g:gcc_keyboard_pick_list
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
  for keyboard in g:gcc_keyboard_ban_list
    call s:ExecuteMap(10, keyboard)
  endfor
  for keyboard in g:gcc_keyboard_pick_list
    if keyboard ==# g:gcc_comfirm_or_continue
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
  for keyboard in g:gcc_keyboard_pick_list
    if keyboard ==# g:gcc_comfirm_or_continue
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

function! s:JudgeAlgorithmExists() abort
  if !exists('s:algorithm')
    return 0
  endif
  if empty(s:algorithm)
    call s:DeleteVariable()
    redraw!
    return 0
  endif
  return 1
endfunction

function! s:GenerateAlgorithm(press_tab) abort
  if !s:JudgeAlgorithmExists()
    return " \b"
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

function! s:GetPluginPath() abort
  let script_file_path = expand('<sfile>')
  let plugin_path = fnamemodify(script_file_path, ":h:h")
  return plugin_path
endfunction

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
if !exists('g:gcc_keyboard_ban_list')
  let g:gcc_keyboard_ban_list = ['<BS>', '<TAB>', '<CR>', '<SPACE>', ]
endif
if !exists('g:gcc_keyboard_pick_list')
  let g:gcc_keyboard_pick_list = [
        \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 
        \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 
        \ 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 
        \ 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '[', ']', '{', '}', 
        \ '1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', 
        \ '\', ';', ':', '''', '"', ',', '<', '.', '>', '/', '?', '`', '~', 
        \ '8', '*', '9', '(', '0', ')', '-', '_', '=', '+', ]
endif
let s:plugin_path = s:GetPluginPath()
let s:filetype_suffix = {
      \ 'c': 'c', 
      \ 'cpp': 'cpp', 
      \ 'java': 'java', 
      \ 'python': 'py', 
      \ }
if !exists('g:gcc_back_last_pos')
  let g:gcc_back_last_pos = '<F8>'
endif
if !exists('g:gcc_paste_algorithm')
  let g:gcc_paste_algorithm = '<F9>'
endif
if !exists('g:gcc_find_file')
  let g:gcc_find_file = '<F6>'
endif
if !exists('g:gcc_release_key_board')
  let g:gcc_release_key_board = '<F7>'
endif
if !exists('g:gcc_comfirm_or_continue')
  let g:gcc_comfirm_or_continue = ':'
endif

augroup gen_algorithm
  autocmd!
  execute 'autocmd FileType ' . join(keys(s:filetype_suffix), ',') . 
        \ ' noremap <silent> <Plug>gen_algorithm :<C-u>call <SID>BeginGetUserPrompt()<CR>i'
  execute 'autocmd FileType ' . join(keys(s:filetype_suffix), ',') . 
        \ ' noremap <silent> <Plug>gen_algorithmBackToLastPos :<C-u>call <SID>BackToLastPos()<CR>a'
  execute 'autocmd FileType ' . join(keys(s:filetype_suffix), ',') . 
        \ ' noremap <silent> <Plug>gen_algorithmReleaseKeyBoard :<C-u>call <SID>ReleaseKeyBoard()<CR>'
  execute 'autocmd FileType ' . join(keys(s:filetype_suffix), ',') . 
        \ ' noremap <silent> <Plug>gen_algorithmPasteAlgorithm :<C-u>call <SID>PasteAlgorithm()<CR>'

  execute 'autocmd VimEnter,FileType ' . join(keys(s:filetype_suffix), ',') . 
        \ ' nmap <silent> ' . g:gcc_find_file . ' <Plug>gen_algorithm'

augroup END
