# z/OS
#### Random mainframe stuff

[SETRRCVT](https://github.com/jaytay79/zos/blob/master/SETRRCVT.txt) - Rexx to pull out RACF SETROPTS info from storage without needing to have SPECIAL or AUDITOR. _work in progress. Any comments or additions gratefully received!_

[racf.rule](https://github.com/jaytay79/zos/blob/master/racf.rule) - hashcat rule for cracking RACF passwords, probably needs more tweaking!

[MVS Control Blocks.txt](https://github.com/jaytay79/zos/blob/master/MVS%20Control%20Blocks.txt) - File for use in ISRDDN to make browsing storage easier. Use in conjunction with [this](http://www.meerkatcomputerservices.com/mfblog/wp-content/uploads/2016/07/Browsing-MVS-Control-Blocks-Using-DDLIST.pdf) document.  

[GENPW](https://github.com/jaytay79/zos/blob/master/GENPW.txt) - Rexx to generate passwords.

## Other useful notes
To find DES encrypted RVARY passwords in common storage:  

```
TSO ISRDDN  
BROWSE 10.?+3e0?+1B8  
```
![RVARY passwords](https://raw.githubusercontent.com/jaytay79/zos/master/rvary.png)
In the above example the password was set to "QWERTY1" for both and  "5AA70358 A9C369E0" is the DES value for both. RVARY SWITCH is the first set of bytes and RVARY STATUS the second set. If the values are all "0"s then the default password of "YES" is set.  

If you want to run this in hashcat then the key used to generate the DES hashes is the plaintext password itself! e.g. `$racf$*QWERTY1*5AA70358A9C369E0`

_With thanks to [Nigel Pentland](http://www.racfsnow.co.uk) for his assistance with this_