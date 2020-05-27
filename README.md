Usage
=====

`- regexp arg arg ... - regexp arg arg ...` ... is the same of `grep -e regexp arg arg ... -e regexp arg arg ....`.  

`number: arg1 arg2 ...`  is the same of `tail -n number arg1 arg2 ...`.  
For example, `15:` is the same of `tail -n 15`.  
`0:` is an alias of `10:`  

`:number ...` is `head -n number ...`  

Pipe in already implicit.  
`- home /etc/passwd :-3 :1`  
is the same of  
`grep home /etc/passwd | head -n -3 | tail -n 1`  

Then there is sed. Example:  
```
- root /etc/passwd  s: root foo :g  s% /foo /foo/home
```  
is the same of  
```
grep -e root /etc/passwd | sed -e s:root:foo:g -e s%/foo%/foo/home%
```  

The non-word character after `s` can actually be any non-word character, so `s: s- s/ s% s@ s-` are all valid. Only, `s/` is not valid if used at the start, not in a pipe, because bash treats / specially.  

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
