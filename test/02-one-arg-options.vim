" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! s:dump_mappings(mode) "{{{
    redir => output
    silent execute a:mode . 'map'
    redir END
    for l in split(output, '\n')
        Diag l
    endfor
endfunction "}}}

function! s:run()
    if !savemap#supported_version()
        return
    endif

    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>

    nmap          foo dummy
    nmap          dup dummy
    nmap <buffer> dup dummy
    nmap <buffer> bar dummy
    vmap          visual dummy

    let normal_mappings = savemap#save_map({'mode': 'n'})
    let dup = savemap#save_map({'mode': 'n', 'lhs': 'dup'})
    let dup_buffer = savemap#save_map({'mode': 'n', 'lhs': 'dup', 'buffer': 1})
    let dup_non_buffer = savemap#save_map({'mode': 'n', 'lhs': 'dup', 'buffer': 0})
    let visual_mappings = savemap#save_map({'mode': 'v'})

    IsDeeply savemap#save_map({'mode': 'v', 'lhs-regexp': '^vi'}), visual_mappings

    let all   = savemap#save_map({'mode': 'nv'})
    let dummy = savemap#save_map({'mode': 'nv', 'rhs-regexp': '^dummy$'})
    IsDeeply all, dummy
    unlet all dummy

    " dup
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>
    Is maparg('dup', 'n', 0), '', 'dup does not exist'
    call dup.restore()
    Is maparg('dup', 'n', 0), 'dummy', 'dup does exist'
    Is get(maparg('dup', 'n', 0, 1), 'buffer', -1), 1, 'dup is <buffer>'
    try
        nunmap <buffer> dup
        Ok 1, "can remove the <buffer> mapping 'dup'"
    catch
        Ok 0, "can remove the <buffer> mapping 'dup'"
    endtry
    Is get(maparg('dup', 'n', 0, 1), 'buffer', -1), 0, 'dup is not <buffer> but exists'

    " dup_buffer
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>
    Is maparg('dup', 'n', 0), '', 'dup does not exist'
    call dup_buffer.restore()
    Is maparg('dup', 'n', 0), 'dummy', 'dup does exist'
    Is get(maparg('dup', 'n', 0, 1), 'buffer', -1), 1, 'dup is <buffer>'
    try
        nunmap <buffer> dup
        Ok 1, "can remove the <buffer> mapping 'dup'"
    catch
        Ok 0, "can remove the <buffer> mapping 'dup'"
    endtry
    Is maparg('dup', 'n', 0), '', 'dup does not exist'

    " dup_non_buffer
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>
    Is maparg('dup', 'n', 0), '', 'dup does not exist'
    call dup_non_buffer.restore()
    Is maparg('dup', 'n', 0), 'dummy', 'dup does exist'
    Is get(maparg('dup', 'n', 0, 1), 'buffer', -1), 0, 'dup is not <buffer>'
    try
        nunmap dup
        Ok 1, "can remove the <buffer> mapping 'dup'"
    catch
        Ok 0, "can remove the <buffer> mapping 'dup'"
    endtry
    Is maparg('dup', 'n', 0), '', 'dup does not exist'

    " normal_mappings
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>
    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    Is maparg('bar', 'n', 0), '', 'bar does exist'
    call normal_mappings.restore()
    Is maparg('foo', 'n', 0), 'dummy', 'foo does exist'
    Is maparg('bar', 'n', 0), 'dummy', 'bar does exist'
    Is maparg('visual', 'v', 0), '', 'visual does not exist'

    " visual_mappings
    nmapclear
    nmapclear <buffer>
    vmapclear
    vmapclear <buffer>
    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    call visual_mappings.restore()
    Is maparg('foo', 'n', 0), '', 'foo does not exist'
    Is maparg('bar', 'n', 0), '', 'bar does not exist'
    Is maparg('visual', 'v', 0), 'dummy', 'visual does exist'
endfunction

call s:run()
Done


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
