FROM ubuntu:xenial

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get -qq update          \
 && apt-get -qq upgrade -y      \
 && apt-get -qq install -y curl \
 && apt-get -qq clean -y        \
 && rm -fR /tmp/*

# ------------------------------------------------------------------------ java8
ENV ZULU_VERSION 8.15.0.1-jdk8.0.92
RUN mkdir -p /usr/lib/jvm \
 && cd /usr/lib/jvm \
 && curl https://cdn.azul.com/zulu/bin/zulu$ZULU_VERSION-linux_x64.tar.gz | gunzip -c | tar x \
 && cd zulu$ZULU_VERSION-linux_x64 \
 && rm -fR src.zip demo sample

ENV JAVA_HOME /usr/lib/jvm/zulu8.$ZULU_VERSION-linux_x64
ENV JRE_HOME  $JAVA_HOME/jre
ENV PATH $PATH:$JAVA_HOME/bin

# --------------------------------------------------------------------- tcnative
ENV APR_VERSION 1.5.2
ENV TCNATIVE_VERSION 1.2.7

RUN apt-get -qq update \
 && apt-get -qq install -y build-essential libssl-dev libpcre++-dev zlib1g-dev \

 && (curl -L http://www.us.apache.org/dist/apr/apr-$APR_VERSION.tar.gz | gunzip -c | tar x) \
 && cd apr-$APR_VERSION \
 && ./configure \
 && make install \

 && (curl -L http://www.us.apache.org/dist/tomcat/tomcat-connectors/native/$TCNATIVE_VERSION/source/tomcat-native-$TCNATIVE_VERSION-src.tar.gz | gunzip -c | tar x) \
 && cd tomcat-native-$TCNATIVE_VERSION-src/native \
 && ./configure --with-java-home=$JAVA_HOME --with-apr=/usr/local/apr --prefix=/usr \
 && make install \

 && apt-get -qq purge -y build-essential dpkg-dev g++ gcc perl libc6-dev make libssl-dev libpcre++-dev zlib1g-dev \
 && apt-get -qq autoremove -y \
 && apt-get -qq clean \
 && rm -fR /tmp/* /apr-* /tomcat-native-*
