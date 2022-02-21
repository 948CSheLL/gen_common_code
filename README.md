# gen_common_code

---

A vim plugin. Help generate algorithm templates during the interview process.

## Installation

---

- Manual
  - `git clone https://github.com/948CSheLL/gen_common_code.git ~/.vim/plugin/gen_common_code`
- Pathogen
  - `git clone https://github.com/948CSheLL/gen_common_code.git ~/.vim/bundle/gen_common_code`
- Vundle
  - `Plugin '948CSheLL/gen_common_code'`
- minpac
  - `call minpac#add('948CSheLL/gen_common_code')`

## Mappings

---

- Type `<F1>` in normal mode，you can view, modify, and add algorithms and documentations by following the prompts in command line. If you want to add a new algorithm, you need to include easy-to-remember letters in the algorithm name to facilitate algorithm retrieval when generating the algorithm.

- Type`<F2>` in normal mode, you can rename an existed algorithm's name to an new name including letters.

- Type`<F3>` in normal mode, you can remove an existed algorithm.

- Type`<F4>` in normal mode, you can watch a list of existed algorithm in command line.

- Type`<F5>` in normal mode, the cursor will be moved to the command line automatically. And then you should type a string of    valid letters according the letter part of the algorithm's name. Retrieval failure or success will not be prompted by any, You need to make sure that what you entered is correct. Assuming your input is correct, most keys on your keyboard will be locked after you enter insert mode, and any key pressed after that will just generate the content of the algorithm you want. Following keys will be locked in insert mode after you type `<F5>`: 

  ```
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
  ```

  If you want to input something else, you can type `<F6>` to unlock keys，and then vim will be shifted into normal mode automatically. When entering insert mode again, you can use keyboard as normal. If you want to continue to generate algorithm, you can type `i`  to entering insert mode and then type `<F6>`. At this point you should be in normal mode, then you should type `<F7>`, it will move the cursor to the correct position in insert mode. You should input some content to ensure that your keys on keyboard is locked, if the content is a part of the algorithm, you can continue. If the content is what you really input, you can type `<BACKSPACE>` to remove the content，and then type `<F6>` to lock keys. At this point you should be in normal mode, then you should type `<F7>` , and then you can continue to generate algorithm.
