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
	nodejs-npm && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	curl \
	jq \
	nodejs \
 echo "**** grab MeshCentral ****" && \
 if [ -z ${MESHCEN_COMMIT}+x} ]; then \
	MESHCEN_COMMIT=$(curl -sX GET "https://api.github.com/repos/Ylianst/MeshCentral/commits/master" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/meshcentral.tar.gz -L \
	"https://github.com/Ylianst/MeshCentral/${MESHCEN_COMMIT}}.tar.gz" && \
 echo "**** install MeshCentral ****" && \
 tar xf \
 /tmp/meshcentral.tar.gz -C \
	/app/ --strip-components=1 && \
 npm config set unsafe-perm true && \
 npm i npm@latest -g && \
 npm install --prefix /app && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# app runs on port 80
EXPOSE 80
