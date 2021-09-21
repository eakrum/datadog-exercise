# ---- Base Node ----
FROM node:16-buster AS base

ARG CHAMBER_VERSION=v2.3.2

ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_HOST
ENV DB_USERNAME ${DB_USERNAME}
ENV DB_PASSWORD ${DB_PASSWORD}
ENV DB_HOST ${DB_HOST}



# Install dependencies
RUN apt-get install curl -y

# Create app directory and copy files to it
WORKDIR /app
COPY . .

# install app dependencies
RUN npm install

# make entrypoint executable
RUN chmod a+x entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["./entrypoint.sh"]