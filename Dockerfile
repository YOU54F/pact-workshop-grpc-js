# docker build . --platform=linux/arm64 --progress plain -t pact-workshop-grpc-js:arm64
# docker run --platform=linux/arm64 -v $PWD:/app -v /app/node_modules/ -v /app/consumer/node_modules -v /app/provider/node_modules -e PACT_PREBUILD_LOCATION=/root/.pact --rm -it pact-workshop-grpc-js:arm64
# docker build . --platform=linux/amd64 --progress plain -t pact-workshop-grpc-js:amd64
# docker run --platform=linux/amd64 -v $PWD:/app -v /app/node_modules/ -v /app/consumer/node_modules -v /app/provider/node_modules -e PACT_PREBUILD_LOCATION=/root/.pact --rm -it pact-workshop-grpc-js:amd64
FROM node:alpine
ARG TARGETARCH
WORKDIR /root

RUN apk --no-cache add curl protoc

# Install musl version of pact-plugin-cli
RUN curl -LO https://github.com/YOU54F/pact-plugins/releases/download/pact-plugin-cli-v0.1.3/pact-plugin-cli-linux-$(uname -m)-musl.gz && \
    gunzip pact-plugin-cli-linux-$(uname -m)-musl.gz && \
    chmod +x pact-plugin-cli-linux-$(uname -m)-musl && \
    mv pact-plugin-cli-linux-$(uname -m)-musl /usr/local/bin/pact-plugin-cli

# Install musl version of pact-protobuf-plugin
RUN pact-plugin-cli install --yes protobuf

# Install musl version of pact-js-prebuild
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        export ARCH="x64"; \
    else \
        export ARCH="arm64"; \
    fi && \
    curl -LO https://github.com/YOU54F/pact-js-core/releases/download/v15.0.0/linux-${ARCH}.tar.gz && \
    tar -xvf linux-${ARCH}.tar.gz && \
    rm linux-${ARCH}.tar.gz && \
    mv prebuilds /root/.pact
WORKDIR /app
CMD ["/bin/sh", "-c", "npm i && npm test"]