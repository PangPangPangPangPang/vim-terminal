# vim-terminal
Use terminal easily in vim.(only support 8.1)

## Feature
* Quickly open and close terminal with `:MXTerminalToggle`.
* Use `g:mx_terminal_custom_height` to config terminal height.
* Use `g:mx_terminal_custom_pos` to config terminal position.('top' or 'bottom')


## Install
`vim-terminal` should work with any modern plugin managers for Vim.
* [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'PangPangPangPangPang/vim-terminal'`
  
## Usage
Below are some helper lines in my `.vimrc`

```vim
" Quick toggle terminal.
Plug 'PangPangPangPangPang/vim-terminal'
map <F12> :MXTerminalToggle<cr>
tmap <F12> <c-w>:MXTerminalToggle<cr>
```

## Lisence
MIT License. Copyright (c) 2013-2017 Bailey Ling & Contributors.
