#!/bin/bash

OWNER=qbadm
MYGROUP=qb
COMMENT="WDAP for WebAdmin"

yourid=`id | awk '{print $1}'`
if [ "$yourid" != "uid=0(root)" ]
then
  echo "You are not root! Please run this command as root"
  exit 1
fi

id $OWNER > /dev/null 2>&1
if [ "$?" != "0" ]
then
  echo "No such user: $OWNER! Please make sure $OWNER exist first"
  exit 1
fi

if [ "$#" -gt "0" ]
then
  cp $1/wdap.tgz /tmp
else
  cd /tmp
  wget http://panda:8082/wdap.tgz
fi

[ -d /www ] || mkdir /www

cd /www
tar zxf /tmp/wdap.tgz
chown -R $OWNER:$MYGROUP ./wdap
chown -R root ./wdap/cfg

cd /www/wdap/bin
for cmd in "expect host java jq rsync scp ssh sudo xmllint"
do
  path=`which $cmd 2>/dev/null`
  if [ "$path" = "" ]
  then
    echo "Can not find $cmd! Please have it installed and add the symlink later"
  else
    su $OWNER -c "ln -s $path $cmd"
  fi
done

cd /tmp
rm wdap.tgz
