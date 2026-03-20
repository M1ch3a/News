FROM php:8.2-apache

RUN apt-get update && \
    apt-get install -y libapache2-mod-php8.2 2>/dev/null; \
    a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null; \
    a2enmod mpm_prefork rewrite

RUN docker-php-ext-install mysqli pdo pdo_mysql

COPY . /var/www/html/

RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

RUN mkdir -p /var/www/html/writable/cache \
             /var/www/html/writable/logs \
             /var/www/html/writable/session \
             /var/www/html/writable/uploads \
    && chmod -R 777 /var/www/html/writable

RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' \
    /etc/apache2/apache2.conf

EXPOSE 80
CMD ["apache2-foreground"]
