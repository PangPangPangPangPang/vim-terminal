if exists('g:mx_terminal_loaded')
  " finish
end
let g:mx_terminal_loaded = 1

let g:mx_terminal_current_number = 0
let g:mx_is_terminal_open = 0

let g:mx_called_by_toggle = 0
let g:mx_terminal_map = {}

if !exists("g:mx_terminal_custom_pos")
  let g:mx_terminal_custom_pos = 'bottom'
endif

if !exists("g:mx_terminal_custom_height")
  let g:mx_terminal_custom_height = 10
endif

function! MXTerminalToggle()
    if g:mx_is_terminal_open == 1
        call MXTerminalCloseWin()
        let g:mx_is_terminal_open = 0
    else
        " call MXTerminalOpen()
        call  MXTerminalOpenWin()
        call MXTerminalOpen()
        let g:mx_is_terminal_open = 1
    endif
endfunction

function! MXTerminalOpenNew()
    if g:mx_is_terminal_open == 0
        call  MXTerminalOpenWin()
        let g:mx_is_terminal_open = 1
    else
        let l:current_win_number = bufwinnr(g:mx_terminal_current_number)
        exec l:current_win_number . 'wincmd W'
    endif
    call MXTerminalCreateNew()
endfunction

function! MXTerminalCloseWin()
    if winnr() == bufwinnr(g:mx_terminal_current_number)
        exec 'wincmd p'
        exec bufwinnr(g:mx_terminal_current_number) . 'wincmd w'
    else
        exec bufwinnr(g:mx_terminal_current_number) . 'wincmd w'
    endif
    close
endfunction

function! MXTerminalCreateNew()
    " Terminal init finished.
    let g:mx_called_by_toggle = 1
    execute 'terminal ++curwin'
endfunction

function! MXTerminalOpenWin()
    let l:mx_terminal_pos = g:mx_terminal_custom_pos ==# 'bottom' ? 'botright ' : 'topleft '
    exec l:mx_terminal_pos . g:mx_terminal_custom_height . ' split'
endfunction

function! MXTerminalOpen()
    if g:mx_terminal_current_number == 0
        call MXTerminalCreateNew()
    else
        if bufexists(str2nr(g:mx_terminal_current_number))
            exec 'b ' . g:mx_terminal_current_number
        else
            let g:mx_terminal_current_number = 0
            call MXTerminalCreateNew()
        endif
    endif
    call MXSetDefaultConfig()
endfunction

function! MXSetDefaultConfig()
    exec 'setlocal wfh'
endfunction


function! MXGetTerminalSetDefautlBufferNumber()
    " Save terminal buffer number.
    let l:window_number = winnr()
    let l:buffer_number = winbufnr(l:window_number)
    let g:mx_terminal_current_number = l:buffer_number
endfunction

function! MXTerminalSetDefault()
    if g:mx_called_by_toggle == 1
        " Mark the first terminal as default.
        call MXGetTerminalSetDefautlBufferNumber()
        let l:window_number = winnr()
        let l:buffer_number = winbufnr(l:window_number)
        let g:mx_terminal_map[l:buffer_number] = 0
        let g:mx_called_by_toggle = 0
    endif
endfunction

function! MXTerminalDelete()
    let g:mx_is_terminal_open = 0
    let l:window_number = winnr()
    let l:buffer_number = winbufnr(l:window_number)
    if has_key(g:mx_terminal_map, l:buffer_number)
        call remove(g:mx_terminal_map, l:buffer_number)
        if l:buffer_number == g:mx_terminal_current_number
            let g:mx_terminal_current_number = len(g:mx_terminal_map) > 0 ? keys(g:mx_terminal_map)[0] : 0
        endif
    endif

endfunction

au TerminalOpen * if &buftype == 'terminal' | call MXTerminalSetDefault() | endif
au BufDelete * if &buftype == 'terminal' | call MXTerminalDelete() | endif

command! -n=0 -bar MXTerminalToggle :call MXTerminalToggle()
