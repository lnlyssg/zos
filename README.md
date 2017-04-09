# RACF and z/OS tools and info

### Rexxes

[SETRRCVT](https://github.com/jaytay79/zos/blob/master/SETRRCVT.rexx) - Rexx to pull out RACF SETROPTS info from storage without needing to have SPECIAL or AUDITOR. _Any comments or additions gratefully received!_  

[GENPW](https://github.com/jaytay79/zos/blob/master/GENPW.rexx) - Rexx to generate random passwords.

### Random stuff

[Cracking RACF passwords with hashcat](https://github.com/jaytay79/zos/wiki/hashcat-commands-for-RACF-passwords)

[racf.rule](https://github.com/jaytay79/zos/blob/master/racf.rule) - for use with the above - based on best64.rule with some minor changes, could do with more tweaking!

[MVS Control Blocks.txt](https://github.com/jaytay79/zos/blob/master/MVS%20Control%20Blocks.txt) - File for use in ISRDDN to make browsing storage easier. Use in conjunction with [this](https://github.com/jaytay79/zos/wiki/ISRDDN-Control-Block-browsing) process.  


## Other useful notes
To find DES encrypted RVARY passwords in common storage:  

```
TSO ISRDDN  
BROWSE 10.?+3e0?+1B8  
```
![RVARY passwords](https://raw.githubusercontent.com/jaytay79/zos/master/rvary.png)
In the above example the password was set to "QWERTY1" for both RVARY SWITCH and RVARY STATUS and "5AA70358 A9C369E0" is the DES value for both (RVARY SWITCH is the first set of bytes and RVARY STATUS the second set). If the values are all "0"s then the default password of "YES" is set.  

If you want to run this in hashcat then the key used to generate the DES hashes is the plaintext password itself! e.g. `$racf$*QWERTY1*5AA70358A9C369E0`

_With thanks to [Nigel Pentland](http://www.racf.co.uk) for his assistance on figuring out the key used_