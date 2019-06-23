#!/bin/bash

gpg_loc=~/.gnupg
gpg_conf_file="gpg.conf"
gpg_keyserver="pgp.key-server.io"

usage_stmt="usage: bash ${0##*/} <e-mail for gpg import>"

if [ -z "$1" ]; then
    echo $usage_stmt
    exit 1
else
    import_key_email="$1"
    if [[ ! $import_key_email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
        echo $usage_stmt
        echo "please enter a legitimate e-mail address"
        exit 3
    fi
fi

if [ -d ~/.gnupg ]; then 
    folder=~/.gnupg.orig
    if [ ! -d $folder ]; then
        mv ~/.gnupg $folder
    else
        count=0
        while [ -d $folder.$count ]; do
            count=$(( $count + 1 ))
        done
        mv ~/.gnupg $folder.$count
    fi
    echo ~/.gnupg" folder already exists, backed it up to $folder.$count"
fi


echo "checking if required packages are installed..."
packages_needed=false
packages=(curl gnupg2 gnupg-agent scdaemon pcscd pcsc-tools wget dirmngr)
for pkg in ${packages[@]}; do
    dpkg -s $pkg 2>/dev/null 1>&2 
    if [ $? -ne 0 ]; then
        packages_needed=true
        break
    fi
done

if [ $packages_needed = false ]; then
    echo "found all required packages"
else
    echo "installing required packages..."
    sudo apt-get update 2>/dev/null 1>&2  && sudo apt-get install -y ${packages[@]} 2>/dev/null 1>&2 
    if [ $? -ne 0 ]; then
        echo "failed to complete updates and/or package installation, exiting..."
        exit 2
    fi
fi

#need this if getting the gpg public key from a USB backup key
#sudo apt-get install cryptsetup

mkdir $gpg_loc
chmod 700 $gpg_loc

#found $gpg_conf_file in this directory
gpg_file=$(find -name $gpg_conf_file | head -n1 )
if [ ! -z $gpg_file ]; then
    echo "using $gpg_file for config"
    cp $gpg_file $gpg_loc/$gpg_conf_file
    chmod 600 $gpg_loc/$gpg_conf_file
else
    echo "getting $gpg_conf_file from github"
    wget https://raw.githubusercontent.com/drduh/config/master/$gpg_conf_file -O $gpg_loc/$gpg_conf_file
    chmod 600 $gpg_loc/$gpg_conf_file
fi

gpg --keyserver $gpg_keyserver --search-keys $import_key_email
if [ "$?" != '0' ]; then
    echo "failed to complete key import, exiting..."
    exit 3
else
    echo "success"
fi
echo $'\nhere is the current state of the key database:'
gpg2 --fingerprint
echo $'\nupdating trust to ultimate for first key installed.'
fingerprint=$(gpg2 --fingerprint | grep fingerprint | sed 's/^.*= //' | sed 's/ //g' | head -n1)
echo $fingerprint:6: | gpg2 --import-ownertrust -
echo $'\nhere is the new state of the key database:'
gpg2 --fingerprint


gpg_agent_conf_file="gpg-agent.conf"
gpg_agent_file=$(find -name $gpg_agent_conf_file | head -n1)
if [ ! -z $gpg_agent_file ]; then
    echo "using $gpg_agent_file for config"
    cp $gpg_agent_file $gpg_loc/$gpg_agent_conf_file
else
    echo "getting $gpg_agent_file from github"
    wget https://raw.githubusercontent.com/drduh/config/master/$gpg_agent_conf_file -O $gpg_loc/$gpg_agent_conf_file
fi

echo "checking .bashrc file..."
cat ~/.bashrc | grep 'gpg-agent' 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "found 'gpg-agent' in .bashrc file already..."
else
    echo "adding gpg-agent to .bashrc file"
    cat .bash_gpgagent >> ~/.bashrc
fi

if [ -f ~/.zshrc ]; then
    cat ~/.zshrc | grep 'gpg-agent' 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
    echo "found 'gpg-agent' in .zshrc file already..."
    else
        echo "adding gpg-agent to .zshrc file"
	cat .bash_gpgagent >> ~/.zshrc
    fi
fi

echo "restarting agents"
pkill ssh-agent
pkill gpg-agent

echo "recommend logging into a new shell or sourcing .bashrc before testing"
echo "also, since this script points the active tty to the current window when .bashrc is run, if using multiple console windows, you will need to source .bashrc again in the active window before utilzing the gpg-agent backend (such as smart card unlock), unless the active window is the last one opened."
