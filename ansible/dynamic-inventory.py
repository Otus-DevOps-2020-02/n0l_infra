#!/usr/bin/python
import json
import os
request = os.popen("gcloud compute instances list | awk '{print  $1, $4, $5}'").read()

ip_dict = {"app":{}, "db":{}}
for ip in request.split('\n')[1:-1]:
    if str(ip.split(' ')[0]).endswith("app"):
         ip_dict["app"]["hosts"]=[str(ip.split(' ')[2])]
    else:
         ip_dict["db"]["hosts"]=[str(ip.split(' ')[2])]
         ip_dict["app"]["vars"]={"db_ip":str(ip.split(' ')[1])}

data = ip_dict


json_data = json.dumps(data)
print(json_data)


