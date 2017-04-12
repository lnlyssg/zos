/*REXX*/
/*********************************************************************/
/* Rexx to pull out all useful SETROPTS info from storage.           */
/* No SPECIAL or AUDITOR needed!                                     */
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
numeric digits 20
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
say ""
/* Below section pulls in bit string values for various settings     */
RCVTPRO  = RCVx + 393                          /* point to RCVTPRO   */
RCVTEROP = RCVx + 154                          /* point to RCVTEROP  */
RCVTAUOP = RCVx + 151                          /* point to RCVTAUOP  */
RCVTPROX = X2B(C2X(STORAGE(D2X(RCVTPRO),4)))   /* get the bits       */
RCVTEROX = X2B(C2X(STORAGE(D2X(RCVTEROP),4)))  /* get the bits       */
RCVTAUOX = X2B(C2X(STORAGE(D2X(RCVTAUOP),8)))  /* get the bits       */
if substr(RCVTEROX,3,1) = 0 then
 say "RACF Command violations are logged"
 else say "RACF Command violations are not logged"
if SUBSTR(RCVTPROX,1,1) = 1 then do
  say "PROTECT-ALL is on"
  if SUBSTR(RCVTPROX,2,1) = 1 then say " PROTECT-ALL WARNING mode"
    else say " PROTECT-ALL FAILURE mode"
  end
 else say "PROTECT-ALL is off"
if SUBSTR(RCVTPROX,3,1) = 1 then do
  say "ERASE-ON-SCRATCH is active, current options:"
  if SUBSTR(RCVTPROX,4,1) = 1 then say " ERASE-ON-SCRATCH BY SECLEVEL is on"
    else say " ERASE-ON-SCRATCH BY SECLEVEL is off"
  if SUBSTR(RCVTPROX,5,1) = 1 then say " ERASE-ON-SCRATCH for all",
     "datasets is on"
    else say " ERASE-ON-SCRATCH for all datasets is off"
 end
 else say "ERASE-ON-SCRATCH is off"
if SUBSTR(RCVTAUOX,2,1) = 1 then say "GROUP changes are audited"
 else say "GROUP changes are not audited"
if SUBSTR(RCVTAUOX,3,1) = 1 then say "USER changes are audited"
 else say "USER changes are not audited"
if SUBSTR(RCVTAUOX,4,1) = 1 then say "DATASET changes are audited"
 else say "DATASET changes are not audited"
if SUBSTR(RCVTAUOX,5,1) = 1 then say "DASDVOL changes are audited"
 else say "DASDVOL changes are not audited"
if SUBSTR(RCVTAUOX,6,1) = 1 then say "TAPEVOL changes are audited"
 else say "TAPEVOL changes are not audited"
if SUBSTR(RCVTAUOX,7,1) = 1 then say "TERMINAL changes are audited"
 else say "TERMINAL changes are not audited"
if substr(RCVTEROX,4,1) = 0 then say "SPECIAL users are audited"
 else say "SPECIAL users are not audited"
if SUBSTR(RCVTAUOX,8,1) = 1 then say "OPERATIONS users are audited"
 else say "OPERATIONS users are NOT audited"
say ""
/* Get the RVARY password info */
RCVTSWPW = Strip(Storage(D2x(RCVT + 440),8))  /* rvary switch pw     */
if c2x(RCVTSWPW) = "0000000000000000" then
 say "RVARY SWITCH password is set to default value of YES"
 else say "RVARY SWITCH password DES hash:" c2x(RCVTSWPW)
RCVTINPW = Strip(Storage(D2x(RCVT + 448),8))  /* rvary status pw     */
if c2x(RCVTINPW) = "0000000000000000" then
 say "RVARY STATUS password is set to default value of YES"
 else say "RVARY STATUS password DES hash:" c2x(RCVTINPW)
say ""
/* Get password and other related settings */
RCVTPINV  = C2d(Storage(D2x(RCVT + 155),1))  /* point to RCVTPINV   */
say "Global password change interval:" RCVTPINV "days"
/* Note that if a rule is set to 8 "*"s then it defaults to "0"s    */
/* which means the rule appears blank.                              */
/* Workaround for this is to look at the max length of each rule to */
/* see if it is truly a blank rule line or not!                     */
RCVTSNT1 = Strip(Storage(D2x(RCVT + 246),8))  /* PW syntax rule 1    */
RCVTSNT1S = Strip(Storage(D2x(RCVT + 244),1)) /* rule 1 min          */
RCVTSNT1E = Strip(Storage(D2x(RCVT + 245),1)) /* rule 1 max          */
 RCVTSNT1 = pwcheck(RCVTSNT1,RCVTSNT1E)       /* check rule 1        */
