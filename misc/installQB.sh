#!/bin/bash

OWNER=qbadm
MYGROUP=qb
COMMENT="QBroker Admin"
MYUID=1454
MYGID=1453
PANDA=75.131.197.149

yourid=`id | awk '{print $1}'`
if [ "$yourid" != "uid=0(root)" ]
then
  echo "You are not root! Please run this command as root"
  exit 1
fi

groupadd -g $MYGID $MYGROUP
id $OWNER > /dev/null 2>&1
if [ "$?" != "0" ]
then
  useradd -u $MYUID -g $MYGID -c "$COMMENT" -s /bin/bash -d /home/$OWNER -m $OWNER
fi

if [ "$#" -gt "0" ]
then
  cp $1/qbroker.tgz /tmp
else
  cd /tmp
  wget --no-check-certificate https://$PANDA/qbroker.tgz
fi

[ -d /opt ] || mkdir /opt

cd /opt
tar zxf /tmp/qbroker.tgz
chown -R $OWNER:$MYGROUP ./qbroker
chmod -R g+w ./qbroker
find ./qbroker -type d -exec chmod g+s {} \;

cd /var/log
mkdir qbroker
if [ -d ./qbroker ]
then
  cd ./qbroker
  mkdir .status archvie checkpoint incoming stats
  chown $OWNER:$MYGROUP . .status archvie checkpoint incoming stats
  chmod g+ws . .status archvie checkpoint incoming stats
else
  echo "failed to create folder of qbroker in /var/log"
fi

cd /tmp
rm qbroker.tgz
