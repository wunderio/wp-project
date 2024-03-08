# Dockerfile for building nginx.
FROM nginx:1.25-alpine

COPY web /app/web

# Patch the nginx configuration with new webroot instead?
RUN rm -rf /usr/share/nginx/html && ln -s /app/web /usr/share/nginx/html
