FROM debian:buster-slim
MAINTAINER Paweł T. Jochym <jochym@wolf.ifj.edu.pl>

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get  update && \
    apt-get -y full-upgrade && \
    apt-get -y install locales supervisor

# create directory for child images to store configuration in
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d

# supervisor base configuration
ADD supervisor.conf /etc/supervisor.conf

# default command
CMD ["supervisord", "-c", "/etc/supervisor.conf"]

# Install locales
RUN locale-gen en_US.UTF-8

ENV BUILD_DEPS="git devscripts equivs apt-utils apache2-dev libslurm-dev python-setuptools cython python-dev slurm-wlm-basic-plugins-dev libslurmdb-dev ca-certificates"

ENV RUN_DEPS="apache2 libapache2-mod-wsgi javascript-common python-flask clustershell libjs-bootstrap libjs-jquery-flot libjs-jquery-tablesorter munge slurm-wlm node-uglify fonts-dejavu-core python-ldap python-redis libjs-requirejs libjs-requirejs-text libjs-three libjs-d3 libjs-handlebars libjs-async python-clustershell"


# Install system dependencies
RUN apt-get update -q && \
    apt-get -y install $BUILD_DEPS $RUN_DEPS

#RUN    ln -s /usr/lib/x86_64-linux-gnu/ /usr/lib64

RUN a2enmod wsgi && \
    a2enconf javascript-common

RUN ln -s /usr/include/slurm-wlm /usr/include/slurm && \
	ln -s /usr/lib/x86_64-linux-gnu/slurm-wlm/libslurmfull.so /usr/lib/x86_64-linux-gnu/

# Build and install specific deps
ENV SLURM_VER=18.08.0.1
RUN cd /usr/src && \
    git clone https://github.com/jochym/pyslurm.git && \
    cd pyslurm && \
    git checkout $SLURM_VER && \
    dch -v $SLURM_VER-1 -D testing "New upstream release" && \
    fakeroot debian/rules binary && \
    dpkg -i ../python-pyslurm_$SLURM_VER-1_amd64.deb

ENV OPENTYPE=0.4.3
ENV OTREL=2
ENV OPENTYPE=0.6.0
ENV OTREL=1
RUN cd /usr/src && \
    git clone https://github.com/edf-hpc/opentypejs.git && \
    cd opentypejs && \
    git checkout debian/$OPENTYPE-$OTREL && \
	tar cvfj ../opentypejs_$OPENTYPE.orig.tar.bz2 --exclude .git . && \
	mk-build-deps -ri -t "apt-get -y --no-install-recommends" && \
	debuild -us -uc && \
	dpkg -i ../node-opentypejs_$OPENTYPE-${OTREL}_all.deb && \
	dpkg -L node-opentypejs


RUN cd /usr/src && \
	git clone https://github.com/edf-hpc/libjs-bootstrap-typeahead.git && \
	cd libjs-bootstrap-typeahead/ && \
    git checkout debian/0.11.1-1 && \
	tar cvfj ../libjs-bootstrap-typeahead_0.11.1.orig.tar.bz2 --exclude .git . && \
	debuild -us -uc && \
	dpkg -i ../libjs-bootstrap-typeahead_0.11.1-1_all.deb

RUN cd /usr/src && \
	git clone https://github.com/edf-hpc/libjs-bootstrap-tagsinput.git && \
	cd libjs-bootstrap-tagsinput/ && \
    git checkout debian/0.8.0-1 && \
	tar cvfj ../libjs-bootstrap-tagsinput_0.8.0.orig.tar.bz2 --exclude .git . && \
	debuild -us -uc && \
	dpkg -i ../libjs-bootstrap-tagsinput_0.8.0-1_all.deb

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN cd /usr/src && \
    git clone https://github.com/jochym/slurm-web.git && \
    cd slurm-web && \
    git checkout master && \
    debuild -us -uc && \
    dpkg -i ../slurm-web-*deb

ADD DejaVuSansMono.typeface.js /usr/share/slurm-web/dashboard/js/fonts/

# Create apache2 service
RUN rm /etc/apache2/sites-available/default-ssl.conf && \
    chown -R www-data:www-data /var/log/apache2

# Create munge directories
RUN chown munge: /var/log/munge /var/lib/munge 

# Cleanup
RUN apt-get clean 

EXPOSE 80/tcp

VOLUME ["/etc/slurm-web"]


