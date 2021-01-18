FROM ubuntu:focal

MAINTAINER Leonard Marschke <github@marschke.me>

# Set pythonunbuffered for getting better outputs in combination with GitLab CI
ENV PYTHONUNBUFFERED=1

# Set noninteractive environment
ENV DEBIAN_FRONTEND=noninteractive

# Set language environment to UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# install build dependencies
RUN apt-get update \
# upgrade software
	&& apt-get -y upgrade \
	&& apt-get -y install apt-transport-https \
		ca-certificates \
		curl \
		dnsutils \
		software-properties-common \
		iputils-ping \
# clean up
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*


RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# update software repos
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
	apt-get update \
# upgrade software
	&& apt-get -y upgrade \
	&& apt remove cmdtest \
	&& apt-get -y install apt-utils \
# install some useful tools need to build (git is needed to use with gitlab ci)
	&& apt-get -y install \
# install essential build tools
		git \
		build-essential \
		curl \
		wget \
# Java
		openjdk-8-jdk \
		gradle \
		maven \
# Javascript
		nodejs \
# deployment
		rsync \
		zstd \
	&& apt install --no-install-recommends yarn \
# clean up
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*


# Inspired by https://github.com/beevelop/docker-android

# https://developer.android.com/studio/#downloads
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip" \
	ANDROID_BUILD_TOOLS_VERSION=29.0.3 \
	ANT_HOME="/usr/share/ant" \
	MAVEN_HOME="/usr/share/maven" \
	GRADLE_HOME="/usr/share/gradle" \
	ANDROID_HOME="/opt/android" \
	ANDROID_SDK_ROOT="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

# Installs Android SDK
RUN mkdir $ANDROID_HOME \
	&& cd $ANDROID_HOME \
	&& wget -O /opt/tools.zip ${ANDROID_SDK_URL} \
	&& unzip /opt/tools.zip \
	&& rm /opt/tools.zip \
	&& rm -rf $ANDROID_HOME/licenses

RUN ls $ANDROID_HOME

RUN mkdir /root/.android && touch /root/.android/repositories.cfg \
	&& while true; do echo 'y'; sleep 2; done | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
	&& while true; do echo 'y'; sleep 2; done | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-10" "platforms;android-15" "platforms;android-16" "platforms;android-17" "platforms;android-18" "platforms;android-19" \
	&& while true; do echo 'y'; sleep 2; done | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-20" "platforms;android-21" "platforms;android-22" "platforms;android-23" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" \
	&& while true; do echo 'y'; sleep 2; done | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-28" "platforms;android-29"

RUN while true; do echo 'y'; sleep 2; done | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository"
RUN while true; do echo 'y'; sleep 2; done | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "add-ons;addon-google_apis-google-15" "add-ons;addon-google_apis-google-16" "add-ons;addon-google_apis-google-17" "add-ons;addon-google_apis-google-18" "add-ons;addon-google_apis-google-19" "add-ons;addon-google_apis-google-21" "add-ons;addon-google_apis-google-22" "add-ons;addon-google_apis-google-23" "add-ons;addon-google_apis-google-24"

RUN chmod a+x -R $ANDROID_HOME && \
	chown -R root:root $ANDROID_HOME
