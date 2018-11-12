cd `dirname $0`
#echo "\$1=""$1"", \$2=""$2" > parameter.log
#sh run.sh yarn-cluster $1 $2
#sh run.sh local $1 $2
#sh run.sh yarn-cluster 13 hjw_test_kmean
#sh run.sh local 0 -b 172.31.18.14:9092,172.31.18.13:9092,172.31.18.12:9092 -i 10 -k foo -n uuid1 -t eventlog  -s jiangyin.eventlog_test -r
#sh run.sh standalone 0 -b 172.31.18.14:9092,172.31.18.13:9092,172.31.18.12:9092 -i 10 -k foo -n uuid1 -t eventlog -s jiangyin.eventlog_test -r
#sh run.sh yarn-cluster 0 -b 172.31.18.14:9092,172.31.18.13:9092,172.31.18.12:9092 -i 5 -k foo -n uuid1 -t eventlog -s jiangyin.eventlog_test -r
sh run.sh yarn-cluster 0 -b 172.31.18.14:9092,172.31.18.13:9092,172.31.18.12:9092 -i 5 -k foo -n uuid1 -t eventlog -s jiangyin.eventlog_test -r
#sh run.sh yarn-cluster 1 -b 172.31.18.14:9092,172.31.18.13:9092,172.31.18.12:9092 -i 5 -k foo -n uuid1 -t eventlog -s jiangyin.eventlog_test -r
#sh run.sh yarn-client 0 -b 172.31.18.14:9092,172.31.18.13:9092,172.31.18.12:9092 -i 10 -k foo -n uuid1 -t eventlog -s jiangyin.eventlog_test -r
cd -
