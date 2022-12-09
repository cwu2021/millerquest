#!/bin/bash
# fireup an old version ubuntu on docker host, then run this script to install ruby 1.8.7.
# docker run -it --name precise ubuntu:12.04
sed -i -e 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
apt-get update
apt-get install vim ruby wget
ruby --version
# millerquest-0.9.1 just works.
wget https://web.archive.org/web/20110202053521/http://www.beastwithin.org/users/wwwwolf/games/millerquest/millerquest-0.9.1.tar.bz2
