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

## Mappings
Add following configuration to your `.vimrc`:

```
augroup plugin_gen_common_code
  autocmd!
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
	\ imap <silent> <F7> <Plug>gen_algorithmReleaseKeyBoard<ESC>
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F1> <Plug>gen_algorithmSearchAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F2> <Plug>gen_algorithmRenameAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F3> <Plug>gen_algorithmRemoveAlgorithm
  autocmd FileType c,cpp,python,java 
	\ nmap <silent> <F4> <Plug>gen_algorithmDisplayAlgorithm
augroup END
```

