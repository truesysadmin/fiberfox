FROM python:3.10.4-buster

WORKDIR /app
COPY ./ ./

RUN pip install requests && python setup.py install

ENTRYPOINT ["fiberfox"]
