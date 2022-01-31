#!/bin/bash


usage()
{
    echo -e "NuvlaBox Edge Impulse Runner"
    echo -e ""
    echo -e "./runner.sh"
    echo -e ""
    echo -e " -h --help"
    echo -e " --api-key=STRING\t\t\t API key for the Edge Impulse project"
    echo -e " --hmac-key=STRING\t\t\t HMAC key to sign new data with"
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
        --api-key)
            api_key=$VALUE
            ;;
        --hmac-key)
            hmac_key=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

edge-impulse-linux-runner --api-key ${api_key} --hmac-key ${hmac_key}