# gotosocial-drone-build

Dockerized build environment for [GoToSocial](https://github.com/superseriousbusiness/gotosocial) CI.

The built (Alpine-based) container at Docker hub tag `superseriousbusiness/gotosocial-drone-build` contains the following tools:

- [Go](https://go.dev/).
- [GoReleaser](https://github.com/goreleaser/goreleaser).
- Running Docker daemon (ie., Docker in Docker).
- [Docker Buildx](https://github.com/docker/buildx).
- [GoSwagger](https://github.com/go-swagger/go-swagger).
- Script for cloning from Github -> Codeberg.

## How to use this container

Put all your source files in the container. Build them manually or with GoReleaser. See [here](https://github.com/superseriousbusiness/gotosocial/blob/main/.drone.yml) for an example that uses all the tools 🦥

## Can I build this container manually?

Absolutely you can!

```bash
docker build \
    --build-arg GORELEASER_VERSION=[goreleaser version number] \
    --build-arg GO_SWAGGER_VERSION=[goswagger version number] \
    --build-arg DOCKER_BUILDX_VERSION=[buildx version number] \
    --build-arg GO_CONTAINER_VERSION=[go version number] \
    -t superseriousbusiness/gotosocial-drone-build:[gotosocial-drone-build version number] \
    .
```

Just fill in the version numbers in the above script and you're good to go.

## Updating the container

Bump the version numbers in `.drone.yml`, sign the file, create a new tag, and push it.
