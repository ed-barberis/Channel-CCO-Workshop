#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Docker Compose v2 on Linux x86 64-bit.
#
# Docker Compose is a tool for running multi-container applications on Docker defined using the
# Compose file format. A Compose file is used to define how one or more containers that make up
# your application are configured. Once you have a Compose file, you can create and start your
# application with a single command: 'docker compose up'.
#
# Docker Compose V2 is a major version bump release of Docker Compose. It has been completely
# rewritten from scratch in Golang (V1 was in Python). The installation instructions for Compose V2
# differ from V1. V2 is not a standalone binary anymore, and installation scripts will have to be
# adjusted. Some commands are different.
#
# For a smooth transition from legacy docker-compose 1.xx, please consider installing
# i'compose-switch' to translate 'docker-compose' commands into Compose V2's docker compose. Also
# check V2's --compatibility flag.
#
# For more details, please visit:
#   https://github.com/docker/compose
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install docker compose v2 cli. -------------------------------------------------------------------
dc_release="2.27.0"
dc_home="/usr/libexec/docker/cli-plugins"
dc_binary="docker-compose-linux-x86_64"
dc_sha256="f3ba3bf1e4ab18e96c2d36526a075a02a78fb5f8e80d3e3ca9c5bf256d81d0a0"

# create docker cli-plugins directory (if needed).
mkdir -p ${dc_home}
cd ${dc_home}

# download docker compose binary from github.com.
rm -f ${dc_binary} docker-compose
curl --silent --location "https://github.com/docker/compose/releases/download/v${dc_release}/${dc_binary}" --output docker-compose
chown root:root docker-compose

# verify the downloaded binary.
echo "${dc_sha256} docker-compose" | sha256sum --check
# docker-compose: OK

# change execute permissions.
chmod 755 docker-compose

# set docker compose home environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
docker compose version
