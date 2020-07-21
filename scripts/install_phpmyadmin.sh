#!/bin/bash

package_check() {
  for rpm in $1
  do
    rpm -qa | grep "^$rpm-" > /dev/null
    if [ $? -eq 0 ]; then
      echo 0
    else
      echo 1
    fi
  done
  echo ""
}

install_httpd() {
  yum install httpd
}

install_php() {

  #5.x? / Defualt version?
  yum install php php-common php-mbstring php-intl php-mysql
}

install_phpMyAdmin() {

  ret=package_check "epel-release"
  if [ $ret -eq 1 ]; then
    amazon-linux-extras install epel
  fi

  yum install phpmyadmin
}
#--------------------------------------------------------------
#                               main
#--------------------------------------------------------------

echo "---------------------------------------------"
echo "             install phpmyadmin              "
echo "---------------------------------------------"
echo ""

phpmyadmin_apm=("httpd" "php" "mysql" "phpMyAdmin")

for value in ${phpmyadmin_apm[@]}
do
  ret=$(package_check "$value")
  if [ $ret -eq 0 ]; then
    line='........................'
    printf "    %s %s"  "$value" "${line:${#value}}"
    echo " [Installed]"
  else
    line='........................'
    printf "    %s %s"  "$value" "${line:${#value}}"
    echo " [Package does not exist]"
    echo ""
    echo "==========================================================================================="

    install_$value

    echo "==========================================================================================="
  fi
done
