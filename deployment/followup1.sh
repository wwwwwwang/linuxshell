#!/bin/sh
cd `dirname $0`
echo "start......"
url=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;;s%\?.*%%" config.cfg`
user=`sed '/^db.mysql.user=/!d;s%.*=%%' config.cfg`
passwd=`sed '/^db.mysql.password=/!d;s%.*=%%' config.cfg`
oozie=`sed '/^oozie=/!d;s%.*=%%' config.cfg`
namenode=`sed '/^nameNode=/!d;s%.*=%%' config.cfg`
jobtracker=`sed '/^jobTracker=/!d;s%.*=%%' config.cfg`
host=`sed '/^host=/!d;s%.*=%%' config.cfg`
hostname=`sed '/^hostName=/!d;s%.*=%%' config.cfg`

echo "bdr-command-bootstrap start..."
fport=`sed '/^flume.pubsub.port=/!d;s%.*=%%' config.cfg`
fpath=`sed '/^flume.program.path=/!d;s%.*=%%' config.cfg`
cd /opt/bdr-command-bootstrap
dos2unix ./bin/*.sh
tfport=`sed '/^flume.pubsub.port=/!d;s%.*=%%' conf/conn.properties`
tfpath=`sed '/^flume.program.path=/!d;s%.*=%%' conf/conn.properties`
if [[ "$tfport" != "$fport" ]]; then
sed -i "s%$tfport%$fport%g" conf/conn.properties
fi
echo "bdr-command-bootstrap -----> conf/conn.properties flume.pubsub.port changed to "$fport
if [[ "$tfpath" != "$fpath" ]]; then
sed -i "s%$tfpath%$fpath%g" conf/conn.properties
fi
echo "bdr-command-bootstrap -----> conf/conn.properties flume.program.path changed to "$fpath
cd -
echo "bdr-command-bootstrap end.."

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
cd /opt/log-collector
dos2unix ./bin/*.sh
tlcurl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" conf/conn.properties`
tlcuser=`sed '/^db.mysql.user=/!d;s%.*=%%' conf/conn.properties`
tlcpasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' conf/conn.properties`
tlcname=`sed '/^db.mysql.agent.name=/!d;s%.*=%%' conf/conn.properties`
tlctarget=`sed '/^sender.target=/!d;s%.*=%%' conf/conn.properties`
tlcpartition=`sed '/kafka.producer.sender.partition=/!d' conf/conn.properties`
tlcbrokerlist=`sed '/^kafka.broker.list=/!d;s%.*=%%' conf/conn.properties`
if [[ "$tlcurl" != "$url" ]]; then
sed -i "s%$tlcurl%$url%g" conf/conn.properties
fi
echo "log-collector -----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$tlcuser" != "$user" ]]; then
sed -i "s%db.mysql.user=$tlcuser%db.mysql.user=$user%" conf/conn.properties
fi
echo "log-collector -----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$tlcpasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tlcpasswd%db.mysql.password=$passwd%" conf/conn.properties
fi
echo "log-collector -----> conf/conn.properties db.mysql.password changed to "$passwd
if [[ "$tlcname" != "$lcname" ]]; then
sed -i "s%$tlcname%$lcname%g" conf/conn.properties
fi
echo "log-collector -----> conf/conn.properties db.mysql.agent.name changed to "$lcname
if [[ "$tlctarget" != "$lctarget" ]]; then
sed -i "s%$tlctarget%$lctarget%g" conf/conn.properties
fi
echo "log-collector -----> conf/conn.properties sender.target changed to "$lctarget
echo "tlcpartition="$tlcpartition
result=$(echo "${tlcpartition}" | grep "#")
if [[ "$result" = "" ]]; then
sed -i "s%$tlcpartition%#$tlcpartition%g" conf/conn.properties
fi
echo "log-collector ----> conf/conn.properties kafka.producer.sender.partition changed to start with #"
if [[ "$tlcbrokerlist" != "$lcbrokerlist" ]]; then
sed -i "s%^kafka.broker.list=$tlcbrokerlist%kafka.broker.list=$lcbrokerlist%g" conf/conn.properties
fi
echo "log-collector ----> conf/conn.properties kafka.broker.list changed to "$lcbrokerlist
sed -i "s%^generaludp.receiver.replyOrNo=.*$%generaludp.receiver.replyOrNo=$lcreply%g" conf/conn.properties
echo "log-collector ----> conf/conn.properties generaludp.receiver.replyOrNo changed to "$lcreply

sed -i "s%^log.kafka.broker.list=.*$%log.kafka.broker.list=$lcbrokerlist%g" conf/conn.properties
echo "log-collector ----> conf/conn.properties log.kafka.broker.list changed to "$lcbrokerlist
sed -i "s%^avato.logs=.*$%avato.logs=$lclogs%" conf/conn.properties
echo "log-collector ----> conf/conn.properties avato.logs changed to "$lclogs
if [[ "x$lclogs" != "x" ]]; then
sed -i "s%^avato.csv.file.path=.*$%avato.csv.file.path=$lcfilepath%" conf/conn.properties
echo "log-collector ----> conf/conn.properties avato.csv.file.path changed to "$lcfilepath
mkdir "$lcfilepath"
sed -i "s%^avato.csv.hdfs.path=.*$%avato.csv.hdfs.path=$lchdfspath%" conf/conn.properties
echo "log-collector ----> conf/conn.properties avato.csv.hdfs.path changed to "$lchdfspath
hdfs dfs -mkdir -p "$lchdfspath"
sed -i "s%^avato.csv.db.name=.*$%avato.csv.db.name=$lcdbname%" conf/conn.properties
echo "log-collector ----> conf/conn.properties avato.csv.db.name changed to "$lcdbname
sed -i "s%^avato.csv.oozie.url=.*$%avato.csv.oozie.url=$oozie%" conf/conn.properties
echo "log-collector ----> conf/conn.properties avato.csv.oozie.url changed to "$oozie
sed -i "s%<host>oozie@.*</host>%<host>oozie@$hostname</host>%" conf/arvatoreceiver/workflow.xml
echo "log-collector ----> conf/arvatoreceiver/workflow.xml hostname changed to "$hostname
hdfs dfs -mkdir -p /user/oozie/examples/apps
hdfs dfs -put -f conf/arvatoreceiver /user/oozie/examples/apps
sed -i "s%^avato.csv.log.kafka.broker.list=.*$%avato.csv.log.kafka.broker.list=$lcbrokerlist%g" conf/conn.properties
echo "log-collector ----> conf/conn.properties avato.csv.log.kafka.broker.list changed to "$lcbrokerlist
fi
cd -
echo "log-collector end.."

echo "log-save-server start.."
zookeeper=`sed '/^kafka.zookeeper=/!d;s%.*=%%' config.cfg`
cd /opt/log-save-server
dos2unix *.sh *.cfg
kafka-topics --create --zookeeper $zookeeper --replication-factor 1 --partitions 1 --topic task_status_log
tlsurl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" config/conn.properties`
tlsuser=`sed '/^db.mysql.user=/!d;s%.*=%%' config/conn.properties`
tlspasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' config/conn.properties`
if [[ "$tlsurl" != "$url" ]]; then
sed -i "s%$tlsurl%$url%g" config/conn.properties
fi
echo "log-save-server ----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$tlsuser" != "$user" ]]; then
sed -i "s%db.mysql.user=$tlsuser%db.mysql.user=$user%" config/conn.properties
fi
echo "log-save-server ----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$tlspasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tlspasswd%db.mysql.password=$passwd%" config/conn.properties
fi
echo "log-save-server ----> conf/conn.properties db.mysql.password changed to "$passwd
cd -
echo "log-save-server end.."

echo "etl start.."
cd /opt/etl
dos2unix *.sh *.cfg
cp lib/mysql*.jar lib/ojdbc*.jar /opt/cloudera/parcels/CDH/lib/spark/lib/ -f
teurl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" config/mysql.properties`
teuser=`sed '/^db.mysql.user=/!d;s%.*=%%' config/mysql.properties`
tepasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' config/mysql.properties`
if [[ "$teurl" != "$url" ]]; then
sed -i "s%$teurl%$url%g" config/mysql.properties
fi
echo "etl -----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$teuser" != "$user" ]]; then
sed -i "s%db.mysql.user=$teuser%db.mysql.user=$user%" config/mysql.properties
fi
echo "etl -----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$tepasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tepasswd%db.mysql.password=$passwd%" config/mysql.properties
fi
echo "etl ----> conf/conn.properties db.mysql.password changed to "$passwd
cd -
echo "etl end.."

echo "ml start.."
cd /opt/ml
dos2unix *.sh *.cfg
tmurl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" config/mysql.properties`
tmuser=`sed '/^db.mysql.user=/!d;s%.*=%%' config/mysql.properties`
tmpasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' config/mysql.properties`
if [[ "$tmurl" != "$url" ]]; then
sed -i "s%$tmurl%$url%g" config/mysql.properties
fi
echo "ml -----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$tmuser" != "$user" ]]; then
sed -i "s%db.mysql.user=$tmuser%db.mysql.user=$user%" config/mysql.properties
fi
echo "ml -----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$tmpasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tmpasswd%db.mysql.password=$passwd%" config/mysql.properties
fi
echo "ml ----> conf/conn.properties db.mysql.password changed to "$passwd
cd -
echo "ml end.."

echo "oozie-java-client start.."
cd /opt/oozie-java-client
dos2unix *.sh
dos2unix file/*.sh
cp -f file/batch.sh file/etl.sh /opt/etl
hdfs dfs -put -f file/kill.sh /user/oozie
hdfs dfs -put -f file/shell /user/oozie/examples/apps/
hdfs dfs -put -f file/sshWithParameters1 /user/oozie/examples/apps/
hdfs dfs -put -f file/sshWithParameters2 /user/oozie/examples/apps/
hdfs dfs -put -f file/cron /user/oozie/examples/apps/
chmod -R 777 /opt/etl
tourl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" config/conn.properties`
touser=`sed '/^db.mysql.user=/!d;s%.*=%%' config/conn.properties`
topasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' config/conn.properties`
tooozie=`sed '/^oozie=/!d;s%.*=%%' config/conn.properties`
tonamenode=`sed '/^nameNode=/!d;s%.*=%%' config/conn.properties`
tojobtracker=`sed '/^jobTracker=/!d;s%.*=%%' config/conn.properties`
tomhost=`sed '/^oozie.ml.add=/!d;s%.*=%%' config/conn.properties`
tobhost=`sed '/^oozie.batch.add=/!d;s%.*=%%' config/conn.properties`
toehost=`sed '/^oozie.etl.add=/!d;s%.*=%%' config/conn.properties`
if [[ "$tourl" != "$url" ]]; then
sed -i "s%$tourl%$url%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$touser" != "$user" ]]; then
sed -i "s%db.mysql.user=$touser%db.mysql.user=$user%" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$topasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$topasswd%db.mysql.password=$passwd%" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties db.mysql.password changed to "$passwd
if [[ "$tooozie" != "$oozie" ]]; then
sed -i "s%$tooozie%$oozie%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties oozie changed to "$oozie
if [[ "$tonamenode" != "$namenode" ]]; then
sed -i "s%$tonamenode%$namenode%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties nameNode changed to "$namenode
if [[ "$tojobtracker" != "$jobtracker" ]]; then
sed -i "s%$tojobtracker%$jobtracker%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties jobTracker changed to "$jobtracker
if [[ "$tomhost" != "$host" ]]; then
sed -i "s%^oozie.ml.add=$tomhost%oozie.ml.add=$host%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties oozie.ml.add changed to "$host
sed -i "s%^oozie.ml.path=.*$%oozie.ml.path=$namenode/user/oozie/examples/apps/sshWithParameters2%" config/conn.properties
echo "log-collector ----> conf/conn.properties oozie.ml.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters2
if [[ "$tobhost" != "$host" ]]; then
sed -i "s%^oozie.batch.add=$tobhost%oozie.batch.add=$host%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties oozie.batch.add changed to "$host
sed -i "s%^oozie.batch.path=.*$%oozie.batch.path=$namenode/user/oozie/examples/apps/sshWithParameters1%" config/conn.properties
echo "log-collector ----> conf/conn.properties oozie.batch.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters1
if [[ "$toehost" != "$host" ]]; then
sed -i "s%^oozie.etl.add=$toehost%oozie.etl.add=$host%g" config/conn.properties
fi
echo "oozie-java-client -----> conf/conn.properties oozie.etl.add changed to "$host
sed -i "s%^oozie.etl.path=.*$%oozie.etl.path=$namenode/user/oozie/examples/apps/sshWithParameters1%" config/conn.properties
echo "log-collector ----> conf/conn.properties oozie.etl.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters1
sed -i "s%^oozie.mlPredict.add=.*$%oozie.mlPredict.add=$host%" config/conn.properties
echo "log-collector ----> conf/conn.properties oozie.mlPredict.add changed to"$host
sed -i "s%^oozie.mlPredict.path=.*$%oozie.mlPredict.path=$namenode/user/oozie/examples/apps/sshWithParameters1%" config/conn.properties
echo "log-collector ----> conf/conn.properties oozie.mlPredict.path changed to"$namenode/user/oozie/examples/apps/sshWithParameters1
sed -i "s%^oozie.coordinator.workflowAppUri=.*$%oozie.coordinator.workflowAppUri=$namenode/user/oozie/examples/apps/cron%" config/conn.properties
echo "log-collector ----> conf/conn.properties oozie.coordinator.workflowAppUri changed to"$namenode/user/oozie/examples/apps/cron
cd -
echo "oozie-java-client end.."

echo "file-watcher start.."
cd /opt/file-watcher
dos2unix *.sh
chmod -R 777 /opt/file-watcher
tfurl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" config/conn.properties`
tfuser=`sed '/^db.mysql.user=/!d;s%.*=%%' config/conn.properties`
tfpasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' config/conn.properties`
if [[ "$tfurl" != "$url" ]]; then
sed -i "s%$tfurl%$url%g" config/conn.properties
fi
echo "file-watcher -----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$tfuser" != "$user" ]]; then
sed -i "s%db.mysql.user=$tfuser%db.mysql.user=$user%" config/conn.properties
fi
echo "file-watcher -----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$tfpasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tfpasswd%db.mysql.password=$passwd%" config/conn.properties
fi
echo "file-watcher ----> conf/conn.properties db.mysql.password changed to "$passwd
cd -
echo "file-watcher end.."

echo "sqoop_web start.."
shivemetastore=`sed '/^hive.metastore.uris=/!d;s%.*=%%' config.cfg`
sport=`sed '/^subscriber.command.port=/!d;s%.*=%%' config.cfg`
cd /opt/sqoop_web
dos2unix *.sh
hdfs dfs -mkdir -p /user/oozie/examples/apps/sqoop_web/lib
#hdfs dfs -put -f ooziefile/sqoop/job.properties /user/oozie/examples/apps/sqoop_web
hdfs dfs -put -f ooziefile/sqoop/workflow.xml /user/oozie/examples/apps/sqoop_web
hdfs dfs -put -f lib_to_hdfs/*.jar /user/oozie/examples/apps/sqoop_web/lib
tsurl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" config/conn.properties`
tsuser=`sed '/^db.mysql.user=/!d;s%.*=%%' config/conn.properties`
tspasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' config/conn.properties`
tsoozie=`sed '/^oozie.url=/!d;s%.*=%%' config/conn.properties`
tsnamenode=`sed '/^nameNode=/!d;s%.*=%%' config/conn.properties`
tsjobtracker=`sed '/^jobTracker=/!d;s%.*=%%' config/conn.properties`
tsport=`sed '/^subscriber.command.port=/!d;s%.*=%%' config/conn.properties`
if [[ "$tsurl" != "$url" ]]; then
sed -i "s%$tsurl%$url%g" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties db.mysql.url changed to "$url
if [[ "$tsuser" != "$user" ]]; then
sed -i "s%db.mysql.user=$tsuser%db.mysql.user=$user%" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties db.mysql.user changed to "$user
if [[ "$tspasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tspasswd%db.mysql.password=$passwd%" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties db.mysql.password changed to "$passwd
if [[ "$tsoozie" != "$oozie" ]]; then
sed -i "s%$tsoozie%$oozie%g" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties oozie changed to "$oozie
if [[ "$tsnamenode" != "$namenode" ]]; then
sed -i "s%$tsnamenode%$namenode%g" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties nameNode changed to "$namenode
if [[ "$tsjobtracker" != "$jobtracker" ]]; then
sed -i "s%$tsjobtracker%$jobtracker%g" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties jobTracker changed to "$jobtracker
if [[ "$tsport" != "$sport" ]]; then
sed -i "s%^subscriber.command.port=$tsport%subscriber.command.port=$sport%g" config/conn.properties
fi
echo "sqoop-web -----> conf/conn.properties subscriber.command.port changed to "$sport
sed -i "s%^oozie.app.path=.*$%oozie.app.path=$namenode/user/oozie/examples/apps/sqoop_web%" config/conn.properties
echo "sqoop-web -----> conf/conn.properties oozie.app.path changed to "$namenode"/user/oozie/examples/apps/sqoop_web"
sed -i "s%^oozie.app.tag2hbase.path=.*$%oozie.app.tag2hbase.path=$namenode/user/oozie/examples/apps/tag2hbase%" config/conn.properties
echo "sqoop-web -----> conf/conn.properties oozie.app.tag2hbase.path changed to "$namenode/user/oozie/examples/apps/tag2hbase
#sed -i "s%^oozie.wf.application.path=.*$%oozie.wf.application.path=$namenode/user/oozie/examples/apps/sqoop_web%" ooziefile/sqoop/job.properties
#echo "sqoop-web -----> ooziefile/sqoop/job.properties oozie.wf.application.path changed to "$namenode/user/oozie/examples/apps/sqoop_web
sed -i "s%^hive.metastore.uris=.*$%hive.metastore.uris=$shivemetastore%" config/conn.properties
echo "sqoop-web -----> ooziefile/sqoop/job.properties hive.metastore.uris changed to "$shivemetastore
sed -i "s%<host>oozie@.*</host>%<host>oozie@$hostname</host>%" ooziefile/tag2hbase/workflow.xml
echo "sqoop-web -----> ooziefile/tag2hbase/workflow.xml hostname changed to "$hostname
hdfs dfs -put -f ooziefile/tag2hbase /user/oozie/examples/apps
cd -
echo "sqoop_web end.."
echo "followup end.."
