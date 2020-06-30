#!/bin/bash

# command info
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "-help" ]; then
 echo "config script to switch the Bitcoin Core wallet on or off"
 echo "network.wallet.sh [status|on|off]"
 exit 1
fi

source /mnt/hdd/raspiblitz.conf

# add disablewallet with default value (0) to bitcoin.conf if missing
if ! grep -Eq "^disablewallet=.*" /mnt/hdd/${network}/${network}.conf; then
  echo "disablewallet=0" | sudo tee -a /mnt/hdd/${network}/${network}.conf >/dev/null
fi

# set variable ${disablewallet}
source <(grep -E "^disablewallet=.*" /mnt/hdd/${network}/${network}.conf)


###################
# STATUS
###################
if [ "$1" = "status" ]; then

  echo "##### STATUS disablewallet"
  echo "disablewallet=${disablewallet}"

  exit 0
fi


###################
# switch on
###################
if [ "$1" = "1" ] || [ "$1" = "on" ]; then
  
  if ! grep -Eq "^wallet=wallet.dat" /mnt/hdd/${network}/${network}.conf; then
    echo "Enable the multiwallet feature in ${network} core and specify wallet.dat" 
    echo "wallet=wallet.dat" | sudo tee -a /mnt/hdd/${network}/${network}.conf >/dev/null
    restartService=1
  else
    echo "Multiwallet is active and wallet.dat is used." 
    restartService=0
  fi
  if [ ${disablewallet} == 1 ]; then
    sudo sed -i "s/^disablewallet=.*/disablewallet=0/g" /mnt/hdd/${network}/${network}.conf
    echo "Switching the ${network} core wallet on"
    restartService=1
  else
    echo "The ${network} core wallet is already on"    
  fi
  if [ ${restartService} == 1 ]; then
    echo "Restarting ${network}d"
    sudo systemctl restart ${network}d
  fi
  exit 0
fi


###################
# switch off
###################
if [ "$1" = "0" ] || [ "$1" = "off" ]; then
  sudo sed -i "s/^disablewallet=.*/disablewallet=1/g" /mnt/hdd/${network}/${network}.conf
  sudo systemctl restart ${network}d
  exit 0
fi

echo "FAIL - Unknown Parameter $1"
exit 1
