#!/usr/bin/env bash

# If the following environment variables are set, certbot will try to generate a new SSL certificate for your domain.
# A certificate renewal chronjob will also be created.
if [ $DOMAINNAME ] && [ $SUBDOMAIN ] && [ $ADMINEMAIL ] && [ "$NODE_ENV" = "production" ]; then

    # Generate the initial letsencrypt / certbot SSL certificate using the webroot method.
    # This method will send a challenge to this server's http port 80.
    # If the response is valid, certbot will put the generated SSL certificates in the following directory: /etc/letsencrypt/live/$SUBDOMAIN.$DOMAIN/
    echo "Executing the initial letsencrypt / certbot SSL certificate request ..."
    /certbot/certbot-auto certonly --webroot --webroot-path /usr/src/app --email $ADMINEMAIL -d $SUBDOMAIN.$DOMAINNAME -n --agree-tos --no-self-upgrade

    # cron job for certificate renewal
    echo "Creating certificate renewal cronjob ..."
    cd / && echo "51 3 * * 4 /certbot/certbot-auto renew --webroot --webroot-path /usr/src/app --email david@appsaloon.be -d $SUBDOMAIN.$DOMAINNAME -n --agree-tos --no-self-upgrade >> /renew.log" >> renew_ssl_cron
    crontab renew_ssl_cron && rm renew_ssl_cron && cron
else
    echo "(optional) To generate a letsencrypt / certbot SSL certificate, make sure the following environment variables are set: SUBDOMAIN DOMAINNAME ADMINEMAIL"
fi