/* Rexx */
/**********************************************************************/
/*                                                                    */
/* This Rexx will process a RACF database and extract the DES hashes  */
/* then print them out in John the Ripper format.                     */
/*                                                                    */
/* This is very much a work in progress from 2019 that I never got    */
/* round to completing or fully testing. It may or may not work for   */
/* for you.                                                           */
/*                                                                    */
/* Still to do:                                                       */
/*   1) Write output to a dataset > ask for dataset name or USS file? */
/*   2) Let the user choose JtR or Hashcat formats                    */
/*   3) Include KDFAES hashes (probably a decent chunk of work....)   */
/*   4) General cleanup of code                                       */
/*   5) Test it further, build-in some error handling                 */
/*                                                                    */
/* Author:  Jim Taylor                                                */
/*            https://github.com/jaytay79/zos                         */
/*                                                                    */
/**********************************************************************/

/* Set your RACF database here */
db = "SYS1.RACF"

"alloc fi(db) da('"db"') shr reuse"
"execio * diskr db (stem dblines. finis"
"free fi(db)"

base = x2c('C2C1E2C54040404000')      /* BASE in hex with extra chars */
ustring = x2c('08')                   /* 08 = user */

do i = 1 to dblines.0
  marker = POS(base,dblines.i)                  /* look for word BASE */
  do while marker <> 0
    len = substr(dblines.i,marker+9,1)    /* length of profile in hex */
     len2 = lenconvert(len)               /* convert the hex          */
    chunk = substr(dblines.i,marker,70)   /* grab a chunk of the DB   */
    call search(chunk)                    /* search it                */
    marker = POS(base,dblines.i,marker+70) /* move the start point on */
  end
end

/* search function does the heavy lifting */
search:
parse arg chunk
if substr(dblines.i,marker+len2+23,1) = ustring then do /* userid = 08*/
  user = substr(dblines.i,marker+11,len2)         /* get the ID       */
  if length(user) = 0 then return                 /* ignore 0 length  */
  if substr(user,1,3) = "irr" then return         /* ignore cert IDs  */
  des = c2x(substr(dblines.i,marker+len2+52,8))   /* get the hash     */
  if substr(des,1,4) <> "0000" then               /* ignore PROTECTED */
  say user":$racf$*"user"*"des                    /* say the output   */
end
return

/* lenconvert just translates hex to numerics to get length. May be a */
/* better way of doing this?                                          */
lenconvert:
parse arg len
select
  when c2x(len) = '08' then return 8
  when c2x(len) = '07' then return 7
  when c2x(len) = '06' then return 6
  when c2x(len) = '05' then return 5
  when c2x(len) = '04' then return 4
  when c2x(len) = '03' then return 3
  when c2x(len) = '02' then return 2
  when c2x(len) = '01' then return 1
  otherwise return 0
end