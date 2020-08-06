#!/usr/bin/env bash

[ "$(whoami)" != "centos" ] && echo "Only supported for the user centos. Exiting..." && exit 1

[ "$1" == "-d" ] && CMD=delete || CMD=apply

# run in the directory, where $0 is located:
DIR=$(cd $(dirname $0); pwd) \
  && cd $DIR

mkdir -p $HOME/.vocloud/.IdeaIC2019.3
mkdir -p $HOME/.vocloud/.local
mkdir -p $HOME/git
mkdir -p $HOME/.vocloud/.java
mkdir -p $HOME/.vocloud/.m2
mkdir -p $HOME/.ssh

#cat deploy/intellijDesktopClaim.yaml      | kubectl $CMD -f -
cat deploy/deploy.yaml | kubectl $CMD -f -

