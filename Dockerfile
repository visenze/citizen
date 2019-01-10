# build stage
FROM node:8 as build

LABEL maintainer="outsideris@gmail.com"

WORKDIR /www
ADD . /www

RUN npm install

RUN npm run build

# final stage
FROM bitnami/minideb

COPY --from=build /www/dist/citizen-linux /usr/local/bin/citizen

WORKDIR /www

ENV CITIZEN_DB_DIR ./data
ENV CITIZEN_STORAGE file
ENV CITIZEN_STORAGE_PATH /path/to/store
#ENV CITIZEN_AWS_S3_BUCKET BUCKET_IF_STORAGE_IS_S3
#ENV AWS_ACCESS_KEY_ID YOUR_AWS_KEY_IF_STORAGE_IS_S3
#ENV AWS_SECRET_ACCESS_KEY YOUR_AWS_SECRET_KEY_IF_STORAGE_IS_S3
ENV NODE_ENV=production

RUN mkdir -p /snapshot/www/lib

COPY ./views /snapshot/www/views

EXPOSE 3000

CMD citizen server
