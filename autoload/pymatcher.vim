" Python Matcher

if !has('python') && !has('python3')
    echo 'In order to use pymatcher plugin, you need +python or +python3 compiled vim'
endif

function! pymatcher#PyMatch(items, str, limit, mmode, ispath, crfile, regex)

    call clearmatches()
    
    if a:str == ''
        return a:items[0:a:limit]
    endif

    let s:rez = []
    let s:regex = ''

exec (has('python') ? ':py' : ':py3') ' << EOF'
import vim, re
from datetime import datetime

items = vim.eval('a:items')
astr = vim.eval('a:str')
lowAstr = astr.lower()
limit = int(vim.eval('a:limit'))
mmode = vim.eval('a:mmode')
aregex = int(vim.eval('a:regex'))

rez = vim.bindeval('s:rez')

specialChars = ['^','$','.','{','}','(',')','[',']','\\','/','+']

regex = ''
if aregex == 1:
    regex = astr
else:
    if len(lowAstr) == 1:
        c = lowAstr
        if c in specialChars:
            c = '\\' + c
        regex += c
    else:
        for c in lowAstr[:-1]:
            if c in specialChars:
                c = '\\' + c
            regex += c + '[^' + c + ']*'
        else:
            c = lowAstr[-1]
            if c in specialChars:
                c = '\\' + c
            regex += c

res = []
prog = re.compile(regex)

def filename_score(line):
    # get filename via reverse find to improve performance
    slashPos = line.rfind('/')
    line = line if slashPos == -1 else line[slashPos + 1:]

    lineLower = line.lower()
    result = prog.search(lineLower)
    if result:
        score = result.end() - result.start() + 1
        score = score + ( len(lineLower) + 1 ) / 100.0
        score = score + ( len(line) + 1 ) / 1000.0
        return 1000.0 / score

    return 0


if mmode == 'filename-only':
    res = [(filename_score(line), line) for line in items]
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

    return s:rez
endfunction
