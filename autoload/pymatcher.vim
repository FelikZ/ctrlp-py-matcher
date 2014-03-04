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

rez = vim.bindeval('s:rez')

regex = ''
for c in lowAstr[:-1]:
    regex += c + '[^' + c + ']*'
else:
    regex += lowAstr[-1]

res = []
prog = re.compile(regex)

for line in items:
    result = prog.search(line.lower())
    if result:
        score = 1000.0 / ((1 + result.start()) * (result.end() - result.start() + 1))
        res.append((score, line))

sortedlist = sorted(res, key=lambda x: x[0], reverse=True)[:limit]
sortedlist = [x[1] for x in sortedlist]

rez.extend(sortedlist)

vim.command("let s:regex = '%s'" % regex)
EOF

        call matchadd('CtrlPMatch', '\v\c'.s:regex)
        call matchadd('CtrlPLinePre', '^>')
    else
        let s:rez = a:items[0:a:limit]
    endif

    return s:rez
endfunction
