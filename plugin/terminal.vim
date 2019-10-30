if exists('g:vs_terminal_loaded')
  finish
end

if !exists('g:vs_terminal_custom_pos')
  let g:vs_terminal_custom_pos = 'bottom'
endif

if !exists('g:vs_terminal_custom_height')
  let g:vs_terminal_custom_height = 10
endif

if !exists('g:vs_terminal_custom_command')
    let g:vs_terminal_custom_command = ''
endif

let g:vs_terminal_loaded = 1
let g:vs_terminal_separator = "a"

let g:vs_terminal_current_number = 0
let g:vs_terminal_delete_bufer_number = 0
let g:vs_is_terminal_open = 0

let g:vs_called_by_toggle = 0
let g:vs_terminal_map = {}
let g:vs_lazyload_cmd = 0

let g:vs_prev_buffer = 0

function! VSTerminalToggle()
    call VSLazyLoadCMD()
    if g:vs_is_terminal_open == 1
        call VSTerminalCloseWin()
    else
        call  VSTerminalOpenWin()
        call VSTerminalOpenBuffer()
    endif
endfunction

function! VSTerminalJudgeAndOpenWin()
    if g:vs_is_terminal_open == 0
        call  VSTerminalOpenWin()
        let g:vs_is_terminal_open = 1
    else
        let l:current_win_number = bufwinnr(str2nr(g:vs_terminal_current_number))
        exec l:current_win_number . 'wincmd W'
    endif
endfunction

function! VSTerminalOpenNew()
    call VSLazyLoadCMD()
    call VSTerminalJudgeAndOpenWin()
    call VSTerminalCreateNew()
endfunction

function! VSTerminalOpenWithIndex(i)
    call VSLazyLoadCMD()
    let l:keys = keys(g:vs_terminal_map)
    let l:index = a:i - 1
    if (a:i > len(g:vs_terminal_map))
        echoe 'Terminal not exists!'
        return
    endif
    let l:bufnr = l:keys[l:index]
    if !bufexists(str2nr(l:bufnr))
        echoe 'Terminal not exists!'
        return
    endif
    call VSTerminalJudgeAndOpenWin()
    exec 'b ' . l:bufnr
    let g:vs_terminal_current_number = l:bufnr
    call VSTerminalRenderStatuslineEvent()

endfunction

function! VSTerminalDeleteWithIndex(i)
    let l:keys = keys(g:vs_terminal_map)
    let l:index = a:i - 1
    if (a:i > len(g:vs_terminal_map))
        echoe 'Terminal not exists!'
        return
    endif
    let l:bufnr = l:keys[l:index]
    if !bufexists(str2nr(l:bufnr))
        echoe 'Terminal not exists!'
        return
    endif
    let g:vs_terminal_delete_bufer_number = l:bufnr
    call VSGetCurrentNumberAfterDelete(l:bufnr)
    call VSTerminalRenderStatuslineEvent()
    exec 'bd! ' . l:bufnr
endfunction

function! VSTerminalCloseWin()
    if len(win_findbuf(g:vs_terminal_current_number)) > 0 
                \ && win_getid() == win_findbuf(g:vs_terminal_current_number)[0]
        exec 'wincmd p'
    else
        let g:vs_prev_buffer = win_getid()
    endif

    exec bufwinnr(str2nr(g:vs_terminal_current_number)) . 'wincmd w'
    close
    call win_gotoid(g:vs_prev_buffer)
    let g:vs_is_terminal_open = 0
endfunction

function! VSTerminalCreateNew()
    " Terminal init finished.
    let g:vs_called_by_toggle = 1
    if has('nvim')
        exec 'enew'
        exec "call termopen(\'zsh\')"
    else
        exec 'terminal ++curwin ' . g:vs_terminal_custom_command
    endif
endfunction

function! VSTerminalOpenWin()
    let l:vs_terminal_pos = g:vs_terminal_custom_pos ==# 'bottom' ? 'botright ' : 'topleft '
    let l:vs_terminal_pos = g:vs_terminal_custom_pos ==# 'left' ? 'topleft ' : g:vs_terminal_custom_pos ==# 'right' ? 'botright ' : l:vs_terminal_pos
    let l:vs_terminal_split = g:vs_terminal_custom_pos ==# 'left' ? ' vsplit' : g:vs_terminal_custom_pos ==# 'right' ? ' vsplit' : ' split'
    exec l:vs_terminal_pos . g:vs_terminal_custom_height . l:vs_terminal_split
    let g:vs_is_terminal_open = 1
endfunction

function! VSTerminalOpenBuffer()
    if g:vs_terminal_current_number == 0 
        call VSTerminalCreateNew()
    else
        if bufexists(str2nr(g:vs_terminal_current_number))
            exec 'b ' . g:vs_terminal_current_number
        else
            let g:vs_terminal_current_number = 0
            call VSTerminalCreateNew()
        endif
    endif
    call VSSetDefaultConfig()
endfunction

function! VSSetDefaultConfig()
    exec 'setlocal wfh'
endfunction


function! VSTerminalSetDefautlBufferNumber()
    " Save terminal buffer number.
    let l:window_number = winnr()
    let l:buffer_number = winbufnr(l:window_number)
    let g:vs_terminal_current_number = l:buffer_number
endfunction

function! VSTerminalOpenEvent()
    if g:vs_called_by_toggle == 1
        " Mark the first terminal as default.
        call VSTerminalSetDefautlBufferNumber()
        let l:window_number = winnr()
        let l:buffer_number = winbufnr(l:window_number)
        let g:vs_terminal_map[l:buffer_number] = 0
        let g:vs_called_by_toggle = 0
        call VSTerminalRenderStatuslineEvent()
    endif
    if has('nvim')
        exec 'normal! a'
    endif
endfunction

function! VSTerminalDeleteEvent()
    let l:buffer_number = 0
    if g:vs_terminal_delete_bufer_number
        let l:buffer_number = g:vs_terminal_delete_bufer_number
    else
        let l:window_number = winnr()
        let l:buffer_number = winbufnr(l:window_number)
    endif

    call VSGetCurrentNumberAfterDelete(l:buffer_number)
    call VSTerminalRenderStatuslineEvent()
    let g:vs_terminal_delete_bufer_number = 0

endfunction

function! VSGetCurrentNumberAfterDelete(n)
    if has_key(g:vs_terminal_map, a:n)
        call remove(g:vs_terminal_map, a:n)
        if a:n == g:vs_terminal_current_number
            let g:vs_terminal_current_number = len(g:vs_terminal_map) > 0 ? keys(g:vs_terminal_map)[0] : 0
        endif
    endif

    if len(g:vs_terminal_map) == 0
        let g:vs_is_terminal_open = 0
    endif
endfunction

function! VSTermianlGetSeparator()
    return g:vs_terminal_separator
endfunction

function! VSTerminalRenderStatuslineEvent()
    set statusline=
    let l:count = len(g:vs_terminal_map)
    let l:keys = keys(g:vs_terminal_map)
    let l:index = 0
    while l:index < l:count
        let l:color = 2
        if l:keys[l:index] == g:vs_terminal_current_number
            let l:color = 1
        endif
        let l:index = l:index + 1
        let l:number = l:index
        exec 'set statusline +=%' . l:color . '*\ ' . l:number . '\ %*'
    endwhile
    highlight User1 gui=bold term=bold guibg=#F00056 guifg=#3D3B4F ctermbg=Red ctermfg=Black
    highlight User2 gui=bold term=bold guibg=#3D3B4F guifg=#F00056 ctermbg=Black ctermfg=Red
    highlight Statusline guibg=#3D3B4F guifg=#3D3B4F ctermbg=Black ctermfg=Black
endfunction

function! VSTerminalBufEnterEvent()
    let g:vs_prev_buffer = win_getid(winnr("#"))
    if has('nvim')
        exec 'normal! a'
    endif
endfunction


command! -nargs=0 -bar VSTerminalToggle :call VSTerminalToggle()
command! -nargs=0 -bar VSTerminalOpenNew :call VSTerminalOpenNew()
command! -nargs=1 -bar VSTerminalOpenWithIndex :call VSTerminalOpenWithIndex('<args>')
command! -nargs=1 -bar VSTerminalDeleteWithIndex :call VSTerminalDeleteWithIndex('<args>')

function! VSLazyLoadCMD()
    if g:vs_lazyload_cmd == 0
        augroup VS
            if has('nvim')
                au TermOpen * if &buftype == 'terminal' | call VSTerminalOpenEvent() | endif
            else
                au TerminalOpen * if &buftype == 'terminal' | call VSTerminalOpenEvent() | endif
            endif
            au BufDelete * if &buftype == 'terminal' | call VSTerminalDeleteEvent() | endif
            au BufWinEnter,BufEnter * if &buftype == 'terminal' | call VSTerminalRenderStatuslineEvent() | endif
            au BufWinEnter * if &buftype == 'terminal' | call VSTerminalBufEnterEvent() | endif
        augroup END
        let g:vs_lazyload_cmd = 1

        """"""""""""""""""""""""""" Compatible with old verion.""""""""""""""""""""""""""""
        if exists("g:mx_terminal_custom_pos")
            let g:vs_terminal_custom_pos = g:mx_terminal_custom_pos
        endif

        if exists("g:mx_terminal_custom_height")
            let g:vs_terminal_custom_height = g:mx_terminal_custom_height
        endif
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    endif
endfunction

""""""""""""""""""""""""""" Compatible with old verion.""""""""""""""""""""""""""""
command! -nargs=0 -bar MXTerminalToggle :call VSTerminalToggle()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
