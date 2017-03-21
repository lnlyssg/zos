/*REXX*/
/*********************************************************************/
/* Work in progress Rexx to pull out all useful SETROPTS info from   */
/* storage. No SPECIAL or AUDITOR needed!                            */
/*                                                                   */
/* Still to do:                                                      */
/* - Cater for multiple password rule settings                       */
/*                                                                   */
/* Author:  Jim Taylor                                               */
/*            https://github.com/jaytay79/zos                        */
/*                                                                   */
/* Sources: Mark Zelden's IPLINFO Rexx:                              */
/*            http://www.mzelden.com/mvsfiles/iplinfo.txt            */
/*          Mark Wilson's "RACF for Systems Programmers" course:     */
/*            http://www.rsm.co.uk                                   */
/*          z/OS Security Server RACF Data Areas manual:             */
/*            http://publibz.boulder.ibm.com/epubs/pdf/ich2c400.pdf  */
/*          Bruce Wells' XSETRPWD                                    */
/*            ftp://public.dhe.ibm.com/s390/zos/racf/irrxutil/       */
/*********************************************************************/
/* Get info from storage, most of this section is a straight lift    */
/* from IPLINFO!                                                     */
CVT      = C2d(Storage(10,4))                /* point to CVT         */
CVTVERID = Storage(D2x(CVT - 24),16)         /* "user" software vers.*/
PRODNAME = Storage(D2x(CVT - 40),7)          /* point to mvs version */
CVTRAC   = C2d(Storage(D2x(CVT + 992),4))    /* point to RACF CVT    */
RCVT     = CVTRAC                            /* use RCVT name        */
RCVx     = C2D(STORAGE(D2X(CVT+X2D('3E0')),4)) /* ugly mess for bits */
RCVTID   = Storage(D2x(RCVT),4)              /* point to RCVTID      */
If RCVTID = 'RCVT' then SECNAM = 'RACF'      /* RCVT is RACF         */
RACFVRM  = Storage(D2x(RCVT + 616),4)        /* RACF Ver/Rel/Mod     */
RACFVER  = Substr(RACFVRM,1,1)               /* RACF Version         */
RACFREL  = Substr(RACFVRM,2,2)               /* RACF Release         */
If Bitand(CVTOSLV2,'01'x) <> '01'x then ,    /* below OS/390 R10     */
  RACFREL  = Format(RACFREL)                 /* Remove leading 0     */
RACFMOD  = Substr(RACFVRM,4,1)               /* RACF MOD level       */
RACFLEV  = RACFVER || '.' || RACFREL || '.' || RACFMOD
RCVTDSN = Strip(Storage(D2x(RCVT + 56),44))  /* RACF prim dsn        */

  RCVTDSDT  = C2d(Storage(D2x(RCVT + 224),4))  /* point to RACFDSDT  */
  DSDTNUM   = C2d(Storage(D2x(RCVTDSDT+4),4))  /* num RACF dsns      */
  DSDTPRIM  = Storage(D2x(RCVTDSDT+177),44)    /* point to prim ds   */
  DSDTPRIM  = Strip(DSDTPRIM,'T')              /* del trail blanks   */
  DSDTBACK  = Storage(D2x(RCVTDSDT+353),44)    /* point to back ds   */
  DSDTBACK  = Strip(DSDTBACK,'T')              /* del trail blanks   */
  Say   'The security software is' Word(PRODNAME,1) ,
        'Security Server (RACF).' ,
        'The FMID is HRF' || RACFVRM || '.'
  If DSDTNUM = 1 then
    Say  '  The RACF primary data set is' DSDTPRIM'.'
    Say  '  The RACF backup  data set is' DSDTBACK'.'
  RCVTUADS = Strip(Storage(D2x(RCVT + 100),44)) /* UADS dsn          */
    say  '  The UADS dataset is' RCVTUADS'.'

