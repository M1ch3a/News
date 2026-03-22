FROM php:8.2-fpm

RUN apt-get update && apt-get install -y libicu-dev nginx \
    && docker-php-ext-install intl mysqli pdo pdo_mysql \
    && apt-get clean

COPY . /var/www/html/

RUN mkdir -p /var/www/html/writable/cache \
             /var/www/html/writable/logs \
             /var/www/html/writable/session \
             /var/www/html/writable/uploads \
    && chmod -R 777 /var/www/html/writable

COPY <<NGINXCONF /etc/nginx/sites-available/default
server {
    listen 80;
    root /var/www/html/public;
    index index.php index.html;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
NGINXCONF

RUN cat > /start.sh << 'SCRIPT'

cp /var/www/html/env /var/www/html/.env
sed -i "s|database.default.hostname = .*|database.default.hostname = ${MYSQLHOST}|" /var/www/html/.env
sed -i "s|database.default.database = .*|database.default.database = ${MYSQLDATABASE}|" /var/www/html/.env
sed -i "s|database.default.username = .*|database.default.username = ${MYSQLUSER}|" /var/www/html/.env
sed -i "s|database.default.password =.*|database.default.password = ${MYSQLPASSWORD}|" /var/www/html/.env
sed -i "s|# database.default.port = .*|database.default.port = ${MYSQLPORT}|" /var/www/html/.env
sed -i "s|CI_ENVIRONMENT = development|CI_ENVIRONMENT = production|" /var/www/html/.env
php-fpm -D
nginx -g "daemon off;"
SCRIPT

RUN chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
