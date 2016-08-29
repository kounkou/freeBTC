#!/bin/bash

# this function will generate a random
# sequence using reverse psychology probability
# for guess numbers
generateRandomReverseSequence()
{
   for it in `seq 0 7`
   do
      if (( rnd[it] == 20 || rnd[it + 1] == $((rnd[it] + 1)) ))
      then
         # go to next instruction
         # for instance if max is 9 :
         # 1 4 8 9 --> 2 5 8 9
         continue
      elif (( rnd[it] != $((rnd[it] + 1)) ))
      then
	 rnd[$it]=$((rnd[it] + 1))
      fi
   done
}

# this function will generate perfectly random numbers
# generate 20 random numbers and choose them
generateRandomNumbers()
{
   local flag=0

   until [ $flag -eq 1 ]
   do
      # displayUpdatedStatus "generating random numbers..."

      # generate 8 random numbers from within 1-20 interval
      # rnd=($(shuf -i 1-20 -n 8 | shuf -i 1-20 -n 8 | sort -n)) 
      xgess=`shuf -i 0-1 -n 1`

      if [ $xgess -eq 1 ]
      then
         rnd=($(shuf -i 1-20 -n 8 | shuf -i 1-20 -n 8)) 
      else
         # the random sequence looks like the following 
         # rnd=(20 5 19 10 18 15 17 16) 
         rnd=($(shuf -i 1-20 -n 8)) 
      fi

      # randomizing a bit more the sequence by inversing
      # the sequence from 9 to 11
      local xcas=($(shuf -i 1-20 -n 1)) 
      
      if ((xcas == 9))
      then 
         # displayUpdatedStatus "Reverse number generating..."
         generateRandomReverseSequence
      fi

      # Invoke the Kolmogorov Smirnov Algorithm 
      # displayUpdatedStatus "Testing random numbers with Kolmogorov Smirnov Test..."

      adjustArrayForKSTest
      computeDPlus
      computeDMinus

      flag=$(performKSTest)
   done
   
   # displayUpdatedStatus "Done generating random numbers"
}

# This will adjust the value to match the Kolmogorov
# Smirnov Test, as values are defined on [0; 1]
adjustArrayForKSTest()
{
   # compute the different adjusted values 
   # using -g to set rnd_tmp as global 
   declare -ag rnd_tmp

   # compute the different adjusted values 
   # this will compute then set each value
   # of the 8 elt associative array 
   for ((i=0; i<8; i++))
   do
      rnd_tmp[$i]=`echo "${rnd[$i]}/20" | bc -l`
   done
}

