#!/bin/bash


function version {
	echo "0.1"
}

function usage  {
	echo "Usage:"
	echo "  -d DOMAIN - Digital Ocean managed domain"
	echo "  -r RECORD - Digital Ocean record name"
	echo "  -t DIGITALOCEAN_ACCESS_TOKEN - Digital Ocean API token"
	echo "  -l TTL - TTL for new records, 180 is the default"
	echo "  -v version"

}

while getopts "d:r:t:hv" opt; do
	case ${opt} in
		h )
			usage
			exit 0
			;;
		d )
			DOMAIN=$OPTARG
			;;
		r )
			RECORD=$OPTARG
			;;
		t )
			DIGITALOCEAN_ACCESS_TOKEN=$OPTARG
			;;
		l )
			TTL=$OPTARG
			;;
		v )
			version
			exit
			;;

		\? )
			echo "Invalid option: $OPTARG" 1>&2
			echo
			usage
			exit 1
			;;
		: )
		echo "Invalid option: $OPTARG requires an argument" 1>&2
		echo
		usage
		exit 1
		;;
	esac
done
shift $((OPTIND -1))


# Verify we have all settings
if [[ -z ${DOMAIN} ]]; then
	echo "DOMAIN is not set, please set an enviroment variable DOMAIN or use the -d DOMAIN option"
	exit 2
fi

if [[ -z ${RECORD} ]]; then
	echo "RECORD is not set, please set an enviroment variable RECORD or use the -r RECORD option"
	exit 2
fi

if [[ -z ${DIGITALOCEAN_ACCESS_TOKEN} ]]; then
	echo "DIGITALOCEAN_ACCESS_TOKEN is not set, please set an enviroment variable DIGITALOCEAN_ACCESS_TOKEN or use the -t DIGITALOCEAN_ACCESS_TOKENoption"
	exit 2
fi

if [[ -z ${TTL} ]]; then
	TTL=180
fi




IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "IP: $IP"

AIP=$(doctl compute domain  records list ${DOMAIN} -o json | jq --raw-output --arg RECORD ${RECORD} -c '.[] | select( .name == $RECORD ) | select(.type == "A") | .data' )
ID=$(doctl compute domain  records list ${DOMAIN} -o json | jq --raw-output --arg RECORD ${RECORD} -c '.[] | select( .name == $RECORD ) | select(.type == "A") | .id' )

echo "AIP: $AIP"
echo "ID: $ID"


if [[ "${IP}" == "${AIP}" ]]; then
	echo "No need to update record"
	exit
fi


if [[ -z $ID ]]; then
	echo "Need to create record has we have no ID"
	doctl compute domain  records create ${DOMAIN} --record-type A --record-name ${RECORD} --record-ttl ${TTL} --record-data ${IP}
	exit $?
else
	echo "Updating record ${ID}"
	doctl compute domain  records update ${DOMAIN} --record-id ${ID} --record-data ${IP}
	exit $?
fi
