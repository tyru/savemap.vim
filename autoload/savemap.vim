" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_savemap') && g:loaded_savemap
    finish
endif
let g:loaded_savemap = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let g:savemap#version = str2nr(printf('%02d%02d%03d', 0, 1, 5))

" Interface {{{

function! savemap#load() "{{{
    " dummy function to load this script
endfunction "}}}

function! savemap#save_map(...) "{{{
    return call('s:save_map', [0] + a:000)
endfunction "}}}

function! savemap#save_abbr(...) "{{{
    return call('s:save_map', [1] + a:000)
endfunction "}}}

function! savemap#supported_version() "{{{
    return v:version > 703 || v:version == 703 && has('patch32')
endfunction "}}}

" }}}

" Implementation {{{

function s:SID() "{{{
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction "}}}
let s:SID_PREFIX = s:SID()
delfunc s:SID

function! s:local_func(name) "{{{
    return function('<SNR>' . s:SID_PREFIX . '_' . a:name)
endfunction "}}}



function! s:save_map(is_abbr, arg, ...) "{{{
    if !savemap#supported_version()
        return {}
    endif

    let map_dict = {
    \   '__is_abbr': a:is_abbr,
    \   'restore': s:local_func('MapDict_restore_mappings'),
    \   '__map_info': [],
    \}
    if a:0 == 0 && type(a:arg) == type({})
        " {options}
        let options = a:arg
        " TODO
    elseif type(a:arg) == type("")
    \   && a:0 == 1
    \   && type(a:1) == type("")
        " {mode}, {lhs}
        let [mode, lhs] = [a:arg, a:1]
        call add(
        \   map_dict.__map_info,
        \   s:get_map_info(mode, lhs, a:is_abbr)
        \)
    elseif type(a:arg) == type("")
    \   && a:0 == 0
        " {mode}
        let mode = a:arg
        for lhs in s:get_all_lhs(mode, a:is_abbr)
            call add(
            \   map_dict.__map_info,
            \   s:get_map_info(mode, lhs, a:is_abbr)
            \)
        endfor
    else
        echoerr 'invalid argument.'
        return {}
    endif

    return map_dict
endfunction "}}}

function! s:MapDict_restore_mappings() dict "{{{
    for d in self.__map_info
        call s:restore_map_info(d.normal, self.__is_abbr)
        call s:restore_map_info(d.buffer, self.__is_abbr)
    endfor
endfunction "}}}

function! s:get_all_lhs(mode, is_abbr) "{{{
    redir => output
    silent execute a:mode . (a:is_abbr ? 'abbr' : 'map')
    redir END

    let pat = '^.\s\+\zs\S\+'
    return filter(map(split(output, '\n'), 'matchstr(v:val, pat)'), 'v:val != ""')
endfunction "}}}

function! s:get_map_info(mode, lhs, is_abbr) "{{{
    let r = {
    \   'buffer': {},
    \   'normal': {},
    \}

    let info = maparg(a:lhs, a:mode, a:is_abbr, 1)
    if empty(info)
        " No such a mapping for a:lhs
    elseif info.buffer
        " <buffer>
        let r.buffer = info
        " Also save a non-<buffer> mapping if it exists.
        call s:do_unmap_silently(a:mode, a:lhs, a:is_abbr, 1)
        let r.normal = maparg(a:lhs, a:mode, a:is_abbr, 1)
        call s:restore_map_info(r.buffer, a:is_abbr)
    else
        " non-<buffer>
        let r.normal = info
    endif

    return r
endfunction "}}}

function! s:do_unmap_silently(mode, lhs, is_abbr, is_buffer) "{{{
    if a:mode == '' || a:lhs == ''
        return
    endif
    " Even if no such a mapping for a:lhs,
    " this does not raise an error.
    silent! execute
    \   a:mode . (a:is_abbr ? 'unabbr' : 'unmap')
    \   (a:is_buffer ? '<buffer>' : '')
    \   a:lhs
endfunction "}}}

function! s:restore_map_info(map_info, is_abbr) "{{{
    if empty(a:map_info)
        return
    endif
    for mode in s:split_maparg_modes(a:map_info.mode)
        execute
        \   mode . (a:map_info.noremap ? 'nore' : '')
        \       . (a:is_abbr ? 'abbr' : 'map')
        \   s:convert_maparg_options(a:map_info)
        \   a:map_info.lhs
        \   a:map_info.rhs
    endfor
endfunction "}}}

function! s:convert_maparg_options(maparg) "{{{
    return join(map(
    \   ['silent', 'expr', 'buffer'],
    \   'a:maparg[v:val] ? "<" . v:val . ">" : ""'
    \), '')
endfunction "}}}

function! s:split_maparg_modes(modes) "{{{
    let h = {}
    for _ in split(a:modes, '\zs')
        if _ ==# ' '
            let h['n'] = 1
            let h['v'] = 1
            let h['o'] = 1
        elseif _ ==# '!'
            let h['i'] = 1
            let h['c'] = 1
        else
            let h[_] = 1
        endif
    endfor
    return keys(h)
endfunction "}}}

" }}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
