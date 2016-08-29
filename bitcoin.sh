#!/bin/bash
#------------------------------------------------------------------
# This program is an automatic better online
# From a minimal amount 10,000 Unit it will
# garanty a 100% profit after each hour
# Please support African Technology
# 1FBAXhuwBnTESvB5RKRWGR3fYzWSayPMx2 for  BTC
# D716sA9JcQmGCRefX9w887QttkaekK1B33 for DOGE
# 
# Disclaimer
# This SOFTWARE PRODUCT is provided by THE PROVIDER "as is" 
# and "with all faults." THE PROVIDER makes 
# no representations or warranties of any kind concerning 
# the safety, suitability, lack of viruses, inaccuracies, 
# typographical errors, or other harmful components of this 
# SOFTWARE PRODUCT. There are inherent dangers in the use 
# of any software, and you are solely responsible for determining 
# whether this SOFTWARE PRODUCT is compatible with your 
# equipment and other software installed on your equipment. 
# You are also solely responsible for the protection of your 
# equipment and backup of your data, and THE PROVIDER will 
# not be liable for any damages you may suffer in connection  
# with using, modifying, or distributing this SOFTWARE PRODUCT.  
#------------------------------------------------------------------

# debug flag, print all traces
# set -x

# export display for remote calls
export DISPLAY=:0.0

# includes
. tools.sh

#--------------------------------------------
# this will give the correct syntax
# globals   : na
# arguments : na 
# return    : na
#--------------------------------------------
usage()
{
   echo -e 'Usage : bash bitcoin.sh <amount limit> <coins type [bitcoin = 1, doge = 2]>'
   echo -e ''
}

#--------------------------------------------
# helper function : BET HI or BET LO
# globals   : na
# arguments : na 
# return    : na
#--------------------------------------------
function bet()
{
   if [ $1 -eq 2 ]
   then
      # bet high
      selectElement 829 407 1
   elif [ $1 -eq 1 ]
   then
      # bet low
      selectElement 978 408 1
   fi
}

#--------------------------------------------
# helper function : set the bet amount
# globals   : na
# arguments : na 
# return    : na
#--------------------------------------------
function setBetAmount()
{
   local bet=$1

   multiClickElement 538 449 3
   setxkbmap fr
   xdotool type "$bet"
   sleep 5
}

#--------------------------------------------
# increase bet amount
# globals   : na
# arguments : na 
# return    : na
#--------------------------------------------
function increaseBetToMax()
{
   selectElement 715 415 1
}

#--------------------------------------------
# increase bet to min x 2
# globals   : na
# arguments : na 
# return    : na
#--------------------------------------------
function increaseBetTo2min()
{
   selectElement 635 416 1
}

#--------------------------------------------
# helper function : decrease bet amount
# globals   : na
# arguments : na 
# return    : na
#--------------------------------------------
function decreaseBetToMin()
{
   if [ $coins -eq 1 ]
   then 
      setBetAmount .00000002
   else
      setBetAmount .040
      btAm=.040
   fi
   sleep 2
}

#--------------------------------------------
# get the amount
# globals   : na
# arguments : na 
# return    : balance
#--------------------------------------------
function getAmount()
{
   local amount

   multiClickElement 1375 118 2
   xdotool key ctrl+c

   # remove the file to have a clean scenario 
   if [ -f clipboard.data ]
   then
      rm -rf clipboard.data
   fi

   # past it to a file
   sleep 2
   xclip -sel clip -o > clipboard.data 
   sleep 2
   amount=`cat clipboard.data`

   echo $amount
}

#--------------------------------------------
# helper function to change element
# globals   : na
# arguments : x_axis, 
#             x_axis, 
#             c_time and nw_val
# return    : na
#--------------------------------------------
function changeElement()
{
   local readonly x_axis=$1
   local readonly y_axis=$2
   local readonly c_time=$3
   local readonly nw_val=$4
   
   multiClickElement $x_axis $y_axis $c_time
   setxkbmap fr
   xdotool type "$nw_val"
   sleep 2
}

#--------------------------------------------
# helper function to change element
# globals   : na
# arguments : x_axis, 
#             x_axis, 
#             c_time
# return    : na
#--------------------------------------------
function multiClickElement()
{
   local readonly x_axis=$1
   local readonly y_axis=$2
   local readonly c_time=$3
   
   moveMouse $x_axis $y_axis
   xdotool click --repeat $c_time 1
   sleep 2
}

#--------------------------------------------
# withdraw 50 doge
# globals   : na
# arguments : na
# return    : na
#--------------------------------------------
function withdraw()
{
   local readonly amnt=$1

   selectElement 0958 0181 1
   sleep 10
   selectElement 0953 0289 1
   changeElement 0806 0667 3 $amnt
   selectElement 0899 0731 
   selectElement 1333 0176 1
   sleep 10
}

#--------------------------------------------
# here is the logic now
# globals   : na
# arguments : na
# return    : na
#--------------------------------------------
function betAlgorithm()
{
   local rslt=0
   local prev=0
   local curr=0

   sleep 2
   prev=$(getAmount)
   bet $nxbet
   sleep 2 
   curr=$(getAmount)
   sleep 2
    
   rslt=$(echo "$curr - $prev" | bc -l)
   
   # if I am loosing money 
   if [ $(echo "$rslt < 0" | bc -l) -eq 1 ]
   then
      let tries+=1
      let count-=1

      if [ $nxbet -eq 1 ]
      then
	 nxbet=1
      fi

      if [ $tries -ge 1 ]
      then
         btAm=$(echo "$btAm * 2" | bc -l)

         if [ $tries -gt 3 ]
         then
           sleep 8
         fi

         setBetAmount $btAm
      fi
   else
      let count+=1
      tries=0
      decreaseBetToMin
      btAm=.040

      # withdraw if we have 20 doge balance
      if [ $(echo "$curr >= 40.0" | bc -l) -eq 1 ]
      then
         withdraw 20
      fi
   fi
   
   nprev=$(getAmount)

   # logging inside bets.log
   local timing=`date +"%W.%u %H:%M:%S"`
   printf "%12s %10s %5s %12s %13s\n" "$nprev" "$count" "$tries" "$btAm" "$timing" >> bets.log

   # Hint : $(echo "expr ..." | bc -l)
   rslt=$(echo "$limit > $nprev" | bc -l)

   if [ $rslt -eq 1 ]
   then
      exit 0
   fi
}

#--------------------------------------------
# function to check the screen resolution
# globals   : na
# arguments : na
# return    : na
#--------------------------------------------
function checkScreenResolution()
{
   # checking screen resolution
   local readonly x_resolution=`xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $1}'`
   local readonly y_resolution=`xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $2}'`

   if [[ $x_resolution -ne 1824 || $y_resolution -ne 984 ]]
   then
      echo "not supported resolution"
      exit 1
   fi
}

# some global values 
count=10
nxbet=1
tries=0
limit=$1
coins=$2

# main function
function __main()
{
   checkScreenResolution

   # building logging header file
   echo "======================================================" >> bets.log 
   echo "new session on : `date` by `whoami`" >> bets.log
   echo "======================================================" >> bets.log 
   printf "%12s %10s %5s %12s %13s\n" "balance" "count" "tries" "bet" "date" >> bets.log

   # checking parameters
   if [ $# -lt 2 ]
   then
      usage
      exit 1
   fi

   # starting the program
   selectElement 1004 117 1
   decreaseBetToMin

   # Infinite loop
   while true
   do
      selectElement 1004 117 1
      betAlgorithm
      sleep 2
   done
}

__main $1 $2
