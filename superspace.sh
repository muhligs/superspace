#!/bin/bash  

# start prereqs (the program is initiated upon super space key sequence (system setting))
######################################################################
# empty ks.txt
> ~/key/ks.txt
# record all keys pressed and put into ks.txt
# here you have to make sure that the number corresponds to your keyboard.
# you could have multiple if external keyboards apply.
# test this with xinput -list
xinput test 9 > ~/key/ks.txt &
ID1=$!
# this is if you have a laptop keyboard as well
# xinput test 11 > ~/key/ks.txt & 
#ID2=$!
xdotool keyup "super+d"; #pretend the user let go of the super+d keys, else it interferes with ctrl-v  
######################################################################

# look in the last two lines of ~/key/ks.txt until a space is encountered
######################################################################
while :
do
    # TASK 1
#    date
 short=$(tail -2 ~/key/ks.txt | awk '{if($2=="press"){printf(","$3)}}' | grep -oh .*,65)
if [ -n "$short" ] ; then 
break
fi
done
######################################################################

# When a space was found, kill the listeners!!!
##############
kill $ID1
#kill $ID2
#################

# read everything in ~/key/ks.txt
######################################################################
# cat ~/key/ks.txt #(test line)
short=$(cat ~/key/ks.txt | awk '{if($2=="press"){printf(","$3)}}' | sed -r 's/(,65)+$/,e/' | sed -r 's/,/s,/')
######################################################################

# Check if you are in a a specific program where for some reason ctrl backspace wont work and we need sequential deletes (this needs updates for terminal)
######################################################################
# get the active window title
term=$(ps -e | grep $(xdotool getwindowpid $(xdotool getwindowfocus)) | grep -v grep | awk '{print $4}')
# check for 'terminal'
if [ "$term" = "gnome-terminal" ]
then
bspace=$(echo $short | awk --field-separator="," '{print(NF-1)}')
for i in $(seq 1 $bspace)
do
  xdotool key BackSpace
done
# check for 'Rstudio'
elif [ "$term" = "rstudio" ]
then
xdotool key "BackSpace";
xdotool key "ctrl+BackSpace";
else
xdotool key "ctrl+BackSpace";
# echo $term | tr -d "\n" | xsel -i -b; # (test line) put the date/time in the clipboard  
# xdotool key "ctrl+v"; # (test line) # simulate a ctrl-v  
fi

# if a [shift][?] (service sequence) is present, write the shortcut out.
######################################################################
qmtest=$(echo "$short" | grep 62,20,e)
if [ -n "$qmtest" ]
then
# remove the ? from the output
noqm=$(echo "$qmtest" | sed 's/,62,20//')
xsel --clipboard > ~/key/clip.txt
echo $noqm | tr -d "\n" | xsel -i -b; #put the date/time in the clipboard  
xdotool key "ctrl+v"; #simulate a ctrl-v  
xsel --clipboard < ~/key/clip.txt
fi
######################################################################

# match the content of ks.txt to the shortcut file and read what the matching shortcut translates to
######################################################################
out=$(grep $short /home/mmn/Dropbox/programming/scripts/keyboard/shorts | cut -f2)
######################################################################

# test for a script word in the beginning of the out variable and execute if found:
######################################################################
####################
testscript=$(echo "$out" | grep '^script') # look for 'script'
if [ -n "$testscript" ] # if found:
then
noscript=$(echo "$out" | sed 's/^script//') # chomp off 'script'
####################
testext=$(echo "$noscript" | grep '^ext') # look for 'ext' after 'script'
if [ -n "$testext" ] # if found:
then
noscript2=$(echo "$noscript" | sed 's/^ext//') # chomp off 'ext'
$noscript2 & 1>/dev/null 2>&1 # ...and execute whatever is behind (!!) but redirect all outputs to /dev/null
####################
else # if 'ext' not found we are interested in the output (e.g. 'date')
out2=$(eval echo $($noscript)) # read output of command
#xdotool type --delay 0 "$out2" # seems that xdotool type conflicts with rstudio and maybe kate. we try to use xclip instead. (old code using xdotool rahter than xclip. Kept for docu-reasons)
#echo $out2 # (test line)
echo $out2 | tr -d "\n" | xsel -i -b; # put the output to the clipboard clipboard (note to self: rescue clip content as below)  
xdotool key "ctrl+v"; #simulate a ctrl-v  
###################
fi # endif 'script'
#eval echo "$noscript &" # (test line)
# out2=$(eval echo $($noscript))# # (old code using xdotool rahter than xclip. Kept for docu-reasons)
# xdotool type --delay 0 "$out2"# # (old code using xdotool rahter than xclip. Kept for docu-reasons)
fi # endif 'ext'
######################################################################

# if script was not found, just execute the typing
######################################################################
if [ -n "$out" ] && ! [ -n "$testscript" ]
then
# echo "hw" # (test line)
xsel --clipboard > ~/key/clip.txt # rescue clip board
# echo -e $out | tr -d "\n" | xsel -i -b; # put the content in the clipboard # (old procedure, not efficient)
# sleep 0.2 (was once needed)
echo -e -n $out | xsel -i -b; # put the content in the clipboard    
sleep 0.2 # needed for some reason
xdotool key "ctrl+v"; #simulate a ctrl-v  
sleep 0.2 # needed for some reason
xsel --clipboard < ~/key/clip.txt # re-generate the clipboard
fi


