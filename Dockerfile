FROM 0x01be/sqlmap as sqlmap
FROM 0x01be/xsser as xsser
FROM 0x01be/openvas as openvas
FROM 0x01be/dnsrecon as dnsrecon
FROM 0x01be/theharvester as theharvester
FROM 0x01be/golismero:build as build

FROM alpine

RUN apk add --no-cache --virtual golismero-build-dependencies \
    git \
    py-pip

ENV GOLISMERO_REVISION master
RUN git clone --depth 1 --branch ${GOLISMERO_REVISION} https://github.com/golismero/golismero.git /golismero

WORKDIR /golismero

RUN pip install -r requirements.txt --prefix=/opt/golismero
RUN pip install -r requirements_unix.txt --prefix=/opt/golismero

RUN cp -R  /golismero/* /opt/golismero/

FROM alpine

COPY --from=build /opt/golismero/ /opt/golismero/
COPY --from=sqlmap /opt/sqlmap/ /opt/sqlmap/
COPY --from=xsser /opt/xsser/ /opt/xsser/
COPY --from=openvas /opt/gvm/ /opt/gvm/
COPY --from=openvas /opt/openvas/ /opt/openvas/
COPY --from=dnsrecon /opt/dnsrecon/ /opt/dnsrecon/
COPY --from=theharvester /opt/theharvester/ /opt/theharvester/
  
RUN apk add --no-cache --virtual golismero-runtime-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    python2 \
    nmap \
    sslscan \
    python3 \
    py3-netaddr \
    py3-dnspython \
    py3-lxml \
    py3-setuptools \
    py3-yaml \
    py3-aiohttp \
    curl \
    libffi \
    firefox-esr \
    glib \
    gnutls \
    gvm-libs \
    libpcap \
    libssh \
    gpgme \
    libksba \
    libgcrypt

ENV PATH ${PATH}:/opt/golismero/:/opt/sqlmap/:/opt/xsser/bin/:/opt/openvas/bin/:/opt/dnsrecon/:/opt/theharvester/bin/
ENV LD_LIBRARY_PATH /usr/lib:/opt/openvas/lib/:/opt/gvm/lib
ENV PYTHONPATH  /usr/lib/python3.8/site-packages/:/opt/dnsrecon/lib/python3.8/site-packages/:/opt/golismero/lib/python2.7/site-packages/:/opt/xsser/lib/python3.8/site-packages/:/opt/theharvester/lib/python3.8/site-packages/

CMD "golismero.py"

