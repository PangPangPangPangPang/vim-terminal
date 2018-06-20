if exists('g:vs_terminal_loaded')
  finish
end
let g:vs_terminal_loaded = 1

let g:vs_terminal_current_number = 0
let g:vs_is_terminal_open = 0

let g:vs_called_by_toggle = 0
let g:vs_terminal_map = {}
let g:vs_lazyload_cmd = 0


if !exists("g:vs_terminal_custom_pos")
  let g:vs_terminal_custom_pos = 'bottom'
endif

if !exists("g:vs_terminal_custom_height")
  let g:vs_terminal_custom_height = 10
endif

function! VSLazyLoadCMD()
    if g:vs_lazyload_cmd == 0
        augroup VS
            au TerminalOpen * if &buftype == 'terminal' | call VSTerminalSetDefault() | endif
            au BufDelete * if &buftype == 'terminal' | call VSTerminalDelete() | endif
            au BufWinEnter,BufEnter * if &buftype == 'terminal' | call VSTerminalRenderStatusline() | endif
        augroup END
        let g:vs_lazyload_cmd = 1
endif
endfunction

function! VSTerminalToggle()
    call VSLazyLoadCMD()
    if g:vs_is_terminal_open == 1
        call VSTerminalCloseWin()
        let g:vs_is_terminal_open = 0
    else
        " call VSTerminalOpen()
        call  VSTerminalOpenWin()
        call VSTerminalOpen()
        let g:vs_is_terminal_open = 1
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
    let l:bufnr = keys[l:index]
    if !bufexists(str2nr(l:bufnr))
        echoe 'Terminal not exists!'
        return
    endif
    call VSTerminalJudgeAndOpenWin()
    exec 'b ' . l:bufnr
    let g:vs_terminal_current_number = l:bufnr
    call VSTerminalRenderStatusline()
endfunction

function! VSTerminalCloseWin()
    if winnr() == bufwinnr(str2nr(g:vs_terminal_current_number))
        exec 'wincmd p'
        exec bufwinnr(str2nr(g:vs_terminal_current_number)) . 'wincmd w'
    else
        exec bufwinnr(str2nr(g:vs_terminal_current_number)) . 'wincmd w'
    endif
    close
endfunction

function! VSTerminalCreateNew()
    " Terminal init finished.
    let g:vs_called_by_toggle = 1
    execute 'terminal ++curwin'
endfunction

function! VSTerminalOpenWin()
    let l:vs_terminal_pos = g:vs_terminal_custom_pos ==# 'bottom' ? 'botright ' : 'topleft '
    exec l:vs_terminal_pos . g:vs_terminal_custom_height . ' split'
endfunction

function! VSTerminalOpen()
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

function! VSTerminalSetDefault()
    if g:vs_called_by_toggle == 1
        " Mark the first terminal as default.
        call VSTerminalSetDefautlBufferNumber()
        let l:window_number = winnr()
        let l:buffer_number = winbufnr(l:window_number)
        let g:vs_terminal_map[l:buffer_number] = 0
        let g:vs_called_by_toggle = 0
        call VSTerminalRenderStatusline()
    endif
endfunction

function! VSTerminalDelete()
    let g:vs_is_terminal_open = 0
    let l:window_number = winnr()
    let l:buffer_number = winbufnr(l:window_number)
    if has_key(g:vs_terminal_map, l:buffer_number)
        call remove(g:vs_terminal_map, l:buffer_number)
        if l:buffer_number == g:vs_terminal_current_number
            let g:vs_terminal_current_number = len(g:vs_terminal_map) > 0 ? keys(g:vs_terminal_map)[0] : 0
        endif
    endif

endfunction


function! VSTerminalRenderStatusline()
    set statusline=
    let l:count = len(g:vs_terminal_map)
    let l:keys = keys(g:vs_terminal_map)
    if l:count > 0
        if l:keys[0] == g:vs_terminal_current_number
            set statusline +=%1*\ 1\ %*
        else
            set statusline +=%2*\ 1\ %*
        endif
    endif
    if l:count > 1
        if l:keys[1] == g:vs_terminal_current_number
            set statusline +=%1*\ 2\ %*
        else
            set statusline +=%2*\ 2\ %*
        endif
    endif
    if l:count > 2
        if l:keys[2] == g:vs_terminal_current_number
            set statusline +=%1*\ 3\ %*
        else
            set statusline +=%2*\ 3\ %*
        endif
    endif
    if l:count > 3
        if l:keys[3] == g:vs_terminal_current_number
            set statusline +=%1*\ 4\ %*
        else
            set statusline +=%2*\ 4\ %*
        endif
    endif
    if l:count > 4
        if l:keys[4] == g:vs_terminal_current_number
            set statusline +=%1*\ 5\ %*
        else
            set statusline +=%2*\ 5\ %*
        endif
    endif
    if l:count > 5
        if l:keys[5] == g:vs_terminal_current_number
            set statusline +=%1*\ 6\ %*
        else
            set statusline +=%2*\ 6\ %*
        endif
    endif
    hi User1 cterm=bold ctermfg=169 ctermbg=238
    hi User2 cterm=none ctermfg=238 ctermbg=169
    hi StatuslineTerm ctermbg=236 ctermfg=236
    hi StatuslineTermNC ctermbg=236 ctermfg=236
endfunction


command! -nargs=0 -bar VSTerminalToggle :call VSTerminalToggle()
command! -nargs=1 -bar VSTerminalOpenWithIndex :call VSTerminalOpenWithIndex('<args>')


""""""""""""""""""""""""""" Compatible with old verion.""""""""""""""""""""""""""""
command! -nargs=0 -bar MXTerminalToggle :call VSTerminalToggle()
if !exists("g:mx_terminal_custom_pos")
  let g:vs_terminal_custom_pos = 'bottom'
endif

if !exists("g:mx_terminal_custom_height")
  let g:vs_terminal_custom_height = 10
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
