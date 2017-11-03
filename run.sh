#!/bin/bash
# Includes
. drawers.sh
. models.sh
. queue.sh
	
# Some consts
timeOutTime=0.03
run=0
# Logic
main(){
	# Setup terminal settings
	backgroundLetter=Q
	intColor $backgroundLetter
	background=$?
	stty -echo
	tput civis -- invisible
	tput setab $background
	tput clear
	
	# # Border
	# for((i=0;i<maxX;++i)); do
	# 	buff+="#"
	# done
	# echo -en "\e[0;0f$buff\e[$maxY;0f$buff"
	
	# Obstacle attributes
	init(){
	obstacleW=$((maxX/10))
	obstacleH=$((obstacleW/2))
	upperObstacleX=$((maxX/2))
	pUpperObstacleX=$upperObstacleX
	upperObstacleY=$((maxY/4-obstacleH/2))
	lowerObstacleX=$((maxX))	
	lowerObstacleY=$((3*maxY/4-obstacleH/2))	
	pLowerObstacleX=$lowerObstacleX
	score=-1
	level=0
	}
	init
	# Raptor attributes; Width, Height, etc
	dinoW=7
	dinoH=5
	# Raptor upperlimit, lowerLimit 
	upY=$((1*maxY/8))
	downY=$((maxY-dinoH-1*maxY/8))
	midY=$(((upY+downY)/2))
	dinoX=$obstacleW
	dinoY=$downY
	pDinoY=$dinoY
	dinoUy=0
	
	# realDinoY=$downY
	# halfG=5
	# t=0

	
	randomColor
	lowerObstacleColor=$?
	randomColor	
	upperObstacleColor=$?
	# renderQueuer &
	# renderQueuerPid=$?
	obstacleV=$((level+2))
	displayScore(){
		((score++))
		if ((score%5==0)); then		
			((level++))
			obstacleV=$((level+2))			
		fi
		x=$((maxX/2))
		y=$((maxY-2))
		echo -ne "\e[$((y-1));"$x"fLevel : $level"		
		echo -ne "\e[$y;"$x"fScore : $score"
	}
	
	x=$((maxX/2))
	y=$((maxY/2))
	tput civis -- invisible
	tput clear
	echo -ne "\e[$y;"$x"fEnter 1)To start game"
	echo ""
	((y=y+1))
	echo -ne "\e[$y;"$x"f       2)To quit"
	echo ""
	((y=y+1))
	echo -ne "\e[$y;"$x"f       press enter to save choices"
	read charGot
	case "$charGot" in 
			1)
				run=1
				;;
			2)
			   run=0
				;;
	esac
	((y=y+1))
	tput civis -- invisible
	tput setab $background
	tput clear
	modelSelection(){
	echo -ne "\e[$y;"$x"f       Enter model number"
	read Modelnum
	case $Modelnum in
	   1)   model="$marioModel"  ;;
	   2)    model="$rocketModelV" ;;
	   3)     model="$rocketModel" ;;
	esac
	tput clear
	}
	if [ $run -eq 1 ]
	then
	modelSelection
	drawModel $dinoX $dinoY "$model"
	displayScore
	fi
	while test $run -eq 1; do
		getChar $timeOutTime
		if [[ "$charGot" != "" ]]; then
			sleep $timeOutTime
		fi
		case "$charGot" in 
			"q")
				run=0
				;;
			"w")
			    echo -en "\a"
				if ((dinoY >= upY)); then
					dinoUy=-2
				fi
				;;
			"s")
				;;
		esac
		pDinoY=$dinoY
		((dinoY+=dinoUy))
		if ((dinoY > downY)); then
			dinoY=$downY		
			dinoUy=0
		fi
		if ((dinoY < upY)); then
			dinoY=$upY
			dinoUy=2
		fi
		if ((pDinoY!=dinoY)); then
			# updateModel $dinoX $dinoY $dinoX $pDinoY "$model" 
			updateModel $dinoX $dinoY $dinoX $pDinoY "$model"
		fi
		moveLeftSolidRect $lowerObstacleX $lowerObstacleY $pLowerObstacleX $lowerObstacleY $obstacleW $obstacleH $lowerObstacleColor
		# updateSolidRect $lowerObstacleX $lowerObstacleY $pLowerObstacleX $lowerObstacleY $obstacleW $obstacleH 2 &				
		pLowerObstacleX=$lowerObstacleX
		((lowerObstacleX-=obstacleV))
		if (( lowerObstacleX < -obstacleW-obstacleV)); then
			lowerObstacleX=$((maxX))
			randomColor
			lowerObstacleColor=$?
			displayScore			
		fi
		moveLeftSolidRect $upperObstacleX $upperObstacleY $pUpperObstacleX $upperObstacleY $obstacleW $obstacleH $upperObstacleColor	
		# updateSolidRect $upperObstacleX $upperObstacleY $pUpperObstacleX $upperObstacleY $obstacleW $obstacleH 2 &
		pUpperObstacleX=$upperObstacleX
		((upperObstacleX-=obstacleV))
		if (( upperObstacleX < -obstacleW-obstacleV)); then
			upperObstacleX=$((maxX))
			randomColor
			upperObstacleColor=$?
			displayScore						
		fi
		((x=dinoX+dinoW))
		((y=lowerObstacleX+2))
		((z=$lowerObstacleX+$obstacleW))
		if [ $x -gt $y ] && [ $dinoY -gt $lowerObstacleY ] || [ $dinoX -gt $z ] && [ $dinoY -gt $lowerObstacleY ];then
			# echo $dinoX $dinoW $lowerObstacleX
			run=0
		fi
		((y1=upperObstacleX+2))
		((z=$upperObstacleX+$obstacleW+1))
		if [ $x -gt $y1 ] && [ $dinoY -lt $upperObstacleY ] || [ $dinoX -gt $z ] && [ $dinoY -lt $upperObstacleY ];then
			# echo $dinoX $dinoW $lowerObstacleX
			run=0
		fi
		if [ $run -eq 0 ]
		then
		tput clear
		displayScore
		x=$((maxX/2))
		y=$((maxY/2))
		echo -ne "\e[$y;"$x"fEnter 1)To replay"
		echo ""
		((y=y+1))
		echo -ne "\e[$y;"$x"f       2)To quit"
		echo ""
		((y=y+1))
		echo -ne "\e[$y;"$x"f       press enter to save choices"
		read charGot
		tput clear
		case "$charGot" in 
				1)
					run=1
					init
					modelSelection
					tput clear
					;;
				2)
				run=0
					;;
		esac
		tput civis -- invisible
		tput clear
		if [ $run -eq 1 ]
		then
		drawModel $dinoX $dinoY "$model"
		init
		fi
		displayScore
		fi	
	done
	# kill $renderQueuerPid
	tput cnorm -- normal
	stty sane
}
# getChar timeout
# Saves key in charGot; Blocks for timeout amount of time
charGot=''
getChar(){
	charGot=''
	IFS= read -r -t $1 -n 1 -s holder && charGot="$holder"
}

# log into log file
log(){
	cat >> log <<< "$@"
}

renderQueuer(){
	while true; do
		qEmpty
		if [ $? -eq 0 ]; then
			qPop
			echo $qPopped
		fi
	done
}
main
