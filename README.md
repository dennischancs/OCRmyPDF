# OCRmyPDF for arm64v8
基于alpine:edge的arm64v8镜像重新制作，适用于arm64v8机器。
ocrmypdf及各项依赖先使用`apk add ocrmypdf`安装，然后卸载并安装最新版 `pip3 uninstall ocrmypdf && pip3 install ocrmypdf` 。

> 参考了以下几个仓库：
> - 主程序：[jbarlow83/OCRmyPDF: OCRmyPDF adds an OCR text layer to scanned PDF files, allowing them to be searched](https://github.com/jbarlow83/OCRmyPDF)
> - webservice: [sseemayer/OCRmyPDF-web: A tiny frontend for OCRing PDF files via the web.](https://github.com/sseemayer/OCRmyPDF-web)
> - watchdog: [bernmic/ocrmypdf-watchdog: A watchdog for OCRMyPDF written in go](https://github.com/bernmic/ocrmypdf-watchdog)

## 简要说明：
1. `dennischancs/ocrmypdf:arm64v8-latest`
  - 保留了 `jbarlow83/OCRmyPDF` 所有脚本
  - 容器入口为 `/usr/bin/ocrmypdf` 
2. `dennischancs/ocrmypdf-watchdog:arm64v8-latest`
  - 基于前一镜像，添加了`sseemayer/OCRmyPDF-web`和`bernmic/ocrmypdf-watchdog`
  - 容器入口为 `/app/watchdog`。

## 使用方法：

```bash
docker create \
  --name=ocrmypdf \
  -e OCRMYPDF_IN='/in' \
  -e OCRMYPDF_OUT='/out' \
  -e WATCHDOG_FREQUENCY=5 \
  -e WATCHDOG_EXTENSIONS='pdf,jpg,jpeg,tif,tiff,png,gif' \
  -e OCRMYPDF_BINARY=ocrmypdf  \
  -e OCRMYPDF_PARAMETER='-l chi_sim+eng+equ --tesseract-timeout 300 --rotate-pages --deskew --jobs 4 --output-type pdfa'  \
  -p 5250:5250 \
  -v /var/media/ssdDATA/ocrfolder/input:/in \
  -v /var/media/ssdDATA/ocrfolder/output:/out \
  --restart unless-stopped \
  dennischancs/ocrmypdf-watchdog:arm64v8-latest
```

注解：
```bash
ocrmypdf                      # it's a scriptable command line program
   -l chi_sim+eng+equ         # OCR中文+英文+数学公式, it supports multiple languages
   --tesseract-timeout 300    # arm机器cpu性能有限,设置每页timeout为300秒避免程序因OCR时间较长而放弃该页
   --rotate-pages             # it can fix pages that are misrotated
   --deskew                   # it can deskew crooked PDFs!
   --jobs 4                   # it uses multiple cores by default
   --output-type pdfa         # it produces PDF/A by default
   --title "My PDF"           # it can change output metadata
   input_scanned.pdf          # takes PDF input (or images)
   output_searchable.pdf      # produces validated PDF output
```


## 功能
- web服务功能：`http://ip:5250/`的web端，支持连续上传pdf，识别完成会自动更名并下载为`ocr-*.pdf`
- 文件夹监控并ocr：可以借助web文件管理器，往`input`文件夹存入原始pdf文件，系统OCR完成后以原文件名存入`output`文件夹，并删除`input`文件夹中的原文件。