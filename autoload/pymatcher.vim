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
import os
import vim, re
import heapq

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
    escaped = [re.escape(c) for c in lowAstr]
    regex = '(?=(' + ''.join([c + '[^' + c + ']*?' for c in escaped]) + '))'

prog = re.compile(regex)

# strip the rest of the path if only interested in the filename
if mmode == 'filename-only':
  items = [os.path.basename(line) for line in items]

# set the strings to lowercase
item = [line.lower() for line in items]

def score(line):
    results = [1.0 / len(result.group(1)) for result in prog.finditer(line) if result]
    return max(results) if results else 0

# determine the score for each item
results = [(score(line), line) for line in items]

# return the best results
rez.extend(line for _, line in heapq.nlargest(limit, results))

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
