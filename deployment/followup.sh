#!/bin/sh
cd `dirname $0`
echo "start......"
echo "bdr-command-bootstrap start..."
cd /opt/bdr-command-bootstrap
dos2unix ./bin/*.sh
echo "bdr-command-bootstrap end.."

echo "log-collector start.."
cd /opt/log-collector
dos2unix ./bin/*.sh
echo "log-collector end.."

echo "log-save-server start.."
cd /opt/log-save-server
dos2unix *.sh *.cfg
echo "log-save-server end.."

echo "etl start.."
cd /opt/etl
dos2unix *.sh *.cfg
cp lib/mysql*.jar lib/ojdbc*.jar /opt/cloudera/parcels/CDH/lib/spark/lib/ -f
echo "etl end.."

echo "oozie-java-client start.."
cd /opt/oozie-java-client
dos2unix *.sh
dos2unix file/*.sh
cp -f file/batch.sh file/start.sh /opt/etl
hdfs dfs -put -f file/kill.sh /user/oozie
hdfs dfs -put -f file/shell /user/oozie/examples/apps/
hdfs dfs -put -f file/sshWithParameters1 /user/oozie/examples/apps/
hdfs dfs -put -f file/sshWithParameters2 /user/oozie/examples/apps/
hdfs dfs -put -f file/cron /user/oozie/examples/apps/
chmod -R 777 /opt/etl
echo "oozie-java-client end.."

echo "followup end.."
