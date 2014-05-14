" Python Matcher

if !has('python')
    echo 'In order to use pymatcher plugin, you need +python compiled vim'
endif

function! pymatcher#PyMatch(items, str, limit, mmode, ispath, crfile, regex)

    call clearmatches()

    let s:rez = []
    let s:regex = ''

    if a:str != ''

python << EOF
import vim, re
from datetime import datetime

items = vim.eval('a:items')
astr = vim.eval('a:str')
lowAstr = astr.lower()
limit = int(vim.eval('a:limit'))
mmode = vim.eval('a:mmode')
aregex = int(vim.eval('a:regex'))

rez = vim.bindeval('s:rez')

regex = ''
if aregex == 1:
    regex = astr
else:
    for c in lowAstr[:-1]:
        regex += c + '[^' + c + ']*'
    else:
        regex += lowAstr[-1]

res = []
prog = re.compile(regex)

if mmode == 'filename-only':
    for line in items:
        lineLower = line

        # get filename via reverse find to improve performance
        slashPos = lineLower.rfind('/')
        if slashPos != -1:
            lineLower = lineLower[slashPos + 1:]

        lineLower = lineLower.lower()
        result = prog.search(lineLower)
        if result:
            scores = []
            scores.append((1 + result.start()) * (result.end() - result.start() + 1))
            scores.append(( len(lineLower) + 1 ) / 100.0)
            scores.append(( len(line) + 1 ) / 1000.0)
            score = 1000.0 / sum(scores)
            res.append((score, line))
else:
    for line in items:
        lineLower = line.lower()
        result = prog.search(lineLower)
        if result:
            scores = []
            scores.append(result.end() - result.start() + 1)
            scores.append(( len(lineLower) + 1 ) / 100.0)
            score = 1000.0 / sum(scores)
            res.append((score, line))

sortedlist = sorted(res, key=lambda x: x[0], reverse=True)[:limit]
sortedlist = [x[1] for x in sortedlist]

rez.extend(sortedlist)

vim.command("let s:regex = '%s'" % regex)
EOF

        let s:matchregex = '\v\c'

        if a:mmode == 'filename-only'
            let s:matchregex .= '[\^\/]*'
        endif

        let s:matchregex .= s:regex

        call matchadd('CtrlPMatch', s:matchregex)
    else
        let s:rez = a:items[0:a:limit]
    endif

    return s:rez
endfunction
