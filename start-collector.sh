#!/bin/bash

strategies="MANUAL AUTO MANUAL_AUTO"
strategy="MANUAL_AUTO"
video_device="/dev/video0"

usage()
{
    echo -e "NuvlaBox Edge Impulse Collector"
    echo -e ""
    echo -e "./start-collector.sh"
    echo -e ""
    echo -e " -h --help"
    echo -e " --collection-strategy=STRING\t\t(optional) How to collect and upload data into Edge Impulse Studio. Must be on of: ${strategies}. Default: ${strategy}"
    echo -e "\t\t MANUAL - Connects to Edge Impulse Studio and waits for the user to manually collect the samples via the user interface"
    echo -e "\t\t AUTO - Collects and uploads samples automatically, based on an interval (env var) defined by the user at deployment time"
    echo -e "\t\t MANUAL_AUTO - Tried to run in MANUAL mode, and if it fails, falls back to AUTO mode if possible"
    echo -e " --video-device=STRING\t\t\t(optional) Video file where to collect the video feed from. Default: ${video_device}"
    echo -e " --api-key=STRING\t\t\t API key for the Edge Impulse project"
    echo -e " --hmac-key=STRING\t\t\t HMAC key to sign new data with"
    echo -e " --label=STRING\t\t\t\t(optional) Label prefix for the video samples, in case of AUTO collection"
    echo -e " --interval=STRING\t\t\t(optional) Image sampling frequency (in seconds) when in AUTO collection mode"
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
        --video-device)
            video_device=$VALUE
            ;;
        --api-key)
            api_key=$VALUE
            ;;
        --hmac-key)
            hmac_key=$VALUE
            ;;
        --label)
            label=$VALUE
            ;;
        --interval)
            interval=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

export VIDEO_DEVICE=${video_device}

if [[ ! -z "${api_key}" ]]
then
  export EDGE_IMPULSE_API_KEY=${api_key}
fi

if [[ ! -z "${hmac_key}" ]]
then
  export EDGE_IMPULSE_HMAC_KEY=${hmac_key}
fi

if [[ ! -z "${label}" ]]
then
  export LABEL_NAME_IDENTIFIER=${label}
fi

if [[ ! -z "${interval}" ]]
then
  export COLLECTION_INTERVAL=${interval}
fi


if [[ "${strategy}" = "AUTO" ]]
then
  ./collect-and-upload.py
else
  echo ${NUVLABOX_UUID:-${HOSTNAME:-nuvlabox}} | edge-impulse-linux --api-key $EDGE_IMPULSE_API_KEY --hmac-key $EDGE_IMPULSE_HMAC_KEY --clean --disable-microphone

  if [[ $? -ne 0 ]] && [[ "${strategy}" = "MANUAL_AUTO" ]]
  then
    echo "ERR: failed to start Edge Impulse binaries for manual collection. Trying to collect samples automatically"
    ./collect-and-upload.py
  fi
fi


