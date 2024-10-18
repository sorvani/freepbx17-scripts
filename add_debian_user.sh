#!/bin/bash

# This script is designed to be executed when you need to add another user to the FrePBX 17 host Debian system.

# collect the linux username and github username of the person runnning the script
read -p "Enter a new username to use for SSH access: " myUserName
read -p "Enter the github username for $myUserName: " myGitName

# Create user account with default password of ChangeMe
echo "Creating the user $myUserName and assigning permissions"
echo ""
useradd --create-home $myUserName --password $(openssl passwd -1 ChangeMe) --shell /bin/bash>> setup.log
# expire the password to force reset on first login
chage -d 0 $myUserName >> setup.log
# Add user to sudo
gpasswd -a $myUserName sudo >> setup.log
# Create the user's .ssh folder 
mkdir /home/$myUserName/.ssh
# Set permissions
chmod 700 /home/$myUserName/.ssh
# Create empty authorized_keys file
touch /home/$myUserName/.ssh/authorized_keys
# set permissions
chmod 600 /home/$myUserName/.ssh/authorized_keys
# execute ssh-key-sync to get the pub keys for this user
ssh-key-sync --github-user $myGitName --system-user $myUserName
chown -R $myUserName:$myUserName /home/$myUserName
