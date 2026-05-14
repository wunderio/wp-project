# Dockerfile for the Nginx container.
FROM wunderio/silta-nginx:latest

COPY --chown=www-data:www-data web /app/web

USER root