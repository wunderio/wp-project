# Dockerfile for the Nginx container.
FROM wunderio/silta-nginx:1.17-v1

COPY --chown=www-data:www-data web /app/web

USER root