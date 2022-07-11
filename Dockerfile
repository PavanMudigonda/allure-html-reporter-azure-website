FROM mcr.microsoft.com/azure-cli


RUN apk --update add --virtual build-dependencies --no-cache wget tar 
RUN apk --update add libc6-compat ca-certificates
RUN apk update && \
    apk add --no-cache bash wget unzip && \
    rm -rf /var/cache/apk/*
    
LABEL "com.github.actions.name"="Allure HTML Reporter Azure Blob Upload"
LABEL "com.github.actions.description"="Upload Allure HTML Test Results to an Azure Blob repository"
LABEL "com.github.actions.icon"="refresh-cw"
LABEL "com.github.actions.color"="green"

LABEL version="0.1"
LABEL repository="https://github.com/PavanMudigonda/allure-html-reporter-azure-blob-website"
LABEL homepage="https://abcd.guru/"
LABEL maintainer="Pavan Mudigonda <mnpawan@gmail.com>"

RUN apk update && \
    apk add --no-cache bash wget unzip && \
    rm -rf /var/cache/apk/* \
    && apk upgrade \
    && apk add ca-certificates \
    && update-ca-certificates \
    && apk add --update coreutils && rm -rf /var/cache/apk/*   \ 
    && apk add --update openjdk11 tzdata curl unzip bash \
    && apk add --no-cache nss \
    && rm -rf /var/cache/apk/*

ARG RELEASE=2.18.1
ARG ALLURE_REPO=https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline

RUN echo $RELEASE && \
    apk update && \
    apk add --no-cache bash wget unzip && \
    rm -rf /var/cache/apk/*

RUN wget --no-verbose -O /allure-$RELEASE.tgz $ALLURE_REPO/$RELEASE/allure-commandline-$RELEASE.tgz && \
    tar -xf ./allure-$RELEASE.tgz && \
    chmod -R +x ./allure-$RELEASE/bin

ENV ROOT=/app \
    PATH=$PATH:/allure-$RELEASE/bin

RUN mkdir -p $ROOT

WORKDIR $ROOT

COPY ./entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]

