FROM minio/minio

RUN groupadd -g 1000 www > /dev/null 2>&1 || { retVal=$?; true; }
RUN useradd -u 1000 -ms /bin/sh -g www www > /dev/null 2>&1 || { retVal=$?; true; }

USER www
