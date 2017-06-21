import re
import vim
import heapq

_escape = dict((c, "\\" + c) for c in [
    '^', '$', '.', '{', '}', '(', ')', '[', ']', '\\', '/', '+'])


def CtrlPPyMatch():
    try:
        _doCtrlPPyMatch()
    except Exception as ex:
        import traceback
        tb = traceback.format_exc()
        vim.command(
            'let s:rez = ["Unknown error in matcher", "%s", "%s"]' %
            (str(ex), tb))


def _doCtrlPPyMatch():
    try:
        items = vim.eval('a:items')
    except UnicodeDecodeError:
        _troubleshootUnicodeInputError()
        return

    astr = vim.eval('a:str')
    lowAstr = astr.lower()
    limit = int(vim.eval('a:limit'))
    mmode = vim.eval('a:mmode')
    aregex = int(vim.eval('a:regex'))
    ispath = vim.eval('a:ispath')
    crfile = vim.eval('a:crfile')

    if (not vim.eval('exists("g:ctrlp_match_current_file")') and
            ispath and crfile):
        items.remove(crfile)

    rez = vim.eval('s:rez')
    sep = vim.eval('s:slashsep')

    regex = ''
    if aregex == 1:
        regex = astr
    else:
        # Escape all of the characters as necessary
        escaped = [_escape.get(c, c) for c in lowAstr]

        # If the string is longer that one character, append a mismatch
        # expression to each character (except the last).
        if len(lowAstr) > 1:
            mismatch = ["[^" + c + "]*" for c in escaped[:-1]]
            regex = ''.join([c for pair in zip(escaped[:-1], mismatch)
                             for c in pair])

        # Append the last character in the string to the regex
        regex += escaped[-1]
    # because this IGNORECASE flag is extremely expensive we are converting
    # everything to lower case
    # see https://github.com/FelikZ/ctrlp-py-matcher/issues/29
    regex = regex.lower()

    res = []
    prog = re.compile(regex)

    def filename_score(line):
        # get filename via reverse find to improve performance
        slashPos = line.rfind(sep)

        if slashPos != -1:
            line = line[slashPos + 1:]

        lineLower = line.lower()
        result = prog.search(lineLower)
        if result:
            score = result.end() - result.start() + 1
            score = score + (len(lineLower) + 1) / 100.0
            score = score + (len(line) + 1) / 1000.0
            return 1000.0 / score

        return 0

    def path_score(line):
        lineLower = line.lower()
        result = prog.search(lineLower)
        if result:
            score = result.end() - result.start() + 1
            score = score + (len(lineLower) + 1) / 100.0
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

    rez.extend([line for score, line in heapq.nlargest(limit, res)
                if score != 0])

    # Use double quoted vim strings and escape \
    vimrez = ['"' + line.replace('\\', '\\\\').replace('"', '\\"') + '"'
              for line in rez]

    vim.command("let s:regex = '%s'" % regex)
    vim.command('let s:rez = [%s]' % ','.join(vimrez))


def _troubleshootUnicodeInputError():
    count = vim.eval('len(a:items)')
    for i in range(int(count)):
        try:
            vim.eval('a:items[%d]' % i)
        except:
            vim.command(
                'let s:rez = ["Unicode error at item %d: ".a:items[%d],'
                '"Line contains invalid characters."]' %
                (i, i))
            break
