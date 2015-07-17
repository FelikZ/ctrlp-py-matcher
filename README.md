ctrlp-py-matcher
================

Fast CtrlP matcher based on python

Performance difference is up to x22, look at this perf:

Default matcher:
```
FUNCTIONS SORTED ON SELF TIME
count  total (s)   self (s)  function
    3  17.768008  17.610161  <SNR>102_MatchIt()
```

With Py Matcher:
```
FUNCTIONS SORTED ON SELF TIME
count  total (s)   self (s)  function
    3              0.730215  pymatcher#PyMatch()
```

To achive such results try to do **long** (5-10+ sym) text queries on a large amount of files (1kk+).

To install this plugin you **need** Vim compiled with `+python` flag:
```
vim --version | grep python
```

This plugin should be compatible with vim **7.x** and [NeoVIM](http://neovim.io) as well.

**If you still have performance issues, it can be caused by [bufferline](https://github.com/bling/vim-bufferline) or alike plugins. So if, for example, it caused by bufferline you can switch to [airline](https://github.com/bling/vim-airline) and setup this option:**
```
let g:airline#extensions#tabline#enabled = 1
```

Installation
------------
### Pathogen (https://github.com/tpope/vim-pathogen)
```
git clone https://github.com/FelikZ/ctrlp-py-matcher ~/.vim/bundle/ctrlp-py-matcher
```

### Vundle (https://github.com/gmarik/vundle)
```
Plugin 'FelikZ/ctrlp-py-matcher'
```

### NeoBundle (https://github.com/Shougo/neobundle.vim)
```
NeoBundle 'FelikZ/ctrlp-py-matcher'
```

### ~/.vimrc setup

    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

Full documentation is available [here](https://github.com/FelikZ/ctrlp-py-matcher/blob/master/doc/pymatcher.txt)

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/c38f2a3d6d6ba9a3e67be921ee2f68f0 "githalytics.com")](http://githalytics.com/FelikZ/ctrlp-py-matcher)
