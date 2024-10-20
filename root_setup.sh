#!/bin/bash
if [ "$EUID" -ne 0 ]
  then printf "This script must be executed with as the root user. Please run again after swithcing to root.\n"
  exit
fi

# This script is designed to be executed immediately after completing the installation of Debian, prior to doing anything with FreePBX 17.

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
# get the ssh-key-sync application form github
wget https://github.com/shoenig/ssh-key-sync/releases/download/v1.7.2/ssh-key-sync_1.7.2_linux_amd64.tar.gz
# install  ssh-key-syn
tar -C /usr/local/bin -xf ssh-key-sync_1.7.2_linux_amd64.tar.gz
# execute ssh-key-sync to get the pub keys for this user
ssh-key-sync --github-user $myGitName --system-user $myUserName
chown -R $myUserName:$myUserName /home/$myUserName

ipaddress=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

echo "Root setup complete."
echo "Please log out from the root user and login, via SSH to $ipaddress or the FQDN you have setup, with username: $myUserName."
echo "You will be required to change your password. It is currently set to: ChangeMe"
echo "You will be disconnected upon successfully setting your password."
echo "Log in again with SSH, switch to the root user, and run the FreePBX 17 installation script."
