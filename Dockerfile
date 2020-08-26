FROM dennischancs/ocrmypdf:arm64v8-latest

## ---加入 watchdog，可以指定 -l的语言，定期扫描input文件夹，并ocr到output文件夹
## ---加入 webservice，可指定语言，能上传和下载pdf文件

# webservice [https://github.com/sseemayer/OCRmyPDF-web]
# watchdog [you can build from `go get github.com/bernmic/ocrmypdf-watchdog`]
COPY hugweb/server.py hugweb/index.htm /app/
COPY hugweb/static /app/static/
COPY entrypoint.sh /app/
COPY watchdog /app/
RUN cd /app &&\
   chmod 755 index.htm server.py watchdog entrypoint.sh && \
   # for fix the falcon 2.0.0 bug [`4 arguments but 5 were given`] if you install this version
   sed -i 's#process_response( req, resp, resource, req_succeeded)#process_response( req, resp, resource)#' \
         /usr/lib/python*/site-packages/falcon/api.py


# hugweb webservice
EXPOSE 5250

# watchdog volume
VOLUME [/in /out]

ENTRYPOINT ["/app/entrypoint.sh"]
# ENTRYPOINT ["/app/watchdog"]