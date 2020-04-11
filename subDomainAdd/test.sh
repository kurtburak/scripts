#!/bin/bash

a_httpdConf=`find -L /etc/httpd -name "httpd.conf"`
a_Inc=`grep "^Include" /etc/httpd/conf/httpd.conf`

echo "####### BEGIN ###########"
echo "Apache httpd file: $a_httpdConf"
echo "==>"
echo "Include files: $a_Inc"
echo "==>"
echo "Apache directories:"
ls -aLR /etc/httpd
echo ""
echo "######## END ###########"
