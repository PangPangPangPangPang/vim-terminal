if exists('g:MXTerminalLoaded')
  finish
end
let g:MXTerminalLoaded = 1

let g:mx_has_terminal = 0
let g:mx_terminal_buffer_number = 0
let g:mx_called_toggle = 0
let g:mx_is_terminal_open = 0

let g:mx_terminal_default_height = 10
let g:mx_terminal_custom_height = 0

function! MXTerminalToggle()
    if g:mx_is_terminal_open == 1
        call MXTerminalClose()
        let g:mx_is_terminal_open = 0
    else
        call MXTerminalOpen()
        let g:mx_is_terminal_open = 1
    endif
endfunction

function! MXTerminalClose()
    if winnr() == bufwinnr(g:mx_terminal_buffer_number)
        exec 'wincmd p'
        exec bufwinnr(g:mx_terminal_buffer_number) . 'wincmd w'
    else
        exec bufwinnr(g:mx_terminal_buffer_number) . 'wincmd w'
    endif
    close
endfunction

function! MXTerminalOpen()
    let g:mx_called_toggle = 1
    let terminal_height = g:mx_terminal_custom_height > 0 ? g:mx_terminal_custom_height : g:mx_terminal_default_height
    if g:mx_has_terminal == 0
        " Terminal init finished.
        let g:mx_has_terminal = 1
        execute 'rightbelow terminal ++rows=' . terminal_height
    else
        exec 'rightbelow ' . terminal_height . ' split'
        exec 'b ' . g:mx_terminal_buffer_number
    endif
    call MXSetDefaultConfig()
endfunction

function! MXSetDefaultConfig()
    exec 'set wfh'
endfunction


function! MXGetTerminalBufferNumber()
    " Save terminal buffer number.
    let l:window_count = winnr()
    let l:buffer_count = winbufnr(l:window_count)
    let g:mx_terminal_buffer_number = l:buffer_count
endfunction

function! MXTerminalSetDefault()
    " Mark the first terminal as default.
    if g:mx_terminal_buffer_number == 0
        call MXGetTerminalBufferNumber()
    endif
endfunction

au TerminalOpen * if &buftype == 'terminal' | call MXTerminalSetDefault() | endif

command! -n=0 -bar MXTerminalToggle :call MXTerminalToggle()
