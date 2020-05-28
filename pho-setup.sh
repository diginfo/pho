ITGT="/usr/share/java/pho"
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $ROOT != "$ITGT" ]; then
  echo "Please install in $TGT"
  exit 0;
fi

cd $ROOT

TGT="/usr/share/java";
REPO="https://github.com/diginfo/pho.git";
BASHDIS="/etc/bashrc.dis";

## Install Java
function java_ {
  apt-get -y update
  apt remove --purge -y default-jdk
  apt -y install software-properties-common
  apt install -y openjdk-8-jre;
  echo "@@@@ JAVA INSTALL DONE.";
}

function pho_ {
  cd $TGT
  echo "Starting up Pure-Pentaho..."
  $TGT/pho/pure-pentaho.sh start;
  echo "@@@ PURE-PENTAHO INSTALLED.";
}

## DISABLED - This is not proven / Tested
function service_ {
  cp -rp $ROOT/pure-pentaho.service /etc/systemd/system
  chmod u+x /etc/systemd/system/pure-pentaho.service
  systemctl daemon-reload
  systemctl enable pure-pentaho.service
  systemctl start pure-pentaho
  systemctl status pure-pentaho
}

## Execute
java_
pho_
service_
