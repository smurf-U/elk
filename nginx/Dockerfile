FROM fholzer/nginx-brotli

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT [ "nginx" ]

CMD [ "-g", "daemon off;" ]