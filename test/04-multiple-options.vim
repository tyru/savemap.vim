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

    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>

    nmap foo dummy
    nmap bar dummy
    vmap baz dummy
    vmap hoge fuga

    let foo_baz = savemap#save_map({'mode': 'n', 'lhs': 'foo'}, {'mode': 'v', 'lhs': 'baz'})
    let bar_hoge = savemap#save_map({'mode': 'n', 'lhs': 'bar'}, {'mode': 'v', 'lhs': 'hoge'})


    " foo_baz
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>

    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    Is maparg('bar', 'n', 0), '', 'bar does not exist'
    Is maparg('baz', 'v', 0), '', 'baz does not exist'
    Is maparg('hoge', 'v', 0), '', 'hoge does not exist'
    call foo_baz.restore()
    Is maparg('foo', 'n', 0), 'dummy', 'foo does exist'
    Is maparg('bar', 'n', 0), '', 'bar does not exist'
    Is maparg('baz', 'v', 0), 'dummy', 'baz does exist'
    Is maparg('hoge', 'v', 0), '', 'hoge does not exist'


    " bar_hoge
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>

    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    Is maparg('bar', 'n', 0), '', 'bar does not exist'
    Is maparg('baz', 'v', 0), '', 'baz does not exist'
    Is maparg('hoge', 'v', 0), '', 'hoge does not exist'
    call bar_hoge.restore()
    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    Is maparg('bar', 'n', 0), 'dummy', 'bar does exist'
    Is maparg('baz', 'v', 0), '', 'baz does not exist'
    Is maparg('hoge', 'v', 0), 'fuga', 'hoge does exist'
endfunction

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
