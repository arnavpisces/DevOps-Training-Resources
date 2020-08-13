FROM alpine

ADD prometheus-2.20.1.linux-amd64 /prometheus

EXPOSE 9090

WORKDIR /prometheus

ENTRYPOINT ["./prometheus", "--config.file=myPrometheus.yml"]

