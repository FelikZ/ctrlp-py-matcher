" Python Matcher

if !has('python') && !has('python3')
    echo 'In order to use pymatcher plugin, you need +python or +python3 compiled vim'
endif

let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

if has('python3')
  execute 'py3file ' . s:plugin_path . '/pymatcher.py'
else
  execute 'pyfile ' . s:plugin_path . '/pymatcher.py'
endif

function! pymatcher#PyMatch(items, str, limit, mmode, ispath, crfile, regex)

    call clearmatches()

    if a:str == ''
        let arr = a:items[0:a:limit]
        if pymatcher#ShouldHideCurrentFile(a:ispath, a:crfile)
            call remove(arr, index(arr, a:crfile))
        endif
        return arr
    endif

    let s:rez = []
    let s:regex = ''

    execute 'python' . (has('python3') ? '3' : '') . ' CtrlPPyMatch()'

    let s:matchregex = '\v\c'

    if a:mmode == 'filename-only'
        let s:matchregex .= '[\^\/]*'
    endif

    let s:matchregex .= s:regex

    call matchadd('CtrlPMatch', s:matchregex)

    return s:rez
endfunction

function! pymatcher#ShouldHideCurrentFile(ispath, crfile)
    return !get(g:, 'ctrlp_match_current_file', 0) && a:ispath && getftype(a:crfile) == 'file'
endfunction
