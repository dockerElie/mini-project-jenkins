# start from nginx image
FROM nginx

#set the maintainer
LABEL maintainer="NONO NOUAGONG ELIE MICHEL"

#Install updates
RUN apt-get update
RUN apt-get upgrade -y

#Install required dependencies
RUN apt-get install -y curl
RUN apt-get install -y git

#Clone repository static website example
RUN rm -rf /usr/share/nginx/html/*
RUN git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html

#copy nginx configuration file into the default nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

#using a text stream editor sed to replace the string $PORT in the nginx.conf file with the environment variable PORT
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'