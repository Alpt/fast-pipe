Usage
=====

`g:RegExp1 arg1 arg2` ... is the same of `grep -e RegExp1 -e RegExp2 ... arg1 arg2 ....`.  
The semicolon character : can actually be any non-word character, so `g% g@ g,` are all valid alternatives to `g:`. Only, `g/` is not valid, because bash treats / specially.  
For example, `g%:[0-1]: -C 2 g%$USER /etc/passwd -n /etc/group` is the same of `grep -e :[0-1]: -C 2 -e $USER /etc/passwd -n /etc/group`  

`number: arg1 arg2 ...`  is the same of `tail -n number arg1 arg2 ...`.  
For example, `15:` is the same of `tail -n 15`.  
`0:` is an alias of `10:`  

`:number ...` is `head -n number ...`  

Finally, like `g:` for grep, there is `s:` for sed. Examples:  
```
g:root /etc/passwd | s:root:foo:g s%/foo%:/foo/home%
```  
The same rules applies, so `s@ s. s, s\ ...` are all alternatives to `s:`, but the non-word character must be used as sed delimiter, for example, `s%root%foo%g /etc/passwd | head`

Examples
========

<pre>
# grep -e :[0-1]: -e $USER /etc/passwd | sed s%:%\\t%g    becomes  as follow

$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g
root	x	0	0	root	/root	/bin/bash
daemon	x	1	1	daemon	/usr/sbin	/usr/sbin/nologin
andrea	x	1000	1000	andrea,,,	/home/andrea	/bin/bash
</pre>  

<pre> 
# grep -e :[0-1]: -e $USER /etc/passwd | sed s%:%\\t%g | tail -n 1  becomes  as follow

$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g | 1:
andrea	x	1000	1000	andrea,,,	/home/andrea	/bin/bash
</pre>  

<pre>
# the same for head -n 1, but with : at the start of the number

$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g | :1
root	x	0	0	root	/root	/bin/bash
</pre>  

<pre>
# the same for tail -n +2  or  head -n -1

$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g | +2:
daemon	x	1	1	daemon	/usr/sbin	/usr/sbin/nologin
andrea	x	1000	1000	andrea,,,	/home/andrea	/bin/bash

$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g | :-1
root	x	0	0	root	/root	/bin/bash
daemon	x	1	1	daemon	/usr/sbin	/usr/sbin/nologin
</pre>
