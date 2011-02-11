" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! s:is_buffer(lhs, name)
    return s:check_buffer(a:lhs, a:name, 1)
endfunction
function! s:is_not_buffer(lhs, name)
    return s:check_buffer(a:lhs, a:name, 0)
endfunction
function! s:check_buffer(lhs, name, is_buffer)
    let m = maparg(a:lhs, 'n', 0, 1)
    let has_buffer = has_key(m, 'buffer')
    Ok has_buffer, a:name . " - " . a:lhs . " has key 'buffer'."
    if !has_buffer
        return
    endif
    Ok (a:is_buffer ? m.buffer : !m.buffer), a:name . " - '" . a:lhs . "' " . (a:is_buffer ? "is" : "is not") . " <buffer>."
endfunction

function! s:run()
    if !savemap#supported_version()
        Skip "your Vim does not support maparg()'s 4th argument."
    endif

    nmapclear
    nmapclear <buffer>

    nnoremap          normal dummy
    nnoremap <buffer> buffer dummy
    nnoremap          both dummy
    nnoremap <buffer> both dummy

    let normal = savemap#save_map('n', 'normal')
    let buffer = savemap#save_map('n', 'buffer')
    let both   = savemap#save_map('n', 'both')

    nmapclear
    nmapclear <buffer>


    Diag '--- normal ---'
    call normal.restore()
    Is maparg('normal', 'n', 0), 'dummy', 'normal'
    call s:is_not_buffer('normal', 'normal')

    Diag '--- buffer ---'
    call buffer.restore()
    Is maparg('buffer', 'n', 0), 'dummy', 'buffer'
    Is get(maparg('buffer', 'n', 0, 1), 'buffer', -1), 1, 'buffer'
    call s:is_buffer('buffer', 'buffer')

    Diag '--- both ---'
    call both.restore()
    Is maparg('both', 'n', 0), 'dummy', 'both'
    call s:is_buffer('both', 'both')
    nunmap <buffer> both
    call s:is_not_buffer('both', 'both')
endfunction

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
