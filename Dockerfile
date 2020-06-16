FROM oraclelinux:7-slim

RUN set -eux; \
    yum install -y \ 
        gzip \
        tar \
        \
        freetype fontconfig \
    ; \
    rm -rf /var/cache/yum

ENV LANG en_US.UTF-8

ENV JAVA_HOME /usr/java/openjdk-13
ENV PATH $JAVA_HOME/bin:$PATH

ENV JAVA_VERSION 13-ea+27
ENV JAVA_URL https://download.java.net/java/early_access/jdk13/27/GPL/openjdk-13-ea+27_linux-x64_bin.tar.gz
ENV JAVA_SHA256 5a19debb43fece867b7ab2b0d35d8a33ba4568ae01ae443d25f4b53357546044

RUN set -eux; \
	\
	curl -fL -o /openjdk.tgz "$JAVA_URL"; \
	echo "$JAVA_SHA256 */openjdk.tgz" | sha256sum -c -; \
	mkdir -p "$JAVA_HOME"; \
	tar --extract --file /openjdk.tgz --directory "$JAVA_HOME" --strip-components 1; \
	rm /openjdk.tgz; \
	\
	ln -sfT "$JAVA_HOME" /usr/java/default; \
	ln -sfT "$JAVA_HOME" /usr/java/latest; \
	for bin in "$JAVA_HOME/bin/"*; do \
		base="$(basename "$bin")"; \
		[ ! -e "/usr/bin/$base" ]; \
		alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
	done; \
	\
	java -Xshare:dump; \
	\
	java --version; \
	javac --version

ADD . /server

WORKDIR /server

EXPOSE 25565

CMD echo eula=true > /server/eula.txt && java -jar server.jar nogui