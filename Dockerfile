#FROM node:22.23.3-trixie-slim
FROM node:20-bookworm-slim

RUN apt-get update -qq && \
    apt-get install -qy make git htop psmisc bash curl sudo && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /bts

COPY . .
RUN chmod +x /bts/installer.sh

EXPOSE 4000
CMD ["/bts/installer.sh"]
