Examples
========

<pre>
# grep -e :[0-1]: -e $USER /etc/passwd | sed s%:%\\t%g    becomes  as follow:
$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g
root	x	0	0	root	/root	/bin/bash
daemon	x	1	1	daemon	/usr/sbin	/usr/sbin/nologin
andrea	x	1000	1000	andrea,,,	/home/andrea	/bin/bash
</pre>

<pre> 
# grep -e :[0-1]: -e $USER /etc/passwd | sed s%:%\\t%g | tail -n 1  becomes  as follow:
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
$ 
$ g%:[0-1]: g%$USER /etc/passwd | s%:%\\t%g | :-1
root	x	0	0	root	/root	/bin/bash
daemon	x	1	1	daemon	/usr/sbin	/usr/sbin/nologin
</pre>
