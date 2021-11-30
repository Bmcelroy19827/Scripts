#!/bin/bash

# script to open an ssh tunnel 


function showUsage() {
   echo ""
   echo ""
   echo "Usage:   "
   echo "      ${0} [-h] [-p] [-f]"
   echo ""
   echo "-h               This help"
   echo "-p               Open the tunnel to the production database"
   echo "-f               Prompts for file name [id_rsa]" 
   echo "-L               Prompts for file location [~/.ssh]"
   echo ""
   echo ""
   exit 1
}

# First Argument is expected to be the color of the text and the second argument is the message to echo
function echoColor() {
  case "$1" in
    'red')     cn='31'
               ;;
    'green')   cn='32'
               ;;
    'yellow')  cn='33'
               ;;
    'blue')    cn='34'
               ;;
   esac

   msg=$2
   echo $'\e[0;'${cn:-'33'}$'m'${msg:-"Default Message"}$'\e[0m'

}

while getopts ':hpfL' flag; do
  case "${flag}" in
    h) showUsage
       ;;
    f) option_f='true'
       ;;
    p) production='true'
       ;;
    L) option_L='true'
       ;;
    *) echo "Unexpected option: -${OPTARG}."
       showUsage
       ;;
  esac
done

# Testing for a string length not equal to zero (meaning it has an assigned value)
if [[ -n "${option_f}" ]]; then
  echo "Enter the file name to use for the ssh tunnel [id_rsa]"
  # Store the user supplied file name in a variable named 'file'
  # If they juse hit enter, then nothing gets stored
  read file
  custom = 'true'
fi

if [[ -n "$option_L" ]]; then
  echo "Enter the file location of the ssh key [~/.ssh]"

  read location
  custom = 'true'
fi

if [[ -n "${custom}" ]]; then  
  eval $(ssh-agent)

  # if file has been assigned then use the assigned value - otherwise use 'id_rsa'
  ssh-add ${location:-'~/.ssh'}/${file:-'id_rsa'}
fi


# checking that the -p flag was not entered
if [[ -z "${production}" ]]; then
  echoColor "yellow" "Opening New Test Tunnel"
  ssh -fNg -o ExitOnForwardFailure=yes -L 3307:127.0.0.1:3306 <user name>@<address (ex. 192.168.1.145)>
else
  echoColor "yellow" "Opening New Production Tunnel"
  ssh -fNg -o ExitOnForwardFailure=yes  -L < (can not remember this exactly I believe it is going through one port and in another) 3308:127.0.0.1:3306> <user name>@<address>
fi

# checking the value returned by the ssh call - 0 is a success, everything else is some sort of failure
if (( $? == 0 )); then
   echoColor "green" "SUCCESS!"
else
   echoColor "red" "New Connection Failed"
fi