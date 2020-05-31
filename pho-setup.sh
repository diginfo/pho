ITGT="/usr/share/java/pho"
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BRC="/etc/bashrc.dis";

if [ $ROOT != "$ITGT" ]; then
  echo "Please install in $ITGT"
  exit 0;
fi

cd $ROOT

TGT="/usr/share/java";
REPO="https://github.com/diginfo/pho.git";
BASHDIS="/etc/bashrc.dis";

# jfrecharts errors.
## use openjdk-8-jre and NOT openjdk-8-jre-headless
## also needs "-Djava.awt.headless=true"

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
  if [ ! -f "$BRC" ]; then
    echo "source $BRC" >> /etc/bash.bashrc
  fi
  echo "## PURE-PENTAHO" >> $BRC;
  echo "alias pure-pentaho=\"service pure-pentaho\"" >> $BRC;
  echo "alias pure-pentaho-help=\"$ITGT/pho-setup.sh readme\"" >> $BRC;
  echo "alias pure-pentaho-start=\"service pure-pentaho start\"" >> $BRC;
  echo "alias pure-pentaho-stop=\"service pure-pentaho stop\"" >> $BRC;
  echo "alias pure-pentaho-restart=\"service pure-pentaho restart\"" >> $BRC;
  echo "alias pure-pentaho-status=\"service pure-pentaho status\"" >> $BRC;
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

function _logo {
  echo "   ___  __  _____  ____    ___  _____  ___________   __ ______ "
  echo "  / _ \/ / / / _ \/ __/___/ _ \/ __/ |/ /_  __/ _ | / // / __ \"
  echo " / ___/ /_/ / , _/ _//___/ ___/ _//    / / / / __ |/ _  / /_/ /"
  echo "/_/   \____/_/|_/___/   /_/  /___/_/|_/ /_/ /_/ |_/_//_/\____/ "
  echo
}

function _readme {
  ./glow README.md
}

function _help {
  _readme;   
}

if [ "$#" -eq 0 ]; then
  _help;
else
  fn="_$1"
  "$fn"
fi

_logo;
