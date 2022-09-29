ARG GO_CONTAINER_VERSION
FROM golang:${GO_CONTAINER_VERSION}

ARG GO_SWAGGER_VERSION
ENV GO_SWAGGER_VERSION=${GO_SWAGGER_VERSION}
ARG GORELEASER_VERSION
ENV GORELEASER_VERSION=${GORELEASER_VERSION}
ARG DOCKER_BUILDX_VERSION
ENV DOCKER_BUILDX_VERSION=${DOCKER_BUILDX_VERSION}
ARG APK_PACKAGES="\
                  ### Git -- for cloning the repo
                  git \
                  ## NodeJS + NPM -- for bundling frontend assets (via yarn)
                  nodejs-current \
                  npm \
                  ### docker -- for making docker files inside this container
                  docker \
                  ### openrc -- for running the docker daemon inside the container
                  openrc \
                  ### gcompat -- for the dynamically linked goswagger binary
                  gcompat"

ADD dockerlogin.sh dockerlogin.sh
ADD codeberg_clone.sh codeberg_clone.sh

RUN apk upgrade --update && \
    ### Installs $APK_PACKAGES ###
    apk add $APK_PACKAGES && \
    npm install --global yarn && \
    ### Installs buildx for extended docker build capabilities
    mkdir -p /usr/local/lib/docker/cli-plugins && \
    wget "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64" -O /usr/local/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx && \
    ### Installs goreleaser for performing releases from inside this container
    wget "https://github.com/goreleaser/goreleaser/releases/download/${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz" -O - | tar -xz -C /go/bin && \
    ### Installs goswagger for building swagger definitions inside this container
    wget "https://github.com/go-swagger/go-swagger/releases/download/${GO_SWAGGER_VERSION}/swagger_linux_amd64" -O /go/bin/swagger && \
    # Makes swagger executable
    chmod +x /go/bin/swagger && \
    # Makes Docker Login Executible
    chmod +x dockerlogin.sh
