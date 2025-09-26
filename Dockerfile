FROM ubuntu:24.04

# Inject timezone data so apt doesn't hang waiting for selection when none will come
ENV TZ=Europe/London

# Homebrew dependencies
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y sudo build-essential procps curl file git tzdata ca-certificates && \
    ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# set the password to empty
RUN passwd -d docker

# avoid needing password for sudo
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER docker
ENV USER=docker

# stop Homebrew from asking for user confirmation
ENV NONINTERACTIVE=1
RUN /bin/bash -c "$(curl --show-error --silent --fail --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

RUN mkdir --mode=0700 /home/docker/.local

CMD /bin/bash
WORKDIR /home/docker
