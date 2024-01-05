#!/bin/sh

# usage:
# $LATEST=$(fetch_git_release("github.com/user/project"))
# wget https:://github.com/$LATEST
fetch_git_release() {
	local URL_RAW=$(curl -s -L $1/releases/latest | grep -i -B 2 "$2" | grep -m 1 "$3")
	local URL1=$(echo $URL_RAW | cut -d \" -f2)
	local URL2=$(echo $URL_RAW | cut -d \" -f4)
	if [[ "$URL1" == *"$3"* ]]; then
		echo $URL1
		return 0
	fi
	if [[ "$URL2" == *"$3"* ]]; then
		echo $URL2
		return 0
	fi
	
	local URL_RAW2A=$(curl -s -L $1/releases/latest | grep "expanded_assets" | sed 's/.*src=//' | sed 's/ .*//' | sed 's/"//g')
	local URL_RAW2=$(curl -s -L $URL_RAW2A | grep -i -B 2 "$2" | grep -m 1 "$3")
	local URL3=$(echo $URL_RAW2 | cut -d \" -f2)
	local URL4=$(echo $URL_RAW2 | cut -d \" -f4)

	if [[ "$URL3" == *"$3"* ]]; then
		echo $URL3
		return 0
	fi
	if [[ "$URL4" == *"$3"* ]]; then
		echo $URL4
		return 0
	fi
	
	return 1
	}

# $2 = "Source" $3 = "tar.gz"

fetch_git_release $1 $2 $3

