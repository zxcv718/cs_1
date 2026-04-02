FROM nginx:1.29.7-alpine

LABEL org.opencontainers.image.title="codyssey-week1-web"
LABEL org.opencontainers.image.description="Week1 custom nginx image"
ENV APP_ENV=week1

COPY site/ /usr/share/nginx/html/

EXPOSE 80