/* Below sections pulls in bit string values for various settings    */
RCVTPRO  = RCVx + 393                          /* point to RCVTPRO   */
RCVTEROP = RCVx + 154                          /* point to RCVTEROP  */
RCVTAUOP = RCVx + 151                          /* point to RCVTAUOP  */
RCVTPROX = X2B(C2X(STORAGE(D2X(RCVTPRO),4)))   /* get the bits       */
RCVTEROX = X2B(C2X(STORAGE(D2X(RCVTEROP),4)))  /* get the bits       */
RCVTAUOX = X2B(C2X(STORAGE(D2X(RCVTAUOP),8)))  /* get the bits       */
if substr(RCVTEROX,3,1) = 0 then say "CMDVIOL is on"
 else say "CMDVIOL is off"
if substr(RCVTEROX,4,1) = 0 then say "SAUDIT is on"
 else say "SAUDIT is off"
if SUBSTR(RCVTPROX,1,1) = 1 then say "PROTECT-ALL is on"
 else say "PROTECT-ALL is off"
if SUBSTR(RCVTPROX,2,1) = 1 then say "PROTECT-ALL WARNING mode"
else say "PROTECT-ALL FAILURE mode"
if SUBSTR(RCVTPROX,3,1) = 1 then say "ERASE-ON-SCRATCH is on"
 else say "ERASE-ON-SCRATCH is off"
if SUBSTR(RCVTPROX,4,1) = 1 then say "ERASE-ON-SCRATCH BY SECLEVEL on"
 else say "ERASE-ON-SCRATCH BY SECLEVEL off"
if SUBSTR(RCVTAUOX,2,1) = 1 then say "Group changes are audited"
 else say "Group changes are not audited"
if SUBSTR(RCVTAUOX,3,1) = 1 then say "User changes are audited"
 else say "User changes are not audited"
if SUBSTR(RCVTAUOX,4,1) = 1 then say "Dataset changes are audited"
 else say "Dataset changes are not audited"
if SUBSTR(RCVTAUOX,5,1) = 1 then say "DASDVOL changes are audited"
 else say "DASDVOL changes are not audited"
if SUBSTR(RCVTAUOX,6,1) = 1 then say "TAPEVOL changes are audited"
 else say "TAPEVOL changes are not audited"
if SUBSTR(RCVTAUOX,7,1) = 1 then say "TERMINAL changes are audited"
 else say "TERMINAL changes are not audited"
if SUBSTR(RCVTAUOX,8,1) = 1 then say "OPERATIONS users are audited"
 else say "OPERATIONS users are not audited"
/* Get the RVARY password info */
RCVTSWPW = Strip(Storage(D2x(RCVT + 440),8))  /* rvary switch pw     */
if c2x(RCVTSWPW) = "0000000000000000" then
 say "RVARY SWITCH password is set to default value of YES"
 else say "RVARY SWITCH password DES hash:" c2x(RCVTSWPW)
RCVTINPW = Strip(Storage(D2x(RCVT + 448),8))  /* rvary status pw     */
if c2x(RCVTINPW) = "0000000000000000" then
 say "RVARY STATUS password is set to default value of YES"
 else say "RVARY STATUS password DES hash:" c2x(RCVTINPW)
/* Get password and other related settings */
RCVTPINV  = C2d(Storage(D2x(RCVT + 155),1))  /* point to RCVTPINV   */
say "Global password change interval:" RCVTPINV "days"
/* it seems that if a rule is set to 8 "*"s then it defaults to     */
/* "0"s which is messy if said rule is active further down.....     */
/* Needs some work to try and figure this out further!              */
RCVTSNT1 = Strip(Storage(D2x(RCVT + 246),8)) /* PW syntax rules     */
RCVTSNT2 = Strip(Storage(D2x(RCVT + 256),8)) /* PW syntax rules     */
RCVTSNT3 = Strip(Storage(D2x(RCVT + 266),8)) /* PW syntax rules     */
RCVTSNT4 = Strip(Storage(D2x(RCVT + 276),8)) /* PW syntax rules     */
RCVTSNT5 = Strip(Storage(D2x(RCVT + 286),8)) /* PW syntax rules     */
RCVTSNT6 = Strip(Storage(D2x(RCVT + 296),8)) /* PW syntax rules     */
RCVTSNT7 = Strip(Storage(D2x(RCVT + 306),8)) /* PW syntax rules     */
RCVTSNT8 = Strip(Storage(D2x(RCVT + 316),8)) /* PW syntax rules     */
say "Password syntax rules:"
if c2x(RCVTSNT1) <> "0000000000000000" then
  say " Rule 1:" RCVTSNT1
