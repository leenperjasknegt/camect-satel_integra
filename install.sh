#!/bin/bash

###################################################################
# API for connecting Camect with Satel Integra ETHM module.       #                                                                                                                                                                                     
# Author: JL                                                      #                            
###################################################################

sudo apt update
echo
if [ $(dpkg-query -W -f='${Status}' python3-pip 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo
  echo "###################################################################"
  echo "Installing Python3"
  echo "###################################################################"
  echo
  sudo apt-get -y install python3-pip;
fi
echo
if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo
  echo "###################################################################"
  echo "Installing Wget"
  echo "###################################################################"
  echo
  sudo apt install wget;
fi
echo
echo
echo "###################################################################"
echo "Installing Flask"
echo "###################################################################"
echo
sudo pip3 install flask
echo
echo
echo "###################################################################"
echo "Installing IntegraPy"
echo "###################################################################"
echo
sudo pip3 install IntegraPy
echo
echo "###################################################################"
echo "Downloading & copy files"
echo "###################################################################"
echo
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/camect.service
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/demo.py
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/templates/index.html
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/templates/setup.html
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/templates/status.html
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/app.py
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/config.json
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/setup.sh
sudo mkdir /opt/camectapi
sudo mkdir /opt/camectapi/templates
sudo mv setup.sh /opt/camectapi/setup.sh
sudo chmod +x /opt/camectapi/setup.sh


# Get the Python version
python_version=$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')

# Construct the destination directory path
dest_dir="/usr/local/lib/python${python_version}/dist-packages/IntegraPy"

# Move the file to the destination directory
sudo mv demo.py "${dest_dir}/demo.py"


#sudo mv demo.py /usr/local/lib/python3.8/dist-packages/IntegraPy/demo.py

sudo mv camect.service /etc/systemd/system/camect.service
sudo mv index.html /opt/camectapi/templates/index.html
sudo mv setup.html /opt/camectapi/templates/setup.html
sudo mv status.html /opt/camectapi/templates/status.html
sudo mv app.py /opt/camectapi/app.py
sudo mv config.json /opt/camectapi/config.json
echo
echo
echo "###################################################################"
echo "Creating Camect Service"
echo "###################################################################"
echo
sudo systemctl stop camect.service
sleep 2
sudo systemctl daemon-reload
sleep 1
sudo systemctl enable camect.service
echo

echo "###################################################################"
echo "Start Camect Service"
echo "###################################################################"
echo
sleep 1
sudo systemctl start camect.service
echo
sleep 2
echo
# Function to get IPv4 address
get_ipv4() {
    # Use ip command to get IPv4 address of non-loopback interface
    ip_address=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1 | head -n1)
    echo "$ip_address"
}

# Get the IPv4 address
ipv4=$(get_ipv4)


#sudo systemctl status camect.service
echo
echo -e "\e[1;42m ################################################################### \e[0m"
echo -e "\e[1;42m INSTALLATION SUCCESFULL! \e[0m"
# Check if IPv4 address is obtained successfully
if [ -n "$ipv4" ]; then
    echo "Please complete the setup: http://$ipv4:81"
else
    echo -e "\e[1;41m Failed to retrieve IPv4 address. \e[0m"
fi
#echo -e "\e[1;41m Please complete the setup at http://ip:81 \e[0m"
echo -e "\e[1;42m ################################################################### \e[0m"
echo
echo
sudo python3 /opt/camectapi/app.py

alias -p camect-setup='sudo python3 /opt/camectapi/app.py'
alias -p camect-status='sudo systemctl status camect.service'

# Define the first alias command
alias_command1="alias camect-setup='sudo python3 /opt/camectapi/app.py'"
# Define the second alias command
alias_command2="alias camect-status='sudo systemctl status camect.service'"

# Function to add an alias to .bashrc if it's not already present
add_alias_to_bashrc() {
    local alias_command="$1"
    if ! grep -qxF "$alias_command" ~/.bashrc; then
        echo "$alias_command" >> ~/.bashrc
        echo "Alias added to .bashrc"
    else
        echo "Alias already exists in .bashrc"
    fi
}

# Add the first alias command
add_alias_to_bashrc "$alias_command1"
# Add the second alias command
add_alias_to_bashrc "$alias_command2"

