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

function! pymatcher#highlight(grp,pat,ispath,regexp,byfname,martcs) abort
	if !empty(a:pat) && a:ispath
		if a:regexp
			let pat = substitute(a:pat, '\\\@<!\^', '^> \\zs', 'g')
			cal matchadd(a:grp, ( a:martcs == '' ? '\c' : '\C' ).pat)
		el
			let pat = a:pat

			" get original characters so we can rebuild pat
            let chars = split(pat, '\[\^\\\?.\]\\{-}')

			" Build a pattern like /a.*b.*c/ from abc (but with .\{-} non-greedy
			" matchers instead)
			let pat = join(chars, '.\{-}')
			" Ensure we match the last version of our pattern
			let ending = '\(.*'.pat.'\)\@!'
			" Case sensitive?
			let beginning = ( a:martcs == '' ? '\c' : '\C' ).'^.*'
			if a:byfname
				" Make sure there are no slashes in our match
				let beginning = beginning.'\([^\/]*$\)\@='
			en

			for i in range(len(chars))
				" Surround our current target letter with \zs and \ze so it only
				" actually matches that one letter, but has all preceding and trailing
				" letters as well.
				" \zsa.*b.*c
				" a\(\zsb\|.*\zsb)\ze.*c
				let charcopy = copy(chars)
				if i == 0
					let charcopy[i] = '\zs'.charcopy[i].'\ze'
					let middle = join(charcopy, '.\{-}')
				el
					let before = join(charcopy[0:i-1], '.\{-}')
					let after = join(charcopy[i+1:-1], '.\{-}')
					let c = charcopy[i]
					" for abc, match either ab.\{-}c or a.*b.\{-}c in that order
					let cpat = '\(\zs'.c.'\|'.'.*\zs'.c.'\)\ze.*'
					let middle = before.cpat.after
				en

				" Now we matchadd for each letter, the basic form being:
				" ^.*\zsx\ze.*$, but with our pattern we built above for the letter,
				" and a negative lookahead ensuring that we only highlight the last
				" occurrence of our letters. We also ensure that our matcher is case
				" insensitive or sensitive depending.
				cal matchadd(a:grp, beginning.middle.ending)
			endfo
		en

	elseif !empty(a:pat) && a:regexp &&
				\ exists('g:ctrlp_regex_always_higlight') &&
				\ g:ctrlp_regex_always_higlight
		let pat = substitute(a:pat, '\\\@<!\^', '^> \\zs', 'g')
		cal matchadd(a:grp, ( a:martcs == '' ? '\c' : '\C').pat)
    endif
endfunction

function! pymatcher#PyMatch(items, str, limit, mmode, ispath, crfile, regex) abort

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

    let byfname = 0
    if a:mmode == 'filename-only'
        let byfname = 1
    endif

    call pymatcher#highlight('CtrlPMatch',s:regex,a:ispath,a:regex,byfname,'')

    return s:rez
endfunction

function! pymatcher#ShouldHideCurrentFile(ispath, crfile)
    return !get(g:, 'ctrlp_match_current_file', 0) && a:ispath && getftype(a:crfile) == 'file'
endfunction
