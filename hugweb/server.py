#!/usr/bin/env python3
import hug
from hug_middleware_cors import CORSMiddleware

import subprocess
from tempfile import NamedTemporaryFile

api = hug.API(__name__)
api.http.add_middleware(CORSMiddleware(api))

# for the `http://ip:80/ocrmypdf`, use dir `/ocrmypdf/`
# for the `http://ip`, use dir `/`

@hug.get('/ocrmypdf/', output=hug.output_format.file)
def index():
    return "./index.htm"


@hug.get('/ocrmypdf/static/{fn}', output=hug.output_format.file)
def static(fn):
    return './static/{}'.format(fn)


@hug.post('/ocrmypdf/ocr', output=hug.output_format.file)
def ocr(body, response, language: "The language(s) to use for OCR"="chi_sim+eng+equ"):
    if not len(body) == 1:
        raise Exception("Need exactly one file!")

    fn, content = list(body.items()).pop()

    f_out = NamedTemporaryFile(suffix='.pdf')

    with NamedTemporaryFile(suffix='.pdf', mode="wb") as f_in:
        f_in.write(content)
        f_in.flush()

        proc = subprocess.Popen(['ocrmypdf', '--force-ocr', '-l', language, f_in.name, f_out.name])

        code = proc.wait()

        response.set_header('X-OCR-Exit-Code', str(code))

        print(f_out.name)

        return f_out
