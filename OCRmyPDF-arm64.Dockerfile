# OCRmyPDF based on alpine:edge linux/arm64/v8
FROM alpine:edge@sha256:cfd04e2c9bfed5d883b14329da780888a6a4d1cbc421a0fb1ad076d81bff1d0e

ENV LANG=C.UTF-8

##更新 镜像源
RUN \
    # echo "http://mirrors.aliyun.com/alpine/edge/main" > /etc/apk/repositories && \
    # echo "http://mirrors.aliyun.com/alpine/edge/community" >> /etc/apk/repositories && \
    apk upgrade --no-cache && \
    # 安装源里的ocrmypdf
    apk add --no-cache tzdata \
      bash curl python3 && \
    # change the TimeZone
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装ocrmypdf，自动安装tesseract-ocr主体
RUN apk add --no-cache  ocrmypdf && \
    #export all_proxy='socks5://192.168.1.110:7890' http_proxy='http://192.168.1.110:7890' https_proxy='http://192.168.1.110:7890' && \
    # 安装最新最完整的pip3
    curl https://bootstrap.pypa.io/get-pip.py | python3  && \
    # 卸载apk源里的旧版ocrmypdf
    pip3 uninstall -y ocrmypdf && \
    # 安装最新的ocrmypdf，以及webservice依赖
    pip3 install --no-cache-dir ocrmypdf \
        appdirs \
        falcon \
        hug \
        hug-middleware-cors \
        packaging \
        pyparsing \
        python-mimeparse \
        requests \
        six
    #unset all_proxy http_proxy https_proxy

# 安装tesseract-ocr-data常用语言包，其中equ为数学公式
RUN apk add --no-cache \
      tesseract-ocr-data-chi_sim \
      tesseract-ocr-data-chi_tra \
      tesseract-ocr-data-deu \
      tesseract-ocr-data-fra \
      tesseract-ocr-data-por \
      tesseract-ocr-data-spa \
      tesseract-ocr-data-rus \
      tesseract-ocr-data-jpn \
      tesseract-ocr-data-kor \
      tesseract-ocr-data-equ

# 增加pytest以及watchdog/flash，编译PyMuPDF
RUN apk add --no-cache \
      gcc python3-dev linux-headers \
      musl-dev mupdf-dev \
      exempi && \
    #export all_proxy='socks5://192.168.1.110:7890' http_proxy='http://192.168.1.110:7890' https_proxy='http://192.168.1.110:7890' && \
    pip3 install --no-cache-dir \
      pytest \
      pytest-helpers-namespace \
      pytest-xdist \
      pytest-cov \
      python-xmp-toolkit \
      watchdog \
      Flask \
      PyMuPDF && \
    #unset all_proxy http_proxy https_proxy && \
    apk del \
      gcc python3-dev linux-headers \
      musl-dev mupdf-dev
    
RUN mkdir /app
WORKDIR /app

# 借用官方python脚本
COPY misc/webservice.py /app/
COPY misc/watcher.py /app/

# Copy minimal project files to get the test suite.
COPY setup.cfg setup.py README.md /app/
COPY requirements /app/requirements
COPY tests /app/tests
COPY src /app/src

ENTRYPOINT ["/usr/bin/ocrmypdf"]
