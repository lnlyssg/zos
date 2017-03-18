/* REXX */                                                               
/*                                                                         */
/* Taken from https://rosettacode.org/wiki/Password_generator and tweaked  */
/* slightly. Help docs at the bottom or use "GENPW ?"                      */
/*                                                                         */
@L='abcdefghijklmnopqrstuvwxyz'; @U=@L; upper @U                        
@#= 0123456789                                                          
@@= #£@                                                                 
/* To include all special chars from OA43999 uncomment below line and      */
/* comment out line above                                                  */
/* @@= '#£@.<+|&!*-%_>?:=' */
parse arg L N seed xxx yyy .                                            
if L=='?'               then signal help                                
if L=='' | L==","       then L=8                                        
if N=='' | N==","       then N=1                                        
if xxx\==''             then call weed  xxx                             
if yyy\==''             then call weed  x2c(yyy)                        
if  datatype(seed,'W')  then call random ,,seed                         
if \datatype(L,   'W')  then call serr "password length, it isn't an integer:"
if L<4                  then call serr "password length, it's too small (< 4):"
if L>80                 then call serr "password length, it's too large (> 80)"
if \datatype(N,   'W')  then call serr "number of passwords, "         
                                                                        
    do g=1  to N;       £=                                              
        do k=1  for L;       z=k;   if z>4  then z=random(1,4)          
        if z==1  then £=£ || substr(@L,random(1,length(@L)),1)          
        if z==2  then £=£ || substr(@U,random(1,length(@U)),1)          
        if z==3  then £=£ || substr(@#,random(1,length(@#)),1)          
        if z==4  then £=£ || substr(@@,random(1,length(@@)),1)          
        end   /*k*/                                                     
                                                                        
        do a=1  for L;          b=random(1, L)                          
        parse var £ =(a) x +1 =(b)  y  +1                               
        £=overlay(x,£,b);       £=overlay(y,£,a)                        
        end  /*L+L*/                                                    
                                                                        
    say right(g, length(N))  'password is: '  £                         
    /*      call lineout 'GENPW.PW', £  */                              
    end      /*g*/                                                      
exit                                                                    
weed:  parse arg ig;   @L=dont(@L);   @U=dont(@U);   @#=dont(@#);   @@=d
dont:  return space( translate(arg(1), , ig), 0)                        
serr:  say;   say '***error*** invalid'  arg(1);  exit 13               
help: signal .; .: do j=sigL+1 to sourceline();,                        
say strip(left(sourceline(j),79)); end                                  
/*                                                                      
   GENPW  ?                         shows this documentation.           
   GENPW                            generates 1 password of 8 chars     
   GENPW len                        generates (all) passwords           
   GENPW  ,   n                     generates N number of passwds       
   GENPW  ,   ,  seed               generates pwords using a random seed
   GENPW  ,   ,    ,  xxx           generates pwords without xxx        
   GENPW  ,   ,    ,   ,  yyy       generates pwords without yyy        
                                                                        
===== where   [if a  comma (,)  is specified,  the default is used]: ===
len     is the length of the passwords to be generated.  Default is 8   
        The minimum is  4,   the maximum is  80.                        
n       is the number of passwords to be generated. default is 1        
seed    is an integer seed used for the RANDOM BIF.                     
xxx     are characters to  NOT  be used for generating passwords.       
yyy     (same as XXX,  except the chars are expressed as hex            
*/