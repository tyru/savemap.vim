" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! s:run()
    if !savemap#supported_version()
        return
    endif

    nmap foo blahblahblah
    let foo_nmap = savemap#save_map('n', 'foo')
    nmap foo bar
    Is maparg('foo', 'n'), 'bar', "nmap: foo's rhs is bar"
    call foo_nmap.restore()
    Is maparg('foo', 'n'), 'blahblahblah', "nmap: foo's rhs is blahblahblah"

    iab foo blahblahblah
    let foo_iab = savemap#save_abbr('i', 'foo')
    iab foo bar
    Is maparg('foo', 'i', 1), 'bar', "iab: foo's rhs is bar"
    call foo_iab.restore()
    Is maparg('foo', 'i', 1), 'blahblahblah', "iab: foo's rhs is blahblahblah"

    cab foo blahblahblah
    let foo_cab = savemap#save_abbr('c', 'foo')
    cab foo bar
    Is maparg('foo', 'c', 1), 'bar', "cab: foo's rhs is bar"
    call foo_cab.restore()
    Is maparg('foo', 'c', 1), 'blahblahblah', "cab: foo's rhs is blahblahblah"
endfunction

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
