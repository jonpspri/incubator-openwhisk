#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG ADOPTOPENJDK_TARGET_REGISTRY=adoptopenjdk
FROM ${ADOPTOPENJDK_TARGET_REGISTRY}/openjdk8:jdk8u192-b12

ENV DOCKER_VERSION 1.12.0
ENV KUBECTL_VERSION v1.16.3
ENV WHISK_CLI_VERSION latest
ENV WHISKDEPLOY_CLI_VERSION latest

RUN apt-get -q update \
  && DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
    apt-transport-https \
    gcc \
    git \
    gnupg \
    libc6-dev \
    libffi-dev \
    libpython2.7-dev \
    make \
    nodejs \
    npm \
    python \
    python-pip \
    software-properties-common \
    wget \
    zip \
  && rm -rf /var/lib/apt/lists/*

# Make sure pipes (even implicit ones) fail the job if they fail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade to a modern pip
RUN pip install --upgrade pip==18.1

# Python packages
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install ansible==2.5.2 && \
    pip install jinja2==2.9.6 && \
    pip install docker

# Install docker client
RUN if [ "$(uname -m)" = x86_64 ]; then \
      wget -q -O - \
        https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
      | tar --strip-components 1 -xvzf - -C /usr/bin docker/docker && chmod +x /usr/bin/docker \
; else \
     debarch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/ppc64le/ppc64el/' -e 's/aarch64/arm64/')" \
     && wget -q -O - https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
     && add-apt-repository \
        "deb [arch=$debarch] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
     && apt-get update \
     && apt-get install -y --no-install-recommends docker-ce \
     && rm -rf /var/lib/apt/lists \
; fi

# Install kubectl in /usr/local/bin
RUN wskarch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')" \
 && wget -q "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${wskarch}/kubectl" \
 && chmod +x kubectl \
 && mv kubectl /usr/local/bin/kubectl

# Install `wsk` cli in /usr/local/bin
RUN wget -q https://github.com/apache/openwhisk-cli/releases/download/$WHISK_CLI_VERSION/OpenWhisk_CLI-$WHISK_CLI_VERSION-linux-amd64.tgz && \
  tar xzf OpenWhisk_CLI-$WHISK_CLI_VERSION-linux-amd64.tgz -C /usr/local/bin wsk && \
  rm OpenWhisk_CLI-$WHISK_CLI_VERSION-linux-amd64.tgz

# Install wskadmin in /bin
COPY wskutil.py /bin
COPY wskprop.py /bin
COPY wskadmin /bin

# Setup tools/data for certificate generation (used by openwhisk-deploy-kube)
RUN mkdir /cert-gen
COPY openwhisk-server-key.pem /cert-gen
COPY genssl.sh /usr/local/bin/
