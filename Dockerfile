FROM ubuntu:17.04

# ------------------------------------------------------
# --- Install required tools
RUN apt-get update -qq

# Base (non android specific) tools
# -> should be added to bitriseio/docker-bitrise-base

# Dependencies to execute Android builds
#RUN dpkg --add-architecture i386
#RUN apt-get update -qq
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386
RUN apt-get install -y openjdk-8-jdk wget expect git curl

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_SDK_HOME
RUN useradd -u 1000 -M -s /bin/bash android
RUN chown 1000 /opt

USER android
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux

RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -O android-sdk.tgz
RUN cd /opt && tar -xvzf android-sdk.tgz
RUN cd /opt && rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/platform-tools:/opt/tools

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter android-23 | grep 'package installed'

# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter build-tools-20.0.0 | grep 'package installed'

# Extras
RUN echo y | android update sdk --no-ui --all --filter extra-android-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-google_play_services | grep 'package installed'

# Copy install tools
COPY tools /opt/tools

#Copy accepted android licenses
COPY licenses ${ANDROID_SDK_HOME}/licenses

# Update SDK
# RUN /opt/tools/android-accept-licenses.sh "android update sdk --no-ui --obsolete --force"

USER root

RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN apt-get install -y libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

RUN apt-get clean

VOLUME ["/opt/android-sdk-linux"]