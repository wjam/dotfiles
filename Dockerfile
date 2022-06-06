FROM ubuntu:22.04

# Inject timezone data so apt doesn't hang waiting for selection when none will come
RUN echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections
RUN echo 'tzdata tzdata/Zones/Europe select London' | debconf-set-selections

# Homebrew dependencies
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y sudo build-essential procps curl file git

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
CMD /bin/bash
WORKDIR /home/docker
