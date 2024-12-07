#!/bin/bash

set -e


# Set env vars for lua
export PROJECT_ROOT=$(pwd)
export LUA_PATH="$PROJECT_ROOT/src/?.lua;$PROJECT_ROOT/src/?/init.lua;$LUA_PATH"

# allow to override the lua binary
if [ -z "$LUA_BIN" ]; then
	LUA_BIN=lua
fi

# first argument is the day of the the advent of code challenge and has to be a number
if [ -z "$1" ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
	echo "Please provide a valid day number as the first argument"
	exit 1
fi
DAY=$1

# check if solution for day exists
if [ ! -f "src/days/day$DAY.lua" ]; then
	echo "Solution for day $DAY does not exist"
	exit 1
fi

# run solution
$LUA_BIN src/days/day$DAY.lua
