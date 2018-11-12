#!/bin/sh
echo "prepare start..."
etlpath=`sed "/^etl.path=/!d;s%.*=%%" config.cfg`
bcbpath=`sed '/^bdr-command-bootstrap.path=/!d;s%.*=%%' config.cfg`
lcpath=`sed '/^log-collector.path=/!d;s%.*=%%' config.cfg`
fwpath=`sed '/^file-watcher.path/!d;s%.*=%%' config.cfg`
lsspath=`sed '/^log-save-server.path=/!d;s%.*=%%' config.cfg`
ojcpath=`sed '/^oozie-java-client.path=/!d;s%.*=%%' config.cfg`
swpath=`sed '/^sqoop_web.path=/!d;s%.*=%%' config.cfg`
etllitepath=`sed '/^etl-lite.path=/!d;s%.*=%%' config.cfg`
mlpath=`sed '/^ml.path=/!d;s%.*=%%' config.cfg`

function makeEtlPath(){
    if [[ x"$1" != x ]]; then
        mkdir -p $1
        echo "the path "$1 " for $2 has been made...."
    else
        echo "the path for $2 is not set...."
    fi
}

function choose(){
    case $1 in
    1)  makeEtlPath $etlpath "etl"
    ;;
    2)  makeEtlPath $bcbpath "bdr-command-bootstrap"
    ;;
    3)  makeEtlPath $lcpath "log-collector"
    ;;
    4)  makeEtlPath $fwpath "file-watcher"
    ;;
    5)  makeEtlPath $lsspath "log-save-server"
    ;;
    6)  makeEtlPath $ojcpath "oozie-java-client"
    ;;
    7)  makeEtlPath $swpath "sqoop_web"
    ;;
    8)  makeEtlPath $mlpath "machine-learning"
    ;;
    9)  makeEtlPath $etllitepath "etl-lite"
    ;;
    *)  echo 'You do not select a right number between 1 to 9'
    ;;
    esac
}

echo "Input the number of process u want to install:\
 (concat by ',', like 1,2; \"X\" means will be removed)"
echo "1.etl             2.bdr-command-bootstrap X   3.log-collector"
echo "4.file-watcher    5.log-save-server           6.oozie-java-client X"
echo "7.sqoop_web    X  8.machine-learning          9.etl-lite"
read options
var=${options//,/ }
for element in $var
do
    echo $element  
    choose $element
done

echo "prepare end..."
