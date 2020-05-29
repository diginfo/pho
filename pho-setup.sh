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

function rm_ {
  mv /etc/java-8-openjdk/accessibility.properties.org /etc/java-8-openjdk/accessibility.properties;
  apt remove --purge -y libjfreechart-java default-jdk openjdk-8-jre openjdk-8-jre-headless;
  systemctl disable pure-pentaho.service;
  systemctl stop pure-pentaho;
  systemctl daemon-reload;
  rm -rf /etc/systemd/system/pure-pentaho.service;
  apt -y autoremove;
}

## Install Java
function java_ {
  apt-get -y update
  apt remove --purge -y default-jdk openjdk-8-jre openjdk-8-jre-headless
  apt install -y openjdk-8-jre libjfreechart-java;
  echo "@@@@ JAVA INSTALL DONE.";
  # mv /etc/java-8-openjdk/accessibility.properties /etc/java-8-openjdk/accessibility.properties.orig;
  # echo -e "## file moved to accessibility.properties.orig by pho-setup.sh\n\n" > /etc/java-8-openjdk/accessibility.properties
}

function pho_ {
  cd $TGT
  echo "Starting up Pure-Pentaho..."
  $TGT/pho/pure-pentaho.sh start;
  echo "@@@ PURE-PENTAHO INSTALLED.";
}

function alias_ {
  if [ ! -f "$BRC" ]; then
    echo ". $BRC" >> /etc/bash.bashrc
  fi
  echo "alias pure-pentaho-start=\"service pure-pentaho start\"" > $BRC;
  echo "alias pure-pentaho-stop=\"service pure-pentaho stop\"" >> $BRC;
  echo "alias pure-pentaho-restart=\"service pure-pentaho restart\"" >> $BRC;
  echo "alias pure-pentaho-logs=\"tail -f $ITGT/log/pure-pentaho.log\"" >> $BRC;
  source /etc/bash.bashrc;
}

function service_ {
  cp -rp $ROOT/pure-pentaho.service /etc/systemd/system
  chmod u+x /etc/systemd/system/pure-pentaho.service
  systemctl daemon-reload
  systemctl enable pure-pentaho.service
  systemctl start pure-pentaho
  systemctl status pure-pentaho
}

if 
[ $1 == "rm" ];then
  echo "Removing JRE and Pentaho..."
  rm_;
  exit 0;
else
  ## Execute
  java_;
  service_;
  alias_;
fi;

