FROM php:8.2-fpm

RUN apt-get update && apt-get install -y libicu-dev \
    && docker-php-ext-install intl mysqli pdo pdo_mysql

RUN apt-get update && apt-get install -y nginx

COPY . /var/www/html/

RUN mkdir -p /var/www/html/writable/cache \
             /var/www/html/writable/logs \
             /var/www/html/writable/session \
             /var/www/html/writable/uploads \
    && chmod -R 777 /var/www/html/writable

COPY <<EOF /etc/nginx/sites-available/default
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
EOF

RUN echo '#!/bin/bash\nphp-fpm -D\nnginx -g "daemon off;"' > /start.sh \
    && chmod +x /start.sh

EXPOSE 80
CMD ["/start.sh"]