RCVTSNT2 = Strip(Storage(D2x(RCVT + 256),8))  /* PW syntax rule 2    */
RCVTSNT2S = Strip(Storage(D2x(RCVT + 254),1)) /* rule 2 min          */
RCVTSNT2E = Strip(Storage(D2x(RCVT + 255),1)) /* rule 2 max          */
 RCVTSNT2 = pwcheck(RCVTSNT2,RCVTSNT2E)       /* check rule 2        */
RCVTSNT3 = Strip(Storage(D2x(RCVT + 266),8))  /* PW syntax rule 3    */
RCVTSNT3S = Strip(Storage(D2x(RCVT + 264),1)) /* rule 3 min          */
RCVTSNT3E = Strip(Storage(D2x(RCVT + 265),1)) /* rule 3 max          */
 RCVTSNT3 = pwcheck(RCVTSNT3,RCVTSNT3E)       /* check rule 3        */
RCVTSNT4 = Strip(Storage(D2x(RCVT + 276),8))  /* PW syntax rule 4    */
RCVTSNT4S = Strip(Storage(D2x(RCVT + 274),1)) /* rule 4 min          */
RCVTSNT4E = Strip(Storage(D2x(RCVT + 275),1)) /* rule 4 max          */
 RCVTSNT4 = pwcheck(RCVTSNT4,RCVTSNT4E)       /* check rule 4        */
RCVTSNT5 = Strip(Storage(D2x(RCVT + 286),8))  /* PW syntax rule 5    */
RCVTSNT5S = Strip(Storage(D2x(RCVT + 284),1)) /* rule 5 min          */
RCVTSNT5E = Strip(Storage(D2x(RCVT + 285),1)) /* rule 5 max          */
 RCVTSNT5 = pwcheck(RCVTSNT5,RCVTSNT5E)       /* check rule 5        */
RCVTSNT6 = Strip(Storage(D2x(RCVT + 296),8))  /* PW syntax rule 6    */
RCVTSNT6S = Strip(Storage(D2x(RCVT + 294),1)) /* rule 6 min          */
RCVTSNT6E = Strip(Storage(D2x(RCVT + 295),1)) /* rule 6 max          */
 RCVTSNT6 = pwcheck(RCVTSNT6,RCVTSNT6E)       /* check rule 6        */
RCVTSNT7 = Strip(Storage(D2x(RCVT + 306),8))  /* PW syntax rule 7    */
RCVTSNT7S = Strip(Storage(D2x(RCVT + 304),1)) /* rule 7 min          */
RCVTSNT7E = Strip(Storage(D2x(RCVT + 305),1)) /* rule 7 max          */
 RCVTSNT7 = pwcheck(RCVTSNT7,RCVTSNT7E)       /* check rule 7        */
RCVTSNT8 = Strip(Storage(D2x(RCVT + 316),8))  /* PW syntax rule 8    */
RCVTSNT8S = Strip(Storage(D2x(RCVT + 314),1)) /* rule 8 min          */
RCVTSNT8E = Strip(Storage(D2x(RCVT + 315),1)) /* rule 8 max          */
 RCVTSNT8 = pwcheck(RCVTSNT8,RCVTSNT8E)       /* check rule 8        */
say "Password syntax rules:"
if c2x(RCVTSNT1E) <> "00" then do
  say " Rule 1:" RCVTSNT1
  Say "    Min length:" c2x(RCVTSNT1S)
  Say "    Max length:" c2x(RCVTSNT1E)
  end
if c2x(RCVTSNT2E) <> "00" then do
  say " Rule 2:" RCVTSNT2
  Say "    Min length:" c2x(RCVTSNT2S)
  Say "    Max length:" c2x(RCVTSNT2E)
  end
if c2x(RCVTSNT3E) <> "00" then do
  say " Rule 3:" RCVTSNT3
  Say "    Min length:" c2x(RCVTSNT3S)
  Say "    Max length:" c2x(RCVTSNT3E)
  end
