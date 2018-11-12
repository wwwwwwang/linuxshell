#!/bin/sh

url=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;;s%\?.*%%" config.cfg`
user=`sed '/^db.mysql.user=/!d;s%.*=%%' config.cfg`
passwd=`sed '/^db.mysql.password=/!d;s%.*=%%' config.cfg`

LIST="log-save-server"
for d in $LIST 
do
cd /opt/$d/config
echo "cd /opt/$d/config"
turl=`sed "/^db.mysql.url=/!d;s%.*mysql:%%;s%\?.*%%" conn.properties`
tuser=`sed '/^db.mysql.user=/!d;s%.*=%%' conn.properties`
tpasswd=`sed '/^db.mysql.password=/!d;s%.*=%%' conn.properties`
echo "$turl"?="$url"
if [[ "$turl" != "$url" ]]; then
sed -i "s%$turl%$url%g" conn.properties
fi
echo "$tuser" ?= "$user"
if [[ "$tuser" != "$user" ]]; then
sed -i "s%$tuser%$user%g" conn.properties
fi
echo "$tpasswd" ?= "$passwd"
if [[ "$tpasswd" != "$passwd" ]]; then
sed -i "s%db.mysql.password=$tpasswd%db.mysql.password=$passwd%g" conn.properties
fi
done
echo "t.sh is finished..."
