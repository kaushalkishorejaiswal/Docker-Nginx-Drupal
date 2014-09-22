################################################################
# Dockerfile to build Centos-LEMP Drupal Installed Container
# Based on CentOS
################################################################

# Set the base image to Centos
FROM centos:centos6

# File Author / Maintainer
MAINTAINER Kaushal Kishore <kaushal.rahuljaiswal@gmail.com>

# Add the ngix and PHP dependent repository
ADD nginx.repo /etc/yum.repos.d/nginx.repo

# Installing nginx 
RUN yum -y install nginx

# Installing MySQL
RUN yum -y install mysql-server mysql-client

# Repository for PHP5.5 
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

# Installing PHP
RUN yum -y --enablerepo=remi,remi-php55 install php-fpm php-common
RUN yum -y --enablerepo=remi,remi-php55 install php-cli php-pear php-pdo php-mysqlnd php-pgsql php-gd php-mbstring php-mcrypt php-xml

# Installing supervisor
RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor

#Installing unzip and zip program
RUN yum install -y tar

# Enviroment variable for setting the Username and Password of MySQL
ENV MYSQL_USER root
ENV MYSQL_PASS root

# Wordpress Database name
ENV DRUPAL_DBNAME drupal

# Adding the configuration file of the nginx
ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
ADD my.cnf /etc/mysql/my.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_database.sh /create_database.sh
ADD mysql_user.sh /mysql_user.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

#Starting MySQL Service
RUN /etc/init.d/mysqld start

# Adding the configuration file of the Supervisor
ADD supervisord.conf /etc/

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

# Retrieve and Installing drupal
RUN rm -rf /var/www/
ADD http://ftp.drupal.org/files/projects/drupal-7.31.tar.gz /drupal-7.31.tar.gz
RUN tar xvzf /drupal-7.31.tar.gz 
RUN mv /drupal-7.31 /var/www/
RUN chmod a+w /var/www/sites/default && mkdir /var/www/sites/default/files
RUN cp /var/www/sites/default/default.settings.php /var/www/sites/default/settings.php
RUN chmod a+w /var/www/sites/default/settings.php
RUN chown -R apache:apache /var/www/

# Set the port to 80 
EXPOSE 80 3306

# Executing supervisord
CMD ["/run.sh"]
