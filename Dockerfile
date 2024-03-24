# syntax=docker/dockerfile:1
# Stage build
FROM golang:1.21-alpine as buildGo

WORKDIR /src

COPY go.mod go.sum ./   

RUN go mod download

COPY . . 

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build go build -o app

# Stage set user
FROM golang:alpine AS builder

RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group

# Stage run
FROM alpine:3.16.2

COPY --from=builder /user/group /user/passwd /etc/
COPY --from=buildGo /src/app-go /app-go

USER nobody:nobody

EXPOSE 8080

ENTRYPOINT ["/app-go"]