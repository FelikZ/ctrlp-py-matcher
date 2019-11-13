import vim
import re
import heapq
from multiprocessing import Pool
import os

_escape = dict((c , "\\" + c) for c in ['^','$','.','{','}','(',')','[',']','\\','/','+'])

class FilenameScore:
    def __init__(self, prog):
        self.prog = prog

    def __call_(self, line):
        # get filename via reverse find to improve performance
        slashPos = line.rfind('/')

        if slashPos != -1:
            line = line[slashPos + 1:]

        lineLower = line.casefold()
        result = self.prog.search(lineLower)
        if result:
            score = result.end() - result.start() + 1
            score = score + ( len(lineLower) + 1 ) / 100.0
            score = score + ( len(line) + 1 ) / 1000.0
            return (1000.0 / score, line)

        return (0, line)

class PathScore:
    def __init__(self, prog, first_non_tab=False, until_last_tab=False):
        self.prog = prog
        self.first_non_tab = first_non_tab
        self.until_last_tab = until_last_tab

    def __call__(self, line):
        lineLower = line.casefold()
        if self.first_non_tab:
            lineLower = lineLower.split('\t')[0]
        if self.until_last_tab:
            lineLower = lineLower.rsplit('\t')[0]
        result = self.prog.search(lineLower)
        if result:
            score = result.end() - result.start() + 1
            score = score + ( len(lineLower) + 1 ) / 100.0
            return (1000.0 / score, line)

        return (0, line)

class VimList:
    def __init__(self, name):
        self.name = name
        self.len = int(vim.eval('len({})'.format(self.name)))

    def __len__(self):
        return self.len

    def __getitem__(self, index):
        return vim.eval('{}[{}]'.format(self.name, index))

    def __iter__(self):
        for i in range(self.len):
            yield self[i]


def CtrlPPyMatch():
    items = VimList('a:items')
    astr = vim.eval('a:str')
    lowAstr = astr.casefold()
    limit = int(vim.eval('a:limit'))
    mmode = vim.eval('a:mmode')
    aregex = int(vim.eval('a:regex'))
    crfile = vim.eval('a:crfile')

    rez = vim.eval('s:rez')

    pool = Pool(max(1, os.cpu_count()-1))
    chunksize = 4096

    regex = ''
    if aregex == 1:
        regex = astr
    else:
        # Escape all of the characters as necessary
        escaped = [_escape.get(c, c) for c in lowAstr]

        # If the string is longer that one character, append a mismatch
        # expression to each character (except the last).
        if len(lowAstr) > 1:
            regex = ''.join([c + "[^" + c + "]*" for c in escaped[:-1]])

        # Append the last character in the string to the regex
        regex += escaped[-1]
    # because this IGNORECASE flag is extremely expensive we are converting everything to lower case
    # see https://github.com/FelikZ/ctrlp-py-matcher/issues/29
    regex = regex.casefold()

    res = []
    prog = re.compile(regex)

    if mmode == 'filename-only':
        filename_score = FilenameScore(prog)
        res = pool.imap_unordered(filename_score, items, chunksize)

    elif mmode == 'first-non-tab':
        path_score = PathScore(prog, first_non_tab=True)
        res = pool.imap_unordered(path_score, items, chunksize)

    elif mmode == 'until-last-tab':
        path_score = PathScore(prog, until_last_tab=True)
        res = pool.imap_unordered(path_score, items, chunksize)

    else:
        path_score = PathScore(prog)
        res = pool.imap_unordered(path_score, items, chunksize)

    pool.close()

    rez.extend((line for score, line in heapq.nlargest(limit, res) if score != 0))

    if int(vim.eval("pymatcher#ShouldHideCurrentFile(a:ispath, a:crfile)")) and crfile in rez:
        rez.remove(crfile)

    # Use double quoted vim strings and escape \
    vimrez = ('"' + line.replace('\\', '\\\\').replace('"', '\\"') + '"' for line in rez)

    vim.command("let s:regex = '%s'" % regex)
    vim.command('let s:rez = [%s]' % ','.join(vimrez))
