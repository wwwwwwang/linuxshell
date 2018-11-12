#!/bin/bash  
echo "Input the number of process u want to install: (concat by ',', like 1,2)"
echo "1.etl           2.bdr-command-bootstrap    3.log-collector"
echo "4.file-watcher  5.log-save-server          6.oozie-java-client"
echo "7.sqoop_web     8.machine-learning"
read options  
var=${options//,/ }
for element in $var   
do  
    echo $element  
done 
