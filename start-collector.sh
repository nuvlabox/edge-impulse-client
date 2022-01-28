#!/bin/bash

strategies="MANUAL AUTO MANUAL_AUTO"
strategy="MANUAL_AUTO"

usage()
{
    echo -e "NuvlaBox Edge Impulse Collector"
    echo -e ""
    echo -e "./start-collector.sh"
    echo -e ""
    echo -e " -h --help"
    echo -e " --collection-strategy=STRING\t\t\t(optional) How to collect and upload data into Edge Impulse Studio. Must be on of: ${strategies}. Default: ${strategy}"
    echo -e "\t\t MANUAL - Connects to Edge Impulse Studio and waits for the user to manually collect the samples via the user interface"
    echo -e "\t\t AUTO - Collects and uploads samples automatically, based on an interval (env var) defined by the user at deployment time"
    echo -e "\t\t MANUAL_AUTO - Tried to run in MANUAL mode, and if it fails, falls back to AUTO mode if possible"
    echo -e ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | cut -d "=" -f 2-`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --collection-strategy)
            strategy=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ "${strategy}" = "AUTO" ]]
then
  ./collect-and-upload.py
else
  echo automate | edge-impulse-linux --api-key $EDGE_IMPULSE_API_KEY --hmac-key $EDGE_IMPULSE_HMAC_KEY --clean --disable-microphone

  if [[ $? -ne 0 ]] && [[ "${strategy}" = "MANUAL_AUTO" ]]
  then
    echo "ERR: failed to start Edge Impulse binaries for manual collection. Trying to collect samples automatically"
    ./collect-and-upload.py
  fi
fi


