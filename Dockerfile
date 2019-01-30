ARG BASE_IMAGE
FROM ${BASE_IMAGE}

##########################################################################
# For the vs-code dev env, assumes you will run docker 
# with a mount to the host's working copy of your project, e.g.
#
#     docker run -v`pwd`:/docker_host ...
#
# The default path for the docker-side mount point is '/docker_host'.
# 
# To use a different docker-side mount point at BUILD time,
# pass your path with build-arg WORKING_COPY, e.g.
#
#     docker build --build-arg WORKING_COPY=/your/preferred/docker-side/mountpoint ...
#
# To use a different docker-side mount point at RUN time,
# pass your path as the environment variable VSCODE_WORKING_COPY, e.g.
#
#     docker run -e VSCODE_WORKING_COPY=`pwd` ...
##########################################################################
ARG VSCODE_WORKING_COPY_DEFAULT=/docker_host
ENV VSCODE_WORKING_COPY=${VSCODE_WORKING_COPY_DEFAULT}
ENV PATH ${VSCODE_WORKING_COPY}/bin:${PATH}
ENV PYTHONPATH ${VSCODE_WORKING_COPY}:${PYTHONPATH}


ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    VSCODE=https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
    TINI_VERSION=v0.16.1


ARG MYUSERNAME=developer
ARG MYUID=2000
ARG MYGID=200
ENV MYUSERNAME=${MYUSERNAME} \
    MYUID=${MYUID} \
    MYGID=${MYGID} 

RUN apt-get update -qq && \
    echo 'Installing OS dependencies' && \
    apt-get install -qq -y --fix-missing \ 
      bash-completion \
      curl \
      libgconf-2-4 \
      libgtk2.0-0 \
      libnotify4 \
      libnspr4 \
      libnss3 \
      libnss3-nssdb \
      libxext-dev \
      libxrender-dev \
      libxslt1.1 \
      libxtst-dev \
      libcanberra-gtk-module \
      libxss1 \
      libxkbfile1 \
      locales \
      locate \
      meld \
      software-properties-common \
      sudo \
    && \
    echo 'Cleaning up' && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y &&  \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    updatedb && \
    locale-gen en_US.UTF-8

RUN echo "Creating user: ${MYUSERNAME} wit UID ${MYUID}" && \
    mkdir -p /home/${MYUSERNAME} && \
    echo "${MYUSERNAME}:x:${MYUID}:${MYGID}:Developer,,,:/home/${MYUSERNAME}:/bin/bash" >> /etc/passwd && \
    echo "${MYUSERNAME}:x:${MYGID}:" >> /etc/group && \
    sudo echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} && \
    sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME} && \
    sudo chown ${MYUSERNAME}:${MYUSERNAME} -R /home/${MYUSERNAME} && \
    sudo chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo && \
    echo 'Installing VsCode' && \
    curl -o vscode.deb -J -L "$VSCODE" && \
    dpkg -i vscode.deb && rm -f vscode.deb 


ENV HOME /home/${MYUSERNAME}
ENV TERM=xterm

WORKDIR /home/${MYUSERNAME}

ARG ENTRYPOINT_FILE=./entrypoint_vscode.sh
ADD ${ENTRYPOINT_FILE} /entrypoint_vscode.sh
RUN chmod +x /entrypoint_vscode.sh

# Add Tini Init System
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini 
ENTRYPOINT ["/tini", "--", "/entrypoint_vscode.sh"]
CMD ["vscode"]
