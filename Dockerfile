ARG GO_CONTAINER_VERSION
FROM golang:${GO_CONTAINER_VERSION}

ARG GO_SWAGGER_VERSION
ENV GO_SWAGGER_VERSION=${GO_SWAGGER_VERSION}

ARG GORELEASER_VERSION
ENV GORELEASER_VERSION=${GORELEASER_VERSION}

RUN apk upgrade --update

### Install nodejs and yarn ###
RUN apk add nodejs-current
RUN apk add npm
RUN npm install --global yarn

### Install docker -- for making docker files inside this container
### Install openrc -- for running the docker daemon inside the container
RUN apk add docker openrc

### Install goreleaser for performing releases from inside this container
RUN go install "github.com/goreleaser/goreleaser@${GORELEASER_VERSION}"

### Install goswagger for building swagger definitions inside this container
RUN wget "https://github.com/go-swagger/go-swagger/releases/download/${GO_SWAGGER_VERSION}/swagger_linux_amd64" -O /go/bin/swagger
RUN chmod +x /go/bin/swagger

ADD entrypoint.sh /go/entrypoint
WORKDIR /go
ENTRYPOINT [ "entrypoint.sh" ]
