#!/bin/bash

unameOut="$(uname -s)"

commands=(
	"cp ../build/index.js ./"
	"docker build -t example-v1 ."
	"docker save -o example-v1.tar example-v1"
	"chmod 666 example-v1.tar"
	"docker rmi example-v1")

case "${unameOut}" in
	Linux*)     machine=Linux;;
	Darwin*)    machine=Mac;;
	MINGW*)     machine=MinGW;;
	*)          machine="UNKNOWN:${unameOut}"
esac

for i in "${commands[@]}"; do
	if [ ${machine} == "Mac" ] || [ ${machine} == "Linux" ]; then
		sudo sh -c "$i"
	elif [ ${machine} == "MinGW" ]; then
		sh -c "$i"
	fi
done
