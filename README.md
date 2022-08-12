# gen_common_code

A vim plugin. Help generate algorithm templates during the interview process.

## Installation

- Manual
  - `git clone https://github.com/948CSheLL/gen_common_code.git ~/.vim/plugin/gen_common_code`
- Pathogen
  - `git clone https://github.com/948CSheLL/gen_common_code.git ~/.vim/bundle/gen_common_code`
- Vundle
  - `Plugin '948CSheLL/gen_common_code'`
- minpac
  - `call minpac#add('948CSheLL/gen_common_code')`

## Requirements

- python version 3.0+
- `pip3 install requests`
- `pip3 install click`
- `pip3 install lxml`

## Mappings

Add following configuration to your `.vimrc`:

```
" except '|'
let g:gcc_keyboard_ban_list = ['<BS>', '<TAB>', '<CR>', '<SPACE>', ]
let g:gcc_keyboard_pick_list = [
      \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 
      \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 
      \ 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 
      \ 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '[', ']', '{', '}', 
      \ '1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', 
      \ '\', ';', ':', '''', '"', ',', '<', '.', '>', '/', '?', '`', '~', 
      \ '8', '*', '9', '(', '0', ')', '-', '_', '=', '+', ]
let g:gcc_comfirm_or_continue = '$'
let g:gcc_find_file = '<Leader>4'
let g:gcc_release_key_board = '<Leader>7'
let g:gcc_back_last_pos = '<Leader>8'
let g:gcc_paste_algorithm = '<Leader>9'
```
