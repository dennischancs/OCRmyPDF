FROM golang:alpine as builder
RUN apk update && apk add --no-cache git
COPY watchdog/* $GOPATH/src/ocrmypdf-watchdog/
WORKDIR $GOPATH/src/ocrmypdf-watchdog/
RUN go get -d -v
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o /go/bin/main .

FROM dennischancs/ocrmypdf
## ---加入 watchdog，可用`-l`指定ocr语言参数，定期扫描input文件夹，并ocr到output文件夹
## ---加入 hugweb webservice，能连续上传和下载pdf文件
# webservice [https://github.com/sseemayer/OCRmyPDF-web]
# watchdog [you can build from `go get github.com/bernmic/ocrmypdf-watchdog`]
COPY hugweb/server.py hugweb/index.htm /app/
COPY hugweb/static /app/static/
COPY entrypoint.sh /app/
COPY --from=builder /go/bin/main /app/watchdog
RUN cd /app &&\
   chmod 755 index.htm server.py watchdog entrypoint.sh && \
   # for fix the falcon 2.0.0 bug [`4 arguments but 5 were given`] if you install this version
   sed -i 's#process_response(req, resp, resource, req_succeeded)#process_response(req, resp, resource)#' /usr/lib/python3.8/site-packages/falcon/api.py

WORKDIR /app

# hugweb webservice
EXPOSE 5250

# watchdog volume
VOLUME [/in /out]

ENTRYPOINT ["/app/entrypoint.sh"]
# ENTRYPOINT ["/app/watchdog"]
