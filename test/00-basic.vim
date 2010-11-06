" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! s:run()
    nmap foo blahblahblah

    let foo_nmap = tempmap#save_map('n', 'foo')
    if empty(foo_nmap)
        echoerr 'your vim version is lower than 7.3.032!'
    endif

    nmap foo bar

    call foo_nmap.restore()

    Is maparg('foo', 'n'), 'blahblahblah', "foo's rhs is blahblahblah"
endfunction

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
