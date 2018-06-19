if exists('g:mx_terminal_loaded')
  finish
end
let g:mx_terminal_loaded = 1

let g:mx_terminal_buffer_number = 0
let g:mx_is_terminal_open = 0

if !exists("g:mx_terminal_custom_pos")
  let g:mx_terminal_custom_pos = 'bottom'
endif

if !exists("g:mx_terminal_custom_height")
  let g:mx_terminal_custom_height = 10
endif

function! MXTerminalToggle()
    " Set mx_is_terminal_open state to 0 if default terminal is not exist.
    if !bufexists(g:mx_terminal_buffer_number)
        let g:mx_is_terminal_open = 0
    endif

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
    let l:mx_terminal_pos = g:mx_terminal_custom_pos ==# 'bottom' ? 'botright ' : 'topleft '
    if g:mx_terminal_buffer_number == 0
        " Terminal init finished.
        execute l:mx_terminal_pos . 'terminal ++rows=' . g:mx_terminal_custom_height
    else
        if bufexists(g:mx_terminal_buffer_number)
            exec l:mx_terminal_pos . g:mx_terminal_custom_height . ' split'
            exec 'b ' . g:mx_terminal_buffer_number
        else
            let g:mx_terminal_buffer_number = 0
            call MXTerminalOpen()
        endif
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
