let g:mx_has_terminal = 0
let g:mx_terminal_buffer_number = 0
let g:mx_called_toggle = 0

function! MXTerminalWindowToggle()
    let g:mx_called_toggle = 1
    if g:mx_has_terminal == 0
        " Terminal init finished.
        let g:mx_has_terminal = 1
        call MXCreateTermianl()
    else
        exec 'rightbelow' . ' 10 ' . 'split'
        exec 'b ' . g:mx_terminal_buffer_number
    endif
endfunction

function! MXCreateTermianl()
    execute 'rightbelow terminal ++rows=10'
endfunction

function! MXGetTerminalBufferNumber()

    " Save terminal buffer number.
    let l:window_count = winnr()
    let l:buffer_count = winbufnr(l:window_count)
    let g:mx_terminal_buffer_number = l:buffer_count
    echo g:mx_terminal_buffer_number
endfunction


function! MXTerminalBufferCreate()
    echom 'type-1'
    if g:mx_called_toggle == 0
        let b:mx_mark_read_terminal = 1
        echom 'type-2'
    else
        if b:mx_mark_read_terminal == 0
            let b:mx_mark_read_terminal = 1
            echom 'type-3'
            call MXGetTerminalBufferNumber()
        endif
        return
    endif
endfunction

function! MXTerminalSetDefault()
    let b:mx_mark_read_terminal = 0
endfunction
au BufLeave * if &buftype == 'terminal' | call MXTerminalBufferCreate() | endif
au BufWinEnter * call MXTerminalSetDefault()