# this function gives the max of a set of numbers
max()
{
   declare -a tmpArr=("${!1}")

   local len=${#tmpArr[*]}
   local i=0
   local max=${tmpArr[1]}

   while [ $i -lt $len ]
   do
      val=`echo "${tmpArr[$i]}"`
      
      if [ $(echo "$max < $val" | bc -l) -eq 1 ]
      then
         max=$val
      fi
      let i++
   done

   # return statement
   echo $max
}

# this function computes D+ for the 
# Kolmogorov Smirnov Test
computeDPlus()
{
   # creating a local associative array
   declare -a dplusArray

   # compute the different adjusted values 
   # this will compute then set each value
   # of the 8 elt associative array 
   for ((i=0; i<8; i++))
   do
      dplusArray[$i]=`echo "$i/8 - ${rnd_tmp[$((i-1))]}" | bc -l`
   done

   # Invoke max on a set of values
   D_PLUS=$(max dplusArray[@])

   # displayUpdatedStatus "$D_PLUS"
}

# this function computes D+ for the 
# Kolmogorov Smirnov Test
computeDMinus()
{
   # creating a local array
   declare -a dminusArray

   # compute the different adjusted values 
   # this will compute then set each value
   # of the 8 elt associative array 
   for ((i=0; i<8; i++))
   do
      dminusArray[$i]=`echo "${rnd_tmp[$((i))]} - $i/8" | bc -l`
   done

   # Invoke max on a set of values
   D_MINUS=$(max dminusArray[@])

   # displayUpdatedStatus "$D_MINUS"
}

# now compute the Kolmogorov Smirnov
# Test to answer if yes or no the
# new sequence is good
performKSTest()
{
   local max
   local sts

   if [ $(echo "$D_MINUS < $D_PLUS" | bc -l) -eq 1 ]
   then
      max=$D_PLUS
   else
      max=$D_MINUS
   fi

   # Now perform the Test at 5% 
   if [ $(echo "$max < .457" | bc -l) -eq 1 ]
   then
      # echo "Accepted at 5%"
      # displayUpdatedStatus "K. Smirnov Test Accepted at 5%"
      sts=1
   else
      # echo "Refused  at 5%"
      tempo=`date`
      displayUpdatedStatus "$tempo, max : $max, K. Smirnov Test Refused  at 5%" > error.log
      sts=0
   fi 
 
   echo 1 # echo $sts
}

# this function will select text from one location
# to another location
selectText()
{
   if [ -f clipboard.txt ]
   then
      rm -rf clipboard.txt
   fi

   # can be improve with vars 
   helperFunction 298 
   helperFunction 334 
   helperFunction 370 
   helperFunction 406 
}

# helper function to select each lines
helperFunction()
{
   moveMouse 984 $1
   performLeftClick 1

   # target : 1179 405
   xdotool mousedown 1
   sleep 1
   local i=984

   for ((i=984; i<1160; i++))
   do
      moveMouse $i $1
      let i+=1
   done
   sleep 1

   xdotool mouseup 1
   moveMouse 1147 $1
   # do the text selection
   xdotool key ctrl+c

   # past it to a file
   xclip -sel clip -o >> clipboard.txt 
   sed -i -e '$a\' clipboard.txt
}

# this function will fill the loto grid
# this is where the 1 is
# 1 : 668          271 
# 2 : 668+1*55     271
# n : 668+(n-1)*55 271
fillLotoGrid()
{
   local x_axis_origin=668
   local y_axis_origin=271
   local step=55 

   # checking for errors first 
   for val in ${rnd[@]}
   do
      if (($val < 1))
      then
         displayUpdatedStatus "($(shuf -i 1-20 -n 8 | sort -n)) generating bad numbers"
         displayUpdatedStatus "Please report this error to linux"
         exit 1
      elif (($val > 20))
      then
         displayUpdatedStatus "($(shuf -i 1-20 -n 8 | sort -n)) generating bad numbers"
         displayUpdatedStatus "Please report this error to linux"
         exit 1
      fi
   done

   # this will select number on the User Interface
   for val in ${rnd[@]}
   do
      if (($val < 6))
      then
	 moveMouse $(($x_axis_origin + ($val - 01) * $step)) \
	           $y_axis_origin
         xdotool click 1 # performLeftClick
      elif (($val > 5 && $val < 11))
      then
	 moveMouse $(($x_axis_origin + ($val - 06) * $step)) \
	           $(($y_axis_origin + $step))
         xdotool click 1 # performLeftClick
      elif (($val > 10 && $val < 16))
      then
	 moveMouse $(($x_axis_origin + ($val - 11) * $step)) \
	           $(($y_axis_origin + 2 * $step))
         xdotool click 1 # performLeftClick
      elif (($val > 15))
      then
	 moveMouse $(($x_axis_origin + ($val - 16) * $step)) \
	           $(($y_axis_origin + 3 * $step))
         xdotool click 1 # performLeftClick
      fi
   done
}

chooseBonusSymbol()
{
   # once done we take the bonus symbol
   symb=($(shuf -i 1-3 -n 1 | shuf -i 1-3 -n 1))

   for s in "${symb[@]}"
   do
      if (($s == 1))
      then
         moveMouse 673 525 
         xdotool click 1 # performLeftClick
      elif (($s == 2))
      then
         moveMouse 778 522 
         xdotool click 1 # performLeftClick
      elif (($s == 3))
      then
         moveMouse 878 524 
         xdotool click 1 # performLeftClick
      fi
   done
}

# this function will display the message
displayUpdatedStatus()
{
   # echo -e "\033[2K $1"\\r

   # printf "%s\r" " $1"
   printf "%*s\r" $(tput cols) "$1"
}

# this function will get the mouse position
getMousePosition()
{
   eval $(xdotool getmouselocation --shell)
}


# this function will display the mouse position
displayMousePosition()
{
   echo -e "($1 ; $2)"
} 

# this function will move mouse and click
moveMouse()
{
   xdotool mousemove --sync $1 $2
}

# this function will perform a left click
performLeftClick()
{
   sleep 2
   xdotool click 1 # 1 is for left click
}

# this function will perform a left click
performRightClick()
{
   sleep 1
   xdotool click 3 # 1 is for left click
}

# this function will move the mouse wheel up
moveMouseWheelUp()
{
   local counter=$1

   until [  $counter -lt 0 ]; do
      xdotool click 4
      let counter-=1
   done
}

# this function will move the mouse wheel up
moveMouseWheelDown()
{
   local counter=$1

   until [  $counter -lt 0 ]; do
      xdotool click 5
      let counter-=1
   done
}