else say " Rule 1: ********"
if c2x(RCVTSNT2) <> "0000000000000000" then
  say " Rule 2:" RCVTSNT2
if c2x(RCVTSNT3) <> "0000000000000000" then
  say " Rule 3:" RCVTSNT3
if c2x(RCVTSNT4) <> "0000000000000000" then
  say " Rule 4:" RCVTSNT4
if c2x(RCVTSNT5) <> "0000000000000000" then
  say " Rule 5:" RCVTSNT5
if c2x(RCVTSNT6) <> "0000000000000000" then
  say " Rule 6:" RCVTSNT6
if c2x(RCVTSNT7) <> "0000000000000000" then
  say " Rule 7:" RCVTSNT7
if c2x(RCVTSNT8) <> "0000000000000000" then
  say " Rule 8:" RCVTSNT8
say "LEGEND:",
    "A-ALPHA C-CONSONANT L-ALPHANUM N-NUMERIC V-VOWEL W-NOVOWEL" ,
    "*-ANYTHING c-MIXED CONSONANT m-MIXED NUMERIC v-MIXED VOWEL",
    "$-NATIONAL"
/* the below is a bit broken as it only pulls out min and max        */
/* values for the first password rule. needs work!                   */
RCVTSLEN = C2D(Strip(Storage(D2x(RCVT + 244),1))) /* min pw length   */
Say "Min password length:" RCVTSLEN
RCVTELEN = C2D(Strip(Storage(D2x(RCVT + 245),1))) /* max pw length   */
Say "Max password length:" RCVTELEN
RCVTRVOK = C2D(Strip(Storage(D2x(RCVT + 241),1))) /* logon attempts  */
Say "Invalid logon attempts allowed:" RCVTRVOK
RCVTINAC = C2D(Strip(Storage(D2x(RCVT + 243),1))) /* inactive int    */
Say "Inactive interval:" RCVTINAC "days"
RCVTHIST = C2D(Strip(Storage(D2x(RCVT + 240),1))) /* pw generations  */
Say "Password generations:" RCVTHIST
/* Misc password related bit string flags */
RCVTFLG3 = RCVx + 633                          /* point to RCVTFLG3  */
RCVTFLGX = X2B(C2X(STORAGE(D2X(RCVTFLG3),8)))  /* get the bits       */
if SUBSTR(RCVTFLGX,2,1) = 1 then say "Mixed case passwords enabled"
 else say "Mixed case passwords disabled"
if SUBSTR(RCVTFLGX,7,1) = 1 then say "Multi factor auth is enabled"
 else say "Multi factor auth is disabled"
/* Checks for new password encryption */
RCVTPALG = C2D(Strip(Storage(D2x(RCVT + 635),1))) /* pw encryption   */
if RCVTPALG = "1" then say "KDFAES encryption is active"
 else say "Legacy encryption is active"
/* ----------------------------------------------------------------- */
/* See if new password exit is active.                               */
/* ----------------------------------------------------------------- */
pwx01hex = Storage(D2x(RCVT + 236),4)
RCVTPWDX = C2d(BITAND(pwx01hex,'7FFFFFFF'x))
If RCVTPWDX = 0 Then
  YesOrNo = 'is NOT'
else
  YesOrNo = 'IS'
say "There" YesOrNo "a new password exit (ICHPWX01) installed."
