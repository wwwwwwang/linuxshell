#!/bin/sh
cd `dirname $0`

function changevalue(){
    local key=$3
    local value=$4
    local file=$2
    local type=$1
    result=$(echo "${value}" | grep "&")
    if [[ "$result" != ""  ]];then
    value=${value//&/\&}
    fi
    sed -i "s%^$key=.*$%$key=$value%" $file
    echo "$type ----> In $file, $key value changes to "$value
}

#url=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;;s%\?.*%%" config.cfg`
url=`sed "/^db.mysql.url=/!d;s%[^=]*=%%" config.cfg`
user=`sed '/^db.mysql.user=/!d;s%.*=%%' config.cfg`
passwd=`sed '/^db.mysql.password=/!d;s%.*=%%' config.cfg`
oozie=`sed '/^oozie=/!d;s%.*=%%' config.cfg`
namenode=`sed '/^nameNode=/!d;s%.*=%%' config.cfg`
jobtracker=`sed '/^jobTracker=/!d;s%.*=%%' config.cfg`
host=`sed '/^host=/!d;s%.*=%%' config.cfg`
hostname=`sed '/^hostName=/!d;s%.*=%%' config.cfg`
etlpath=`sed "/^etl.path=/!d;s%.*=%%" config.cfg`
bcbpath=`sed '/^bdr-command-bootstrap.path=/!d;s%.*=%%' config.cfg`
lcpath=`sed '/^log-collector.path=/!d;s%.*=%%' config.cfg`
fwpath=`sed '/^file-watcher.path/!d;s%.*=%%' config.cfg`
lsspath=`sed '/^log-save-server.path=/!d;s%.*=%%' config.cfg`
ojcpath=`sed '/^oozie-java-client.path=/!d;s%.*=%%' config.cfg`
swpath=`sed '/^sqoop_web.path=/!d;s%.*=%%' config.cfg`
mlpath=`sed '/^ml.path=/!d;s%.*=%%' config.cfg`

function bdb(){
    echo "bdr-command-bootstrap start..."
    fport=`sed '/^flume.pubsub.port=/!d;s%.*=%%' config.cfg`
    fpath=`sed '/^flume.program.path=/!d;s%.*=%%' config.cfg`
    cd $bcbpath
    dos2unix ./bin/*.sh
    changevalue "bdr-command-bootstrap" "conf/conn.properties" "flume.pubsub.port" $fport
    changevalue "bdr-command-bootstrap" "conf/conn.properties" "flume.program.path" $fpath
    cd -
    echo "bdr-command-bootstrap end.."
}

function lc(){
    echo "log-collector start.."
    lcname=`sed '/^db.mysql.agent.name=/!d;s%.*=%%' config.cfg`
    lctarget=`sed '/^sender.target=/!d;s%.*=%%' config.cfg`
    lcpartition=`sed '/kafka.producer.sender.partition=/!d' config.cfg`
    lcbrokerlist=`sed '/^log.kafka.broker.list=/!d;s%.*=%%' config.cfg`
    lclogs=`sed '/^avato.logs=/!d;s%.*=%%' config.cfg`
    lcfilepath=`sed '/avato.csv.file.path=/!d;s%.*=%%' config.cfg`
    lchdfspath=`sed '/^avato.csv.hdfs.path=/!d;s%.*=%%' config.cfg`
    lcdbname=`sed '/^avato.csv.db.name=/!d;s%.*=%%' config.cfg`
    lcreply=`sed '/^generaludp.receiver.replyOrNo=/!d;s%.*=%%' config.cfg`
    cd $lcpath
    dos2unix ./bin/*.sh
    changevalue "log-collector" "conf/conn.properties" "db.mysql.url" $url
    changevalue "log-collector" "conf/conn.properties" "db.mysql.user" $user
    changevalue "log-collector" "conf/conn.properties" "db.mysql.password" $passwd
    changevalue "log-collector" "conf/conn.properties" "db.mysql.agent.name" $lcname
    changevalue "log-collector" "conf/conn.properties" "sender.target" $lctarget
    echo "tlcpartition="$tlcpartition
    result=$(echo "${tlcpartition}" | grep "#")
    if [[ "$result" = "" ]]; then
      sed -i "s%$tlcpartition%#$tlcpartition%g" conf/conn.properties
    fi
    echo "log-collector ----> conf/conn.properties kafka.producer.sender.partition changed to start with #"
    changevalue "log-collector" "conf/conn.properties" "kafka.broker.list" $lcbrokerlist
    changevalue "log-collector" "conf/conn.properties" "generaludp.receiver.replyOrNo" $lcreply
    changevalue "log-collector" "conf/conn.properties" "log.kafka.broker.list" $lcbrokerlist
    changevalue "log-collector" "conf/conn.properties" "avato.logs" $lclogs
    if [[ "x$lclogs" != "x" ]]; then
      changevalue "log-collector" "conf/conn.properties" "avato.csv.file.path" $lcfilepath
      mkdir "$lcfilepath"
      changevalue "log-collector" "conf/conn.properties" "avato.csv.hdfs.path" $lchdfspath
      hdfs dfs -mkdir -p "$lchdfspath"
      changevalue "log-collector" "conf/conn.properties" "avato.csv.db.name" $lcdbname
      changevalue "log-collector" "conf/conn.properties" "avato.csv.oozie.url" $oozie
      sed -i "s%<host>oozie@.*</host>%<host>oozie@$hostname</host>%" conf/arvatoreceiver/workflow.xml
      echo "log-collector ----> conf/arvatoreceiver/workflow.xml hostname changed to "$hostname
      hdfs dfs -mkdir -p /user/oozie/examples/apps
      hdfs dfs -put -f conf/arvatoreceiver /user/oozie/examples/apps
      changevalue "log-collector" "conf/conn.properties" "avato.csv.log.kafka.broker.list" $lcbrokerlist
    fi
    cd -
    echo "log-collector end.."
}

function lss(){
    echo "log-save-server start.."
    zookeeper=`sed '/^kafka.zookeeper=/!d;s%.*=%%' config.cfg`
    cd $lsspath
    dos2unix *.sh *.cfg
    kafka-topics --create --zookeeper $zookeeper --replication-factor 1 --partitions 1 --topic task_status_log
    changevalue "log-save-server" "config/conn.properties" "db.mysql.url" $url
    changevalue "log-save-server" "config/conn.properties" "db.mysql.user" $user
    changevalue "log-save-server" "config/conn.properties" "db.mysql.password" $passwd
    cd -
    echo "log-save-server end.."
}

function etl(){
    echo "etl start.."
	mapip=`sed '/^mapreduce.jobtracker.ip=/!d;s%.*=%%' config.cfg`
	yarnip=`sed '/^yarn.resourcemanager.ip=/!d;s%.*=%%' config.cfg`
	zookeeper=`sed '/^db.hbase.zookeeper_quorm=/!d;s%.*=%%' config.cfg`
    cd $etlpath
    dos2unix *.sh *.cfg
    chmod -R 755 $etlpath
    cp lib/mysql*.jar lib/ojdbc*.jar /opt/cloudera/parcels/CDH/lib/spark/lib/ -f
    changevalue "etl" "config/conn.properties" "db.mysql.url" $url
    changevalue "etl" "config/conn.properties" "db.mysql.user" $user
    changevalue "etl" "config/conn.properties" "db.mysql.password" $passwd
	changevalue "etl" "config/conn.properties" "mapreduce.jobtracker.ip" $mapip
	changevalue "etl" "config/conn.properties" "yarn.resourcemanager.ip" $yarnip
	changevalue "etl" "config/conn.properties" "db.hbase.zookeeper_quorm" $zookeeper
    cd -
    echo "etl end.."
}

function ml(){
    echo "ml start.."
    cd $mlpath
    chmod -R 755 $mlpath
    dos2unix *.sh *.cfg
    changevalue "machine-learning" "config/mysql.properties" "db.mysql.url" $url
    changevalue "machine-learning" "config/mysql.properties" "db.mysql.user" $user
    changevalue "machine-learning" "config/mysql.properties" "db.mysql.password" $passwd
    cd -
    echo "ml end.."
}

function ojc(){
    echo "oozie-java-client start.."
    cd $ojcpath
    dos2unix *.sh
    dos2unix file/*.sh
    cp -f file/batch.sh file/etl.sh $etlpath
    hadoop fs -mkdir /user/oozie/examples/apps/
    hdfs dfs -put -f file/kill.sh /user/oozie
    hdfs dfs -put -f file/shell /user/oozie/examples/apps/
    hdfs dfs -put -f file/sshWithParameters1 /user/oozie/examples/apps/
    hdfs dfs -put -f file/sshWithParameters2 /user/oozie/examples/apps/
    hdfs dfs -put -f file/cron /user/oozie/examples/apps/
    changevalue "oozie-java-client" "config/conn.properties" "db.mysql.url" $url
    changevalue "oozie-java-client" "config/conn.properties" "db.mysql.user" $user
    changevalue "oozie-java-client" "config/conn.properties" "db.mysql.password" $passwd
    changevalue "oozie-java-client" "config/conn.properties" "oozie" $oozie
    changevalue "oozie-java-client" "config/conn.properties" "nameNode" $namenode
    changevalue "oozie-java-client" "config/conn.properties" "jobTracker" $jobtracker
    changevalue "oozie-java-client" "config/conn.properties" "oozie.ml.add" $host
    sed -i "s%^oozie.ml.path=.*$%oozie.ml.path=$namenode/user/oozie/examples/apps/sshWithParameters2%" config/conn.properties
    echo "oozie-java-client ----> config/conn.properties oozie.ml.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters2
    sed -i "s%^oozie.ml.command=.*$%oozie.ml.command=$mlpath/train.sh%" config/conn.properties
	echo "oozie-java-client ----> config/conn.properties oozie.ml.command changed to"$mlpath/train.sh
	changevalue "oozie-java-client" "config/conn.properties" "oozie.batch.add" $host
    sed -i "s%^oozie.batch.path=.*$%oozie.batch.path=$namenode/user/oozie/examples/apps/sshWithParameters1%" config/conn.properties
    echo "oozie-java-client ----> config/conn.properties oozie.batch.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters1
    sed -i "s%^oozie.batch.command=.*$%oozie.batch.command=$etlpath/batch.sh%" config/conn.properties
	echo "oozie-java-client ----> config/conn.properties oozie.batch.command changed to"$etlpath/batch.sh
	changevalue "oozie-java-client" "config/conn.properties" "oozie.etl.add" $host
    sed -i "s%^oozie.etl.path=.*$%oozie.etl.path=$namenode/user/oozie/examples/apps/sshWithParameters1%" config/conn.properties
    echo "oozie-java-client ----> config/conn.properties oozie.etl.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters1
    sed -i "s%^oozie.etl.command=.*$%oozie.etl.command=$etlpath/start.sh%" config/conn.properties
	echo "oozie-java-client ----> config/conn.properties oozie.etl.command changed to"$etlpath/start.sh
	changevalue "oozie-java-client" "config/conn.properties" "oozie.mlPredict.add" $host
    sed -i "s%^oozie.mlPredict.path=.*$%oozie.mlPredict.path=$namenode/user/oozie/examples/apps/sshWithParameters1%" config/conn.properties
    echo "oozie-java-client ----> conf/conn.properties oozie.mlPredict.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters1
    sed -i "s%^oozie.mlPredict.command=.*$%oozie.mlPredict.command=$mlpath/Predict.sh%" config/conn.properties
	echo "oozie-java-client ----> config/conn.properties oozie.mlPredict.command changed to"$mlpath/Predict.sh
	sed -i "s%^oozie.coordinator.workflowAppUri=.*$%oozie.coordinator.workflowAppUri=$namenode/user/oozie/examples/apps/cron%" config/conn.properties
    echo "oozie-java-client ----> conf/conn.properties oozie.coordinator.workflowAppUri changed to"$namenode/user/oozie/examples/apps/cron   
   cd -
    echo "oozie-java-client end.."
}

function fw(){
    echo "file-watcher start.."
    cd $fwpath
    dos2unix *.sh
    chmod -R 755 $fwpath
    changevalue "file-watcher" "config/conn.properties" "db.mysql.url" $url
    changevalue "file-watcher" "config/conn.properties" "db.mysql.user" $user
    changevalue "file-watcher" "config/conn.properties" "db.mysql.password" $passwd
    cd -
    echo "file-watcher end.."
}

function sw(){
    echo "sqoop_web start.."
    shivemetastore=`sed '/^hive.metastore.uris=/!d;s%.*=%%' config.cfg`
    sport=`sed '/^subscriber.command.port=/!d;s%.*=%%' config.cfg`
    cd $swpath
    dos2unix *.sh
    hdfs dfs -mkdir -p /user/oozie/examples/apps/sqoop_web/lib
    #hdfs dfs -put -f ooziefile/sqoop/job.properties /user/oozie/examples/apps/sqoop_web
    hdfs dfs -put -f ooziefile/sqoop/workflow.xml /user/oozie/examples/apps/sqoop_web
    hdfs dfs -put -f lib_to_hdfs/*.jar /user/oozie/examples/apps/sqoop_web/lib
    changevalue "sqoop_web" "config/conn.properties" "db.mysql.url" $url
    changevalue "sqoop_web" "config/conn.properties" "db.mysql.user" $user
    changevalue "sqoop_web" "config/conn.properties" "db.mysql.password" $passwd
    changevalue "sqoop_web" "config/conn.properties" "oozie.url" $oozie
    changevalue "sqoop_web" "config/conn.properties" "nameNode" $namenode
    changevalue "sqoop_web" "config/conn.properties" "jobTracker" $jobtracker
    changevalue "sqoop_web" "config/conn.properties" "subscriber.command.port" $sport
    sed -i "s%^oozie.app.path=.*$%oozie.app.path=$namenode/user/oozie/examples/apps/sqoop_web%" config/conn.properties
    echo "sqoop-web -----> config/conn.properties oozie.app.path changed to "$namenode"/user/oozie/examples/apps/sqoop_web"
    sed -i "s%^oozie.app.tag2hbase.path=.*$%oozie.app.tag2hbase.path=$namenode/user/oozie/examples/apps/tag2hbase%" config/conn.properties
    echo "sqoop-web -----> config/conn.properties oozie.app.tag2hbase.path changed to "$namenode/user/oozie/examples/apps/tag2hbase
    changevalue "sqoop_web" "config/conn.properties" "hive.metastore.uris" $shivemetastore
    sed -i "s%<host>oozie@.*</host>%<host>oozie@$hostname</host>%" ooziefile/tag2hbase/workflow.xml
    echo "sqoop-web -----> ooziefile/tag2hbase/workflow.xml hostname changed to "$hostname
    hdfs dfs -put -f ooziefile/tag2hbase /user/oozie/examples/apps
    cd -
    echo "sqoop_web end.."
}

function choose(){
    case $1 in
    1)  etl
    ;;
    2)  bdb
    ;;
    3)  lc
    ;;
    4)  fw
    ;;
    5)  lss
    ;;
    6)  ojc
    ;;
    7)  sw
    ;;
    8)  ml
    ;;
    *)  echo 'You do not select a right number between 1 to 8'
    ;;
    esac
}

echo "start......"
echo "Input the number of process u want to install: (concat by ',', like 1,2)"
echo "1.etl           2.bdr-command-bootstrap    3.log-collector"
echo "4.file-watcher  5.log-save-server          6.oozie-java-client"
echo "7.sqoop_web     8.machine-learning"
read options
var=${options//,/ }
for element in $var
do
    echo $element  
    choose $element
done
echo "followup end.."

