#!/bin/bash

function indent() {
  sed -u "s/^/       /"
}

DEFAULT_LOCALE="en_US.UTF-8"
if [[ ! "$(locale)" =~ "$DEFAULT_LOCALE" ]]; then
  echo "-----> Setting default locale to: $DEFAULT_LOCALE"
  echo -e "LANG=$DEFAULT_LOCALE\nLANGUAGE=$DEFAULT_LOCALE\nLC_ALL=$DEFAULT_LOCALE" | sudo tee /etc/default/locale
  locale-gen $DEFAULT_LOCALE
  sudo dpkg-reconfigure locales
fi
echo "locale:  $(locale)" | head -n 1

if [ "`tail -1 /root/.profile`" = "mesg n" ]; then
  echo 'Patching basebox to prevent future `stdin: is not a tty` errors...'
  sed -i '$d' /root/.profile
  cat << 'EOH' >> /root/.profile
  if `tty -s`; then
    mesg n
  fi
EOH
fi

if [ ! -f /usr/bin/curl ]; then
  echo "Installing curl"
  sudo apt-get install curl -y
fi
echo "curl:    $(curl --version)" | head -n 1

if [[ ! "$(ruby --version)" =~ "ruby 1.9.3" ]]; then
  echo "Upgrading ruby to 1.9.1"
  sudo apt-get install ruby1.9.1 ruby1.9.1-dev \
    rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 \
    build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev \
    libxslt-dev libxml2-dev -y
   
  sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
           --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                          /usr/share/man/man1/ruby1.9.1.1.gz \
          --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
          --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
          --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1
   
  # choose your interpreter
  # changes symlinks for /usr/bin/ruby , /usr/bin/gem
  # /usr/bin/irb, /usr/bin/ri and man (1) ruby
  sudo update-alternatives --config ruby || true
  sudo update-alternatives --config gem  || true

  echo -e "#Ensure gems are in path\nexport PATH=\$PATH:/var/lib/gems/1.9.1/bin/" >> /etc/profile
fi
echo "ruby:    $(ruby --version)"

if [[ "$(gem query -n bundler -d | wc -l)" =~ "1" ]]; then
  sudo gem install bundle --no-ri --no-rdoc
fi

if [ ! -f /usr/bin/git ]; then
  echo "Installing git"
  sudo apt-get install git-core -y
fi
echo "git:     $(git --version)"

if [[ ! "$(node --version)" =~ "v0.10" ]]; then
  echo "Installing nodejs"
  sudo apt-get install python-software-properties -y
  sudo add-apt-repository ppa:richarvey/nodejs -y  
  sudo apt-get update
  sudo apt-get install nodejs npm -y
fi
echo "node:    $(node -v)"

if [ ! -f /usr/local/ti-debug/bin/dbgp ]; then
  echo "Installing ti-debug"
  git clone https://github.com/dpb587/ti-debug /usr/local/ti-debug
  pushd /usr/local/ti-debug
  npm install
  popd
fi
echo "ti-debug:$(/usr/local/ti-debug/bin/dbgp --version)"

if [ ! -f /usr/bin/stackato ]; then
    sudo curl -k --location -o /tmp/stackato.zip http://downloads.activestate.com/stackato/client/v1.7.2/stackato-1.7.2-linux-glibc2.3-x86_64.zip 
    sudo apt-get install unzip -y 
    sudo unzip /tmp/stackato.zip -d /tmp
    sudo mv /tmp/stackato-1.7.2-linux-glibc2.3-x86_64/stackato /usr/bin
    sudo rm -rf /tmp/stackato*
fi
echo "stackato:$(stackato --version)"

echo "Clean up..."
sudo apt-get autoremove -y | tail -n 2 | indent
rm -f /home/vagrant/postinstall.sh

echo "Copying host source files into place"
rsync -a --exclude='.git*' --exclude='.vagrant' --exclude='.DS_Store' /vagrant/ /home/vagrant/

echo "Configuring build dependancies"
bundle install | indent

echo "=-=-=-=-=-=-=-=-=-=-=-="
echo "Provisioning completed!"
echo "=-=-=-=-=-=-=-=-=-=-=-="
