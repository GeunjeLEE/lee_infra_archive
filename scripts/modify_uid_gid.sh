#!/bin/bash
target_user=ssm-user

if [ -z $1 ]
then
        echo "There are no parameters!"
        echo "---------------------------"
        echo "sh filename.sh {ID number you want to change}"
        echo "---------------------------"
        exit
fi

origin_uid=$(grep $target_user /etc/passwd | cut -d : -f 3)
origin_gid=$(grep $target_user /etc/passwd | cut -d : -f 4)

echo "#########################既存の所有ディレクトリ＆ファイル#########################"
echo "------------------uid : $origin_uid --------------------"
echo $(find / -user $origin_uid -exec ls -la {} \;)
echo "------------------uid : $origin_gid --------------------"
echo $(find / -user $origin_gid -exec ls -la {} \;)
echo "###############################################################################"
echo -e "\n"

usermod -u $1 $target_user
groupmod -g $1 $target_user

find / -user $origin_uid -exec chown -h $target_user {} \;
find / -group $origin_gid -exec chgrp -h $target_user {} \;
echo -e "\n"

echo "########################結果#########################"
echo "--------------------------------------"
echo $(grep $target_user /etc/passwd)
echo "--------------------------------------"
echo -e "\n"
echo "------------------uid : $origin_uid --------------------"
echo $(find / -user $origin_uid -exec ls -la {} \;)
echo "------------------uid : $origin_gid --------------------"
echo $(find / -user $origin_gid -exec ls -la {} \;)
echo -e "\n"
new_uid=$(grep $target_user /etc/passwd | cut -d : -f 3)
new_gid=$(grep $target_user /etc/passwd | cut -d : -f 4)
echo "------------------uid : $new_uid --------------------"
echo $(find / -user $new_uid -exec ls -la {} \;)
echo "------------------uid : $new_gid --------------------"
echo $(find / -user $new_gid -exec ls -la {} \;)
echo "####################################################"