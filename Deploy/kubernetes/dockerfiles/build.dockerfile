FROM golang:1.6.2

RUN apt-get update \
    && apt-get install -y libldap2-dev \
    && rm -r /var/lib/apt/lists/*

COPY . /go/src/github.com/vmware/harbor


WORKDIR /go/src/github.com/vmware/harbor/ui

RUN go build -v -a -o /go/bin/harbor_ui
    
WORKDIR /go/src/github.com/vmware/harbor/jobservice

RUN go build -v -a -o /go/bin/harbor_jobservice
