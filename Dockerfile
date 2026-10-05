#FROM node:22.23.3-trixie-slim
FROM node:20-bookworm-slim

RUN apt-get update -qq && \
	apt-get install -qy make git \
		htop psmisc && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /bts
#ADD package.json package-lock.json ./
RUN npm ci --only=prod

#RUN mkdir -p static/bup/
#ADD div/bupdate.js div/
#ADD Makefile ./
#RUN make bupdate
#RUN make install-bup-dev

RUN chmod +x /installer.sh

ADD . .

EXPOSE 4000
CMD ["make", "run"]
