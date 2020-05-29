ITGT="/usr/share/java/pho"
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BRC="/etc/bashrc.dis";

if [ $ROOT != "$ITGT" ]; then
  echo "Please install in $TGT"
  exit 0;
fi

cd $ROOT

TGT="/usr/share/java";
REPO="https://github.com/diginfo/pho.git";
BASHDIS="/etc/bashrc.dis";

# -Djava.awt.headless=true = no-charts
# -Djava.awt.headless=false = crash

## Prompt Continue
function _continue {
  read -p "Continue Y/N? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    exit 0
  fi
}

## Prompt Wait ($1)
function _wait {
  echo
  echo "$1"
  _continue;
}

function _rm {
  _wait "Remove & Purge Java & Pentaho ?"
  apt remove --purge -y libjfreechart-java default-jdk openjdk-8-jre openjdk-8-jre-headless;
  systemctl disable pure-pentaho.service;
  systemctl stop pure-pentaho;
  rm -rf /etc/systemd/system/pure-pentaho.service;
  systemctl daemon-reload
  apt -y autoremove;
}

## Install Java
function _java {
  _wait "Update O/S and Install Pentaho ?"
  apt-get -y update;
  apt install -y openjdk-8-jre libjfreechart-java;
  # mv /etc/java-8-openjdk/accessibility.properties /etc/java-8-openjdk/accessibility.properties.orig;
  # echo -e "## file moved to accessibility.properties.orig by pho-setup.sh\n\n" > /etc/java-8-openjdk/accessibility.properties
}

function _alias {
  _wait "Install Pentaho Aliases ?"
  if [ ! -f "$BRC" ]; then
    echo ". $BRC" >> /etc/bash.bashrc
  fi
  echo "alias pure-pentaho=\"service pure-pentaho\"" > $BRC;
  echo "alias pure-pentaho-logs=\"tail -f $ITGT/log/pure-pentaho.log\"" >> $BRC;
  source /etc/bash.bashrc;
}

function _service {
  _wait "Install Pentaho Service ?"
  cp -rp $ROOT/pure-pentaho.service /etc/systemd/system
  chmod u+x /etc/systemd/system/pure-pentaho.service
  systemctl daemon-reload
  systemctl enable pure-pentaho.service
  systemctl start pure-pentaho
  systemctl status pure-pentaho
}

function _all {
  _wait "Full Pentaho Install ?"
  _rm;
  _java;
  _service;
  _alias;  
}

function _help {
  echo "USAGE pho-setup.sh | rm | all | java | service | alias | help"
  echo "FULL INSTALL: pho-setup.sh all"    
}

if [ "$#" -eq 0 ]; then
  _help;
else
  fn="_$1"
  "$fn"
fi

