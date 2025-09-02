FROM golang:bookworm AS app
RUN mkdir -p /yopass
WORKDIR /yopass
COPY . .
RUN go build ./cmd/yopass && go build ./cmd/yopass-server

FROM node:20 AS website
COPY website /website
WORKDIR /website
RUN yarn install --network-timeout 600000 && yarn build
docker run -p 3000:3000 -t yopass
FROM gcr.io/distroless/base
COPY --from=app /yopass/yopass /yopass/yopass-server /
COPY --from=website /website/build /public
ENTRYPOINT ["/yopass-server"]
