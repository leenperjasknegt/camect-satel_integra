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
if python -c 'import pkgutil; exit(not pkgutil.find_loader("flask"))'; then
  echo
  echo "###################################################################"
  echo "Installing Wget"
  echo "###################################################################"
  echo
  sudo pip3 install flask
else
    echo "Flask already installed"
fi
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
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/app.py
wget https://raw.githubusercontent.com/leenperjasknegt/camect-satel_integra/main/flask.service
sudo mkdir /opt/camectapi
sudo mv demo.py /usr/local/lib/python3.8/dist-packages/IntegraPy/demo.py
sudo mv camect.service /etc/systemd/system/camect.service
sudo mv flask.service /etc/systemd/system/flask.service
sudo mv index.html /opt/camectapi/index.html
sudo mv setup.html /opt/camectapi/setup.html
sudo mv app.py /opt/camectapi/app.py
echo
echo
echo "###################################################################"
echo "Creating Camect & Webserver Service"
echo "###################################################################"
echo
sudo systemctl stop camect.service
sudo systemctl stop flask.service
sleep 1
sudo systemctl daemon-reload
sleep 1
sudo systemctl enable camect.service
sudo systemctl enable flask.service
echo

echo "###################################################################"
echo "Start Camect & Webserver Service"
echo "###################################################################"
echo
sleep 1
sudo systemctl start camect.service
echo
sudo systemctl start flask.service
echo
sleep 2
echo
sudo systemctl status camect.service
echo
sudo systemctl status flask.service
echo "###################################################################"
echo "INSTALLATION SUCCESFULL!"
echo "Please complete the setup at http://ip:81"
echo "###################################################################"
echo
echo
