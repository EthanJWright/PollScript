#!/bin/bash
#Ethan Wright 9/11/16
cd "$(dirname "$0")"  #Set cwd 
if ping -c 1 www.google.com &> /dev/null #check for internet connection
then
curl -s http://www.realclearpolitics.com/epolls/latest_polls/president/ | html2text > data.txt
TRUMP=$(cat data.txt |\
grep 'Trump +' |\
 grep -o '[+][0-9]*' | grep -Eo '[0-9]+' |\
tee $(dirname "$0")/trumplc.txt|\
 awk '{ SUM += $1} END { print SUM }')
 #pull data from RCP, tee a file to trumplc.txt, and add up the spread

TRUMPAVG=$(wc -l < $(dirname "$0")/trumplc.txt)   #this is the total number of polls taken for spread
TRUMPNEW=$((TRUMP/TRUMPAVG))    #average trump's spread


CLINTON=$(cat data.txt |\
grep 'Clinton +' |\
 grep -o '[+][0-9]*' | grep -Eo '[0-9]+' |\
tee $(dirname "$0")/clintonlc.txt|\
 awk '{ SUM += $1} END { print SUM }')      #Pull Clinton's data from RLC

CLINTAVG=$(wc -l < $(dirname "$0")/clintonlc.txt) #Get total number of polls for clinton

CLINTNEW=$((CLINTON/CLINTAVG))   #Average Clinton's spread

if [[ $CLINTNEW > $TRUMPNEW ]]   #Set up conditional based on who is ahead
then                             #if Clinton is ahead
  DIFF=$((CLINTNEW-TRUMPNEW))
  printf '%s%d\n' "The spread benefits Clinton +" "$DIFF"
else                            #if Trump is ahead
  DIFF=$((TRUMPNEW-CLINTNEW))
  printf '%s%d\n' "The spread benefits Trump +" "$DIFF"
fi

CLINTONCOUNT=$(wc -l < $(dirname "$0")/clintonlc.txt)  #Establish data for who has won more polls
TRUMPCOUNT=$(wc -l < $(dirname "$0")/trumplc.txt)
TOTALCOUNT=$((CLINTONCOUNT+TRUMPCOUNT))

if [[ $CLINTONCOUNT > $TRUMPCOUNT ]]    #conditional for who has won more polls
then
  DIFF=$((CLINTONCOUNT-TRUMPCOUNT))

  printf '%s%d%s%d%s\n' "and Clinton is ahead in " "$CLINTONCOUNT" " polls out of " "$TOTALCOUNT" " total polls."
else
  DIFF=$((TRUMPCOUNT-CLINTONCOUNT))       #Trump has won more polls
  printf '%s%d%s%d%s\n' "and Trump is ahead in " "$TRUMPCOUNT" " polls out of " "$TOTALCOUNT" " total polls."
fi
rm $(dirname "$0")/trumplc.txt
rm $(dirname "$0")/clintonlc.txt
rm $(dirname "$0")/data.txt
else              #This only runs if there cannot be internet connection established
    echo 'Cannot connect'
    exit 1
fi

