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

FROM debian:stretch-slim
ARG JAVA_VERSION="jdk-11.0.7%2B10_openj9-0.20.0"
ARG GLIBC_VER="2.31-r0"

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

#  NOTE:  Should we provide a file of URL's and checksums so we can be sure the
#         that the JDK download is not vulnerable to a man-in-the-middle attack?
#hadolint ignore=DL3008
RUN : \
 && apt-get update \
 && apt-get -y --no-install-recommends install \
      ash \
      curl ca-certificates \
      locales \
 && rm -rf /var/lib/apt/lists/* \
 && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 && :

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

COPY transformEnvironment.sh copyJMXFiles.sh /
RUN : \
 && mkdir -p /opt/java/openjdk /logs \
 && api_root="https://api.adoptopenjdk.net/v3" arch=$(uname -m | sed -e 's/x86_64/x64/') \
 && url="${api_root}/binary/version/${JAVA_VERSION}/linux/${arch}/jdk/openj9/normal/adoptopenjdk" \
 && echo "Retreiving JDK via ${url}" \
 && curl -sL "${url}" | tar zfx - -C /opt/java/openjdk --strip-components=1 \
 && chmod +x /transformEnvironment.sh copyJMXFiles.sh \
 && :
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH" \
    JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"
