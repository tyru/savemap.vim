" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! s:run()
    if !savemap#supported_version()
        Skip "your Vim does not support maparg()'s 4th argument."
    endif

    nmapclear
    nmapclear <buffer>

    nmap foo dummy
    nmap bar dummy
    nmap baz dummy

    let mappings = savemap#save_map('n')

    nmapclear
    nmapclear <buffer>

    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    Is maparg('bar', 'n', 0), '', 'bar does not exist'
    Is maparg('baz', 'n', 0), '', 'baz does not exist'
    call mappings.restore()
    Is maparg('foo', 'n', 0), 'dummy', 'foo does exist'
    Is maparg('bar', 'n', 0), 'dummy', 'bar does exist'
    Is maparg('baz', 'n', 0), 'dummy', 'baz does exist'
endfunction

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
