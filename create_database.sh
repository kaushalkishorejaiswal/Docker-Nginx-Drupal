#!/bin/bash
# Creating Database fro Wordpress
# Author : Kaushal Kishore <kaushal.rahuljaiswal@gmail.com>
if [[ $# -eq 0 ]]; then
	echo "Usage: $0 <db_name>"
	exit 1
fi

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
	sleep 5
	mysql -uroot -e "CREATE DATABASE $1 CHARACTER SET utf8 COLLATE utf8_general_ci"
	RET=$?
done

