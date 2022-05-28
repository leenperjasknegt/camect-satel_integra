from pathlib import Path
import os
import re
from subprocess import check_output
import json
import time
import threading
import requests
from flask import Flask, request, render_template, url_for, redirect



app = Flask(__name__)


@app.route('/')
@app.route('/index')

def index():
    if mode == 'RUN':
        with open('/opt/camectapi/config.json') as f:
            conf_dict = json.load(f)
        return render_template('index.html', camect_url=conf_dict['camect_url'],
                                admin_pwd=conf_dict['admin_pwd'], integra_ip=conf_dict['integra_ip'], 
                                partition_name=conf_dict['partition_name'], zone_name=conf_dict['zone_name'], 
                                inverse_zone=conf_dict['inverse_zone'])


    else:
        return render_template("index.html", value='No Network')

@app.route('/setup', methods =["GET", "POST"])
def config():
    if request.method == "POST":
        camect_url = request.form.get("camect_url") 
        admin_pwd = request.form.get("admin_pwd")
        integra_ip = request.form.get("integra_ip") 
        partition_name = request.form.get("partition_name")
        zone_name = request.form.get("zone_name")
        inverse_zone = request.form.get("inverse_zone") 

        conf_dict = {"camect_url": camect_url, "admin_pwd": admin_pwd, "integra_ip": integra_ip, "partition_name": partition_name, "zone_name": zone_name, "inverse_zone": inverse_zone,}
        with open('/opt/camectapi/config.json', 'w') as f:
            json.dump(conf_dict, f)

# Read the Integra IP and edit the Systemd file with the correct IP
# Restart the Camect.service

        integraip = "sed -i '9c\ExecStart=/usr/bin/python3 -m IntegraPy.demo {0}' /etc/systemd/system/camect.service".format(integra_ip)
        inversezone = "sed -i '47c\    if integrapartition in armed_partitions and {0} integrazone in violated_zones :' /usr/local/lib/python3.8/dist-packages/IntegraPy/demo.py".format(inverse_zone)
        os.system(integraip)
        os.system(inversezone)
        os.system("sudo systemctl daemon-reload")
        os.system("sudo systemctl restart camect.service")
        return render_template("status.html", camect_url=camect_url, admin_pwd=admin_pwd, integra_ip=integra_ip, partition_name=partition_name, zone_name=zone_name, inverse_zone=inverse_zone)
    return render_template("setup.html")


if __name__ == '__main__':
    try:
        with open('/opt/camectapi/config.json') as f:
            config_dict = json.load(f)
        mode = 'RUN'
    except:
        mode = 'AP'
    
    app.run(host='0.0.0.0', port=81)
