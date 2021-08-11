#!/bin/bash
systemctl daemon-reload
cp /media/break/.rick_history /root/.bash_history
rm -rf /media/break
history -c
