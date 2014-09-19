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
import heapq
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
            regex += c + '[^' + c + ']*?'
        else:
            c = lowAstr[-1]
            if c in specialChars:
                c = '\\' + c
            regex += c
        regex = '(?=(' + regex + '))'

res = []
prog = re.compile(regex)

def filename_score(line):
    line = line[line.rfind('/') + 1:].lower()
    results = [1.0 / len(result.group(1)) for result in prog.finditer(line) if result]

    return max(results) if results else 0


def path_score(line):
    line = line.lower()
    results = [1.0 / len(result.group(1)) for result in prog.finditer(line) if result]

    return max(results) if results else 0


if mmode == 'filename-only':
    res = [(filename_score(line), line) for line in items]
else:
    res = [(path_score(line), line) for line in items]

rez.extend([line for score, line in heapq.nlargest(limit, res)])

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