if c2x(RCVTSNT4E) <> "00" then do
  say " Rule 4:" RCVTSNT4
  Say "    Min length:" c2x(RCVTSNT4S)
  Say "    Max length:" c2x(RCVTSNT4E)
  end
if c2x(RCVTSNT5E) <> "00" then do
  say " Rule 5:" RCVTSNT5
  Say "    Min length:" c2x(RCVTSNT5S)
  Say "    Max length:" c2x(RCVTSNT5E)
  end
if c2x(RCVTSNT6E) <> "00" then do
  say " Rule 6:" RCVTSNT6
  Say "    Min length:" c2x(RCVTSNT6S)
  Say "    Max length:" c2x(RCVTSNT6E)
  end
if c2x(RCVTSNT7E) <> "00" then do
  say " Rule 7:" RCVTSNT7
  Say "    Min length:" c2x(RCVTSNT7S)
  Say "    Max length:" c2x(RCVTSNT7E)
  end
if c2x(RCVTSNT8E) <> "00" then do
  say " Rule 8:" RCVTSNT8
  Say "    Min length:" c2x(RCVTSNT8S)
  Say "    Max length:" c2x(RCVTSNT8E)
  end
if c2x(RCVTSNT1E) = "00" & c2x(RCVTSNT2E) = "00",
   & c2x(RCVTSNT3E) = "00" & c2x(RCVTSNT4E) = "00",
   & c2x(RCVTSNT5E) = "00" & c2x(RCVTSNT6E) = "00",
   & c2x(RCVTSNT7E) = "00" & c2x(RCVTSNT8E) = "00",
   then  say " ** No password rules defined! **"
else say " LEGEND:",
    "A-ALPHA C-CONSONANT L-ALPHANUM N-NUMERIC V-VOWEL W-NOVOWEL" ,
    "*-ANYTHING  c-MIXED CONSONANT m-MIXED NUMERIC v-MIXED VOWEL",
    "$-NATIONAL s-SPECIAL"
RCVTSLEN = C2D(Strip(Storage(D2x(RCVT + 244),1))) /* min possible    */
if RCVTSLEN = 0 then RCVTSLEN = 1                 /* password length */
Say "Minimum possible password length:" RCVTSLEN
RCVTELEN = C2D(Strip(Storage(D2x(RCVT + 245),1))) /* max possible    */
if RCVTELEN = 0 then RCVTELEN = 8                 /* password length */
Say "Maximum possible password length:" RCVTELEN
RCVTRVOK = C2D(Strip(Storage(D2x(RCVT + 241),1))) /* logon attempts  */
if RCVTRVOK = 0 then RCVTRVOK = "unlimited"
Say "Invalid logon attempts allowed:" RCVTRVOK
RCVTINAC = C2D(Strip(Storage(D2x(RCVT + 243),1))) /* inactive intvl  */
if RCVTINAC = "0" then
 say "No inactive interval"
 else say "Inactive interval:" RCVTINAC "days"
RCVTHIST = C2D(Strip(Storage(D2x(RCVT + 240),1))) /* pw generations  */
if RCVTHIST = "0" then
 say "No password history in use"
 else say "Password generations:" RCVTHIST
/* Misc password related bit string flags */
RCVTFLG3 = RCVx + 633                          /* point to RCVTFLG3  */
RCVTFLGX = X2B(C2X(STORAGE(D2X(RCVTFLG3),8)))  /* get the bits       */
if SUBSTR(RCVTFLGX,2,1) = 1 then say "Mixed case passwords enabled"
 else say "Mixed case passwords disabled"
if SUBSTR(RCVTFLGX,5,1) = 1 then
 say "Special characters are allowed in passwords"
 else say "Special characters are not allowed in passwords"
if SUBSTR(RCVTFLGX,6,1) = 1 then
 say "Enhanced password options under OA43999 are available"
 else say "Enhanced password options under OA43999 are not available"
if SUBSTR(RCVTFLGX,7,1) = 1 then say "Multi factor auth is available"
 else say "Multi factor auth is not available"
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
exit

/* pwcheck function to check for an empty rule but with a max length */
pwcheck: parse arg pw length
if c2x(pw) = "0000000000000000" & c2x(length) <> "00" then
 return "********"
 else return pw
