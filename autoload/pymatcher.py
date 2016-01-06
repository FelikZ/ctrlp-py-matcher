import vim, re
import heapq
from datetime import datetime

def CtrlPPyMatch():
    items = vim.eval('a:items')
    astr = vim.eval('a:str')
    lowAstr = astr.lower()
    limit = int(vim.eval('a:limit'))
    mmode = vim.eval('a:mmode')
    aregex = int(vim.eval('a:regex'))

    rez = vim.eval('s:rez')

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

        if slashPos != -1:
            line = line[slashPos + 1:]

        lineLower = line.lower()
        result = prog.search(lineLower)
        if result:
            score = result.end() - result.start() + 1
            score = score + ( len(lineLower) + 1 ) / 100.0
            score = score + ( len(line) + 1 ) / 1000.0
            return 1000.0 / score

        return 0

    def path_score(line):
        lineLower = line.lower()
        result = prog.search(lineLower)
        if result:
            score = result.end() - result.start() + 1
            score = score + ( len(lineLower) + 1 ) / 100.0
            return 1000.0 / score

        return 0

    if mmode == 'filename-only':
        res = [(filename_score(line), line) for line in items]

    elif mmode == 'first-non-tab':
        res = [(path_score(line.split('\t')[0]), line) for line in items]

    elif mmode == 'until-last-tab':
        res = [(path_score(line.rsplit('\t')[0]), line) for line in items]

    else:
        res = [(path_score(line), line) for line in items]

    #rez.extend([line for score, line in heapq.nlargest(limit, res)])
    for score, line in heapq.nlargest(limit, res):
        if score != 0:
            rez.extend([line])

    # Use double quoted vim strings and escape \
    vimrez = ['"' + line.replace('\\', '\\\\').replace('"', '\\"') + '"' for line in rez]

    vim.command("let s:regex = '%s'" % regex)
    vim.command('let s:rez = [%s]' % ','.join(vimrez))

