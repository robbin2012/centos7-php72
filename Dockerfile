FROM centos/httpd:latest
MAINTAINER robbin

RUN yum clean all && yum makecache fast && yum -y update \
    && yum -y install epel-release && yum install -y yum-utils mariadb-server mariadb httpd  

RUN rpm -iUvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN rpm -iUvh http://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum update -y && yum-config-manager --enable remi-php72 

RUN yum install -y php  php-opcache php-mysql php-mbstring  php-bcmath php-pdo php-xml php-mcrypt php-pecl-imagick php-pecl-memcached php-gd php-xmlrpc php-soap php-xmlrpc

RUN echo "Setting up SSH for GitHub Checkouts..." \
    && mkdir -p /root/.ssh && chmod 700 /root/.ssh \
    && touch /root/.ssh/known_hosts \
    && ssh-keyscan -H github.com >> /root/.ssh/known_hosts \
    && chmod 600 /root/.ssh/known_hosts \
    && echo "Setting up postfix and phpmail for outbound email.." \
    && touch /var/log/phpmail.log \
    && mkfifo /var/spool/postfix/public/pickup \
    && chown apache: /var/www/html

# Setup htaccess and apache conf
COPY config/main.cf /etc/postfix/main.cf
COPY config/php.ini /etc/php.ini

EXPOSE 80
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-DFOREGROUND"]
