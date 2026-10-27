FROM golang:1.24 AS builder

WORKDIR /src
COPY . .
RUN go build -o /out/testbed .

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5
COPY --from=builder /out/testbed /usr/local/bin/testbed
ENTRYPOINT ["/usr/local/bin/testbed"]
