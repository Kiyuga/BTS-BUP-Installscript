FROM node:20-bookworm-slim

RUN apt-get update -qq && \
    apt-get install -qy make git htop psmisc bash curl sudo && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /bts

COPY . .
RUN chmod +x /bts/installer_docker.sh

ENV CONTAINER=1

RUN /bts/installer_docker.sh

WORKDIR /root/bts

EXPOSE 4000
CMD ["make", "run"]
