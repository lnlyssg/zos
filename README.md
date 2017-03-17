# z/OS
#### Random mainframe stuff

SETRRCVT - Rexx to pull out RACF SETROPTS info from storage without needing to have SPECIAL or AUDITOR. _work in progress_

racf.rule - hashcat rule for cracking RACF passwords, probably needs more tweaking!

MVS Control Blocks.txt - File for use in ISRDDN to make browsing storage easier. Use in conjunction with [this](http://www.meerkatcomputerservices.com/mfblog/wp-content/uploads/2016/07/Browsing-MVS-Control-Blocks-Using-DDLIST.pdf) document.

## Other useful notes
To find DES encrypted RVARY passwords in common storage:  

```
TSO ISRDDN  
BROWSE 10.?+3e0?+1B0+8  
```
![RVARY passwords](https://raw.githubusercontent.com/jaytay79/zos/master/rvary.png)
In the above example "5AA70358 A9C369E0" is the DES value for both RVARY SWITCH and RVARY STATUS passwords and they appear side by side.