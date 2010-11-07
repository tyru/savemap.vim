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


function! savemap#save_map(mode, ...) "{{{
    return call('s:save_map', [a:mode, 0] + a:000)
endfunction "}}}

function! savemap#save_abbr(mode, ...) "{{{
    return call('s:save_map', [a:mode, 1] + a:000)
endfunction "}}}

function! s:save_map(mode, is_abbr, ...) "{{{
    if !savemap#supported_version()
        return {}
    endif

    if a:0
        let map_dict = maparg(a:1, a:mode, a:is_abbr, 1)
        if empty(map_dict)
            return {}
        endif

        let o = {'__map_dict': map_dict, '__is_abbr': a:is_abbr}
        function o.restore()
            let o = self.__map_dict
            for mode in s:each_modes(o.mode)
                execute
                \   mode . (o.noremap ? 'nore' : '')
                \       . (self.__is_abbr ? 'abbr' : 'map')
                \   s:convert_options(o)
                \   o.lhs
                \   o.rhs
            endfor
        endfunction
        return o
    else
        return map(s:get_all_lhs(a:mode), 'savemap#save_map(a:mode, v:val)')
    endif
endfunction "}}}

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

function! s:convert_options(map_dict) "{{{
    return join(map(
    \   ['silent', 'expr', 'buffer'],
    \   'a:map_dict[v:val] ? "<" . v:val . ">" : ""'
    \), '')
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
