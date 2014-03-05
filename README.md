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

Full documentation is available [here](https://github.com/FelikZ/ctrlp-py-matcher/blob/master/doc/pymatcher.txt)
