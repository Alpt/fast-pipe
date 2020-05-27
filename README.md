Usage
=====

`- regexp arg arg ... - regexp arg arg ...`  

is the same of `grep -e regexp arg arg ... -e regexp arg arg ....`  

`number: arg1 arg2 ...`  means `tail -n number arg1 arg2 ...`

`0:` is an alias of `10:`  

`:number ...` means `head -n number ...`  

Pipe is already implicit:

`- home /etc/passwd :-3 1:`  

is the same of  

`grep home /etc/passwd | head -n -3 | tail -n 1`  

Finally, there is sed. Example:  

```
- root /etc/passwd  s: root foo :g  s% /foo /foo/home
```  

is the same of  

```
grep -e root /etc/passwd | sed -e s:root:foo:g -e s%/foo%/foo/home%
```  

The non-word character after `s` can actually be any non-word character, so `s: s- s/ s% s@ s- ...` are all valid. Only, `s/` is not valid if used at the start, not in a pipe, because bash treats / specially.  

Example
=======

<pre>
Pseudo code:
    
  grep users with 'nologin' as login shell | substitute the string 'nologin' with 'nopelogin' |
      grep uid with at most 3 digits | take only the first three lines

Normal bash:

  grep -e nologin /etc/passwd | sed -e s/nologin/nopelogin/ | grep '^[^:]*:[^:]*:[^:]\{,3\}:' | head -n 3

Fastpipe bash:

  - nologin /etc/passwd s/ nologin nopelogin - '^[^:]*:[^:]*:[^:]\{,3\}:' :3

Output:

  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nopelogin
  bin:x:2:2:bin:/bin:/usr/sbin/nopelogin
  sys:x:3:3:sys:/dev:/usr/sbin/nopelogin

</pre>  
