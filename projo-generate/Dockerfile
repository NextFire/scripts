FROM python:alpine
RUN apk add --no-cache vim && pip install --no-cache-dir click
COPY generate.sh /
ENTRYPOINT ["/generate.sh"]
