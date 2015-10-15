#!/bin/bash

command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.2.3

# choose versioni
rvm use 2.2.3 --default

echo 'export PATH="$HOME/.rvm/scripts:$PATH"' >> ~/.bashrc

echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler

gem install rails -v 4.2.4
