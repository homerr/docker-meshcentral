FROM lsiobase/alpine:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MESHCEN_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="homerr"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	git \
	nodejs-npm && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	curl \
	jq \
	nodejs \
	nodejs-npm && \
 echo "**** grab MeshCentral ****" && \
 if [ -z ${MESHCEN_COMMIT}+x} ]; then \
	MESHCEN_COMMIT=$(curl -sX GET "https://api.github.com/repos/Ylianst/MeshCentral/commits/master" \
	| jq -r '. | .sha'); \
 fi && \
 git clone https://github.com/Ylianst/MeshCentral.git /app/meshcentral && \
 echo "**** install MeshCentral ****" && \
 npm config set unsafe-perm true && \
 npm i npm@latest -g && \
 npm i archiver@4.0.2 -g && \
 npm install --prefix /app/meshcentral && \
 chown -R abc:abc /app  && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# app runs on port 80
EXPOSE 80
