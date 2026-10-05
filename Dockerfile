FROM node:20-bookworm-slim

RUN apt-get update -qq && \
    apt-get install -qy make git htop psmisc bash curl sudo && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /bts

COPY . .
RUN chmod +x /bts/installer_docker.sh

ENV CONTAINER=1

EXPOSE 4000
CMD ["bash", "-lc", "/bts/installer_docker.sh && cd /root/bts && make run"]
