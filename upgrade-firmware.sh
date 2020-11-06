#/bin/sh

MAIN_URL_FTP=ftp://ftp.dd-wrt.com/betas
MAIN_URL_HTTPS=https://download1.dd-wrt.com/dd-wrtv2/downloads/betas
YEAR=$(date +%Y)
LATEST_BUILD=$(curl -s ${MAIN_URL_FTP}/${YEAR}/ | tail -1 | awk '{print $9}')
LATEST_BUILD_ID=$(echo ${LATEST_BUILD} | awk -F - '{print $4}')
LATEST_BUILD_ID_WOUT_R=${LATEST_BUILD_ID:1}

# how to get dd-wrt device name from somewhere else than nvram?
DD_BOARD=$(nvram get DD_BOARD)

case $DD_BOARD in
	"Asus RT-AC68U C1")
		FILENAME=asus_rt-ac68u-firmware.trx
		DIRECTORY=asus-rt-ac68u
		;;
	"Asus RT-N66U")
		FILENAME=dd-wrt.v24-${LATEST_BUILD_ID_WOUT_R}_NEWD-2_K3.x-big-RT-N66U.trx
		DIRECTORY=broadcom_K3X
		;;
	*)
		echo "No model match, exiting."
		exit 1
esac



URL=${MAIN_URL_FTP}/${YEAR}/${LATEST_BUILD}/${DIRECTORY}/${FILENAME}
echo "Downloading ${URL}"

curl -fs ${URL} -o /tmp/firmware.trx

# Unfortunately, nginx at download1.dd-wrt.com returns 200 when it should return 404.
# Since that's quite risky (the next step would flash a HTML page), we download through FTP.
if [[ $? -ne 0 ]]; then
	echo "Error downloading! Firmware not upgraded."
	exit 1
else
	write /tmp/firmware.trx linux
	if [[ $? -ne 0 ]]; then
		echo "Error flashing! not rebooting."
		exit 1
	else
		reboot
	fi
fi
