FROM centos:centos6

MAINTAINER Daniel Taylor <lazydan@gmail.com>

# Add EPEL repo for nginx and supervisor
RUN su -c 'rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
RUN yum update -y

# Install nginx and supervisor
RUN yum install -y nginx supervisor

# Add tools to compile Python from source
RUN yum groupinstall -y "Development tools"
RUN yum install -y wget tar zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel

# Download and compile Python from source
RUN /usr/bin/wget -O /tmp/Python-3.4.2.tgz https://www.python.org/ftp/python/3.4.2/Python-3.4.2.tgz && \
	cd /tmp && \
	/bin/tar xf Python-3.4.2.tgz && \
	cd Python-3.4.2 && \
	./configure --prefix=/usr/local --enable-shared && \
	/usr/bin/make && \
	/usr/bin/make altinstall

# Solves missing shared library errors
RUN su -c "echo '/usr/local/lib' >> /etc/ld.so.conf" && /sbin/ldconfig

RUN yum remove -y wget tar zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel

# Web server config
ADD . /opt/docker/code

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN mkdir -p /opt/html
RUN echo "<html><body>Hello world!</body></html>" >> /opt/html/index.html

RUN ln -s /opt/docker/code/nginx.conf /etc/nginx/conf.d
RUN rm -f /etc/nginx/conf.d/default.conf

RUN cat /opt/docker/code/supervisor-app.conf >> /etc/supervisord.conf

EXPOSE 80
cmd ["supervisord", "-n"]


