FROM python:slim-buster
ARG API_ENDPOINT
ENV API_ENDPOINT=${API_ENDPOINT}
COPY . /test-agent/
WORKDIR "/test-agent/"
RUN pip3 install -r /test-agent/requirements.txt

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]