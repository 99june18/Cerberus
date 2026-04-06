#!/bin/sh

export PYTHONUNBUFFERED=1
 python3 run_script.py Cerberus.yaml > /root/Cerberus_script/run_status/log_Cerberus.log 2>&1 &

