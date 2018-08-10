FROM ubuntu:16.04
MAINTAINER Sagar Pandya <sagargp@gmail.com>

# Install the latest *release* of zoneminder
RUN apt-get update \
 && apt-get install --yes --no-install-recommends software-properties-common python-software-properties \
 && add-apt-repository ppa:iconnor/zoneminder \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends apache2 libapache2-mod-php zoneminder mysql-server zip \
 && apt-get remove --yes --purge software-properties-common python-software-properties \
 && apt-get autoremove --yes --purge \
 && rm -rf /var/lib/apt/lists/*

# Set our volumes before we attempt to configure apache
VOLUME /var/lib/zoneminder/images /var/lib/zoneminder/events /var/lib/mysql /var/log/zoneminder

# Configure Apache
RUN echo "ServerName localhost" > /etc/apache2/conf-enabled/servername.conf \
    && echo "# Redirect the webroot to /zm\nRedirectMatch permanent ^/$ /zm" > /etc/apache2/conf-enabled/redirect.conf \
    && a2enmod cgi && a2enconf zoneminder && a2enmod rewrite

# Expose http port
EXPOSE 80

# Get the entrypoint script and make sure it is executable
ADD entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh

# This is run each time the container is started
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

################
# RUN EXAMPLES #
################

# ZoneMinder uses /dev/shm for shared memory and many users will need to increase 
# the size significantly at runtime like so:
#
# docker run -d -t -p 1080:443 \
#    --shm-size="512m" \
#    --name zoneminder \
#    zoneminder/zoneminder

# ZoneMinder checks the TZ environment variable at runtime to determine the timezone.
# If this variable is not set, then ZoneMinder will default to UTC.
# Alternaitvely, the timezone can be set manually like so:
#
# docker run -d -t -p 1080:443 \
#    -e TZ='America/Los_Angeles' \
#    --name zoneminder \
#    zoneminder/zoneminder

# ZoneMinder can write its data to folders outside the container using volumes.
#
# docker run -d -t -p 1080:443 \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/mysql:/var/lib/mysql \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --name zoneminder \
#    zoneminder/zoneminder

# ZoneMinder can use an external database by setting the appropriate environment variables.
#
# docker run -d -t -p 1080:443 \
#    -e ZM_DB_USER='zmuser' \
#    -e ZM_DB_PASS='zmpassword' \
#    -e ZM_DB_NAME='zoneminder_database' \
#    -e ZM_DB_HOST='my_central_db_server' \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --name zoneminder \
#    zoneminder/zoneminder

# Here is an example using the options described above with the internal database:
#
# docker run -d -t -p 1080:443 \
#    -e TZ='America/Los_Angeles' \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/mysql:/var/lib/mysql \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --shm-size="512m" \
#    --name zoneminder \
#    zoneminder/zoneminder

# Here is an example using the options described above with an external database:
#
# docker run -d -t -p 1080:443 \
#    -e TZ='America/Los_Angeles' \
#    -e ZM_DB_USER='zmuser' \
#    -e ZM_DB_PASS='zmpassword' \
#    -e ZM_DB_NAME='zoneminder_database' \
#    -e ZM_DB_HOST='my_central_db_server' \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --shm-size="512m" \
#    --name zoneminder \
#    zoneminder/zoneminder

