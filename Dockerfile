FROM nginx:1.14
LABEL maintainer="Jason Wilder mail@jasonwilder.com"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
    musl \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Forego
#ADD https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm.tgz /usr/local/bin/forego
RUN wget https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm.tgz \
  && tar -C /usr/local/bin -zxf forego-stable-linux-arm.tgz \
  && rm /forego-stable-linux-arm.tgz \
  && chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.4

COPY network_internal.conf /etc/nginx/

COPY . /app/
COPY docker-gen /usr/local/bin/docker-gen
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
