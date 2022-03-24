#!/bin/bash

#Treasure Hunt version 1.01 - The great bugfix





#Install sox for audio.

if [[ -e /usr/bin/sox ]]; then
echo "Sox is required for audio but was not found. Would you like to install it now?"
else
OPTIONS="Install Skip"
select opt in $OPTIONS; do
	if [[ "$opt" = "Install" ]]; then 
		echo "Installing. Please grant permission."
		sudo apt install sox
		break
	elif [ "$opt" = "Skip" ]; then
		echo "Okay."
		break
	else 
		echo "Invalid option."
		break
	fi
done
fi





#Clear screen before beginning game.
clear

#Set variably
LIVES=3
SCORE=0




#Welcoming the player and explaining the game.
path=$(pwd)
#Copy maps
echo "Please wait while maps load..."
cp -R ./Config/MapStorage/"map room" .
play -q $path/Sound/welcome.wav -t alsa
clear
echo "********************************************************************"
echo "*                  Welcome to Treasure Hunt!            by John S  *"
echo "*                                                                  *"
echo "* In this game you must explore the far reaches of the world       *"
echo "* to find treasure and become rich beyond your wildest dreams.    *"
echo "*                                                                  *"
echo "*                                                                  *"
echo "* You will have a limited amount of time to explore and           *"
echo "* collect gold.                                                    *"
echo "* You must collect as many coins as you can before the timer runs  *"
echo "* out to complete the game.                                        *"
echo "*                                                                  *"
echo "* Compete with your friends for the best score on the scoreboard!  *"
echo "********************************************************************"
echo ""

echo "Would you like to read the instructions?"
echo "(Enter a number and press enter.)"
OPTIONS="yes no"
select opt in $OPTIONS; do
	if [[ "$opt" = "yes" ]]; then 
		echo "You said yes"
		less $path/Config/instructions
		break
	elif [ "$opt" = "no" ]; then
		echo "Okay then, no instructions."
		break
	else 
		echo "That's not an option. Please enter one of the numbers listed and press enter"
		break
	fi
done

echo ""
echo "Do you want to view the scoreboard of previous players?"
echo "(Enter a number and press enter.)"
echo ""
OPTIONS="yes no"
select opt in $OPTIONS; do
	if [[ "$opt" = "yes" ]]; then 
		echo ""
		echo "These are the scores of those who came before you."
		cat $path/Config/scores
		break
	elif [ "$opt" = "no" ]; then
		echo "Alright, moving on."
		break
	else 
		echo "That's not an option. Please enter one of the numbers listed and press enter"
		break
	fi

done


echo ""
echo "Let's begin!"
echo ""
echo "What's your name?"
read NAME
echo ""
echo "Welcome to Treasure Hunt $NAME"
echo ""
echo "Press enter to begin!"
read WAIT
clear



#Select a map
cd "map room"
DIR=$(ls | grep '^[A-Z]')
echo "*************************************************************************"
echo "MAP SELECTION"
echo "The game will begin after you choose a map. You will have 3 minutes!"
echo "You are standing in the map selection room. The available maps are:"
echo ""
echo "$DIR"
echo ""
echo "Please type your selection:"
echo "(Remember to type your selection exactly as it appears and press enter.)"
echo ""
read OPTION
cd $OPTION

STARTTIME=$SECONDS





#Main game loop____________________________________________________________________________________________________________________
while [[ $TIME -lt 180 ]] && [[ $LIVES -gt 0 ]] 
do
clear
TIME=$(($SECONDS - $STARTTIME))
TIMELEFT=$((180 - $TIME)) 
DIR=$(ls | grep '^[A-Z]')
echo "********************************************************************"
echo "* TREASURE HUNT                                                    *"
echo "*  Player info >  Lives: $LIVES  Score: $SCORE    Time: $TIMELEFT  *"
echo "********************************************************************"
cat description
echo "********************************************************************"
ACTION=$(cat action)



#Death
if [[ $ACTION = "die" ]]
then
clear
play -q $path/Sound/die.wav -t alsa
LIVES=$(($LIVES - 1))
echo "********************************************************************"
echo "* TREASURE HUNT                                                    *"
echo "*  Player info >  Lives: $LIVES  Score: $SCORE    Time: $TIMELEFT  *"
echo "********************************************************************"
cat description
echo ""
echo "$NAME died!"
echo "-1 life"
echo "You have $LIVES lives left!"
if [[ $LIVES = 0 ]]
then
break
fi


echo "Press enter to respawn in the last room."
echo ""
echo "********************************************************************"
read WAIT
play -q $path/Sound/start.wav -t alsa
cd ..
DIR=$(ls | grep '^[A-Z]')
clear
echo "********************************************************************"
echo "* TREASURE HUNT                                                    *"
echo "*  Player info >  Lives: $LIVES  Score: $SCORE    Time: $TIMELEFT  *"
echo "********************************************************************"
cat description
echo "********************************************************************"
fi



#Coins found
if [[ $ACTION = "coin" ]]
then
clear
LOOT=$(($RANDOM%20+2))
SCORE=$(($SCORE + $LOOT))
echo "null" > action
echo "********************************************************************"
echo "* TREASURE HUNT                                                    *"
echo "*  Player info >  Lives: $LIVES  Score: $SCORE    Time: $TIMELEFT  *"
echo "********************************************************************"
cat description
echo "$NAME found $LOOT gold coins!"
echo "You now have $SCORE gold coins!"
play -q $path/Sound/coin.wav -t alsa
echo "********************************************************************"
fi


#Display options
UP="$(dirname "$(pwd)")"
LASTROOM=$( echo $UP | awk -F / '{print $NF}' )
echo ""
echo "Options are:"
echo "$DIR"
echo "$LASTROOM"
echo "Please type your selection:"
read OPTION
play -q $path/Sound/walk.wav -t alsa


#Move to selected room
if [[ $OPTION = $LASTROOM ]] 
then 
cd ..
else 
cd "$OPTION"
fi


done



if [[ $LIVES = 0 ]]
then
echo "You lost all your lives! Your obituary will be added to the"
echo "score board for all to see.                                "
echo ""
echo "Your obituary reads as follows:"
echo "On $(date +%D) $NAME died while looking for treasure. We will miss you. Coins lost at death: $SCORE"
echo "On $(date +%D) $NAME died while looking for treasure. We will miss you. Coins lost at death: $SCORE" >> $path/Config/scores 
echo ""
echo "SCOREBOARD________________________________________________"
cat $path/Config/scores
echo ""
echo "Better luck next time!"
echo ""
echo "Press enter to exit."
read WAIT
exit
else
	echo ""
	echo ""
	echo "*********************************************"
	echo ""
	echo "Congratulations $NAME, you finished the game!"
	echo "You collected a total of $SCORE coins!"
        echo "You finished the game with $LIVES lives left."
	echo""
	echo "Your score will be added to the board as:"
	echo "On $(date +%D) $NAME finished the game with a score of $SCORE"
	echo "On $(date +%D) $NAME finished the game with a score of $SCORE" >> $path/Config/scores
        echo ""
	echo "SCOREBOARD_______________________________________"
	cat $path/Config/scores

fi



echo "Press enter to exit."
read WAIT
exit






