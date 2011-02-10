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


let g:savemap#version = str2nr(printf('%02d%02d%03d', 0, 1, 2))

function! savemap#load() "{{{
    " dummy function to load this script
endfunction "}}}

function! savemap#save_map(...) "{{{
    return call('s:save_map', [0] + a:000)
endfunction "}}}

function! savemap#save_abbr(...) "{{{
    return call('s:save_map', [1] + a:000)
endfunction "}}}

function! s:save_map(is_abbr, mode, ...) "{{{
    if !savemap#supported_version()
        return {}
    endif

    let map_dict = {
    \   '__is_abbr': a:is_abbr,
    \}
    if a:0
        let map_dict.restore = s:local_func('MapDict_restore_a_map')
        let map_dict.__map_info = maparg(a:1, a:mode, a:is_abbr, 1)
    else
        let map_dict.restore = s:local_func('MapDict_restore_mappings')
        let map_dict.__map_info = []
        for lhs in s:get_all_lhs(a:mode)
            call add(
            \   map_dict.__map_info,
            \   maparg(lhs, a:mode, a:is_abbr, 1)
            \)
        endfor
    endif

    return map_dict
endfunction "}}}

function s:SID() "{{{
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction "}}}
let s:SID_PREFIX = s:SID()
delfunc s:SID

function! s:local_func(name) "{{{
    return function('<SNR>' . s:SID_PREFIX . '_' . a:name)
endfunction "}}}

function! s:restore_map_info(map_info, is_abbr) "{{{
    for mode in s:each_modes(a:map_info.mode)
        execute
        \   mode . (a:map_info.noremap ? 'nore' : '')
        \       . (a:is_abbr ? 'abbr' : 'map')
        \   s:convert_options(a:map_info)
        \   a:map_info.lhs
        \   a:map_info.rhs
    endfor
endfunction "}}}

" MapDict {{{
function! s:MapDict_restore_a_map() dict "{{{
    call s:restore_map_info(self.__map_info, self.__is_abbr)
endfunction "}}}

function! s:MapDict_restore_mappings() dict "{{{
    for d in self.__map_info
        call s:restore_map_info(d, self.__is_abbr)
    endfor
endfunction "}}}
" }}}

function! savemap#supported_version() "{{{
    return v:version > 703 || v:version == 703 && has('patch32')
endfunction "}}}

function! s:get_all_lhs(mode, ...) "{{{
    redir => output
    silent execute a:mode.'map' join(a:000)
    redir END

    let pat = '^.\s\+\(\S\+\)'
    return filter(map(split(output, '\n'), 'matchstr(v:val, pat)'), 'empty(v:val)')
endfunction "}}}

function! s:each_modes(modes) "{{{
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

function! s:convert_options(maparg) "{{{
    return join(map(
    \   ['silent', 'expr', 'buffer'],
    \   'a:maparg[v:val] ? "<" . v:val . ">" : ""'
    \), '')
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
