# --------------------------
# 🏗️ Build Go binaries
# --------------------------
FROM golang:bookworm AS build

WORKDIR /yopass
COPY . .

# Build CLI and the server
RUN go build ./cmd/yopass \
 && go build ./cmd/yopass-server

# --------------------------
# 🌐 Build web frontend
# --------------------------
FROM node:20 AS web

WORKDIR /web
COPY website/ .

RUN yarn install --network-timeout 600000 \
 && yarn build

# --------------------------
# 📦 Runtime (tiny)
# --------------------------
FROM gcr.io/distroless/base

# Working directory inside the image
WORKDIR /

# Copy binaries
COPY --from=build /yopass/yopass /yopass
COPY --from=build /yopass/yopass-server /yopass-server

# Copy the compiled website
COPY --from=web /web/build /public

# Yopass server uses 1337 by default
EXPOSE 1337

ENTRYPOINT ["/yopass-server"]
