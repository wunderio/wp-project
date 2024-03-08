# Dockerfile for the PHP container.
FROM wunderio/silta-php-fpm:8.2-fpm-v1 AS base

COPY --chown=www-data:www-data config /app/config
COPY --chown=www-data:www-data vendor /app/vendor
COPY --chown=www-data:www-data web /app/web

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN cp wp-cli.phar /usr/local/bin/wp

USER www-data

WORKDIR /app
