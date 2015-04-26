ctrlp-py-matcher
================

Fast CtrlP matcher based on python

Performance difference is up to x22, look those profiling log:

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

To achive this results try to do **long** (5-10+ sym) text queries on a large amount of files (1kk+).

To install this plugin you **need** Vim compiled with `+python` flag:
```
vim --version | grep python
```

This plugin should be compatible with vim **7.x** and [NeoVIM](http://neovim.io) as well.

**If you still have performance issues, it can be caused by [bufferline](https://github.com/bling/vim-bufferline) or another one plugin. So if it caused by bufferline you can switch to [airline](https://github.com/bling/vim-airline) and setup this option:**
```
let g:airline#extensions#tabline#enabled = 1
```

Full documentation is available [here](https://github.com/FelikZ/ctrlp-py-matcher/blob/master/doc/pymatcher.txt)

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/c38f2a3d6d6ba9a3e67be921ee2f68f0 "githalytics.com")](http://githalytics.com/FelikZ/ctrlp-py-matcher)
