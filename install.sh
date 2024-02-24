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
sudo systemctl status camect.service
echo
echo "###################################################################"
echo "INSTALLATION SUCCESFULL!"
echo "Please complete the setup at http://ip:81"
echo "###################################################################"
echo
echo
sudo python3 /opt/camectapi/app.py
