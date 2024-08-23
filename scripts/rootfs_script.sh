#!/bin/bash

# get image id from the path to output
IMAGE_ID=$(echo $BR2_CONFIG | awk -F '/' '{print $(NF-1)}')
HOSTNAME=$(echo $IMAGE_ID | awk -F '_' '{print $1 "-" $2}')

cd $BR2_EXTERNAL
GIT_BRANCH=$(git branch | grep ^* | awk '{print $2}')
GIT_HASH=$(git show -s --format=%H)
GIT_TIME=$(git show -s --format=%ci)
BUILD_ID="${GIT_BRANCH}+${GIT_HASH:0:7}, ${GIT_TIME}"
cd -

FILE=${TARGET_DIR}/usr/lib/os-release
# prefix exiting buildroot entires
tmpfile=$(mktemp)
sed 's/^/BUILDROOT_/' $FILE > $tmpfile
# create our own release file
{
	echo "NAME=Thingino"
	echo "ID=thingino"
	echo "VERSION=\"1 (Ciao)\""
	echo "VERSION_ID=1"
	echo "VERSION_CODENAME=ciao"
	echo "PRETTY_NAME=\"Thingino 1 (Ciao)\""
	echo "ID_LIKE=buildroot"
	echo "CPE_NAME=\"cpe:/o:thinginoproject:thingino:1\""
	echo "LOGO=thingino-logo-icon"
	echo "ANSI_COLOR=\"1;34\""
	echo "HOME_URL=\"https://thingino.com/\""
	echo "ARCHITECTURE=mips"
	echo "IMAGE_ID=${IMAGE_ID}"
	echo "BUILD_ID=\"${BUILD_ID}\""
	echo "HOSTNAME=ing-${HOSTNAME}"
	date +TIME_STAMP=%s
	cat $tmpfile
} > $FILE
rm $tmpfile

if grep -q ^U_BOOT_ENV_TXT $BR2_CONFIG; then
	uenv=$(sed -rn "s/^U_BOOT_ENV_TXT=\"\\\$\(\w+\)(.+)\"/\1/p" $BR2_CONFIG)
	if [ -f "${BR2_EXTERNAL}${uenv}" ]; then
		cp -v ${BR2_EXTERNAL}${uenv} ${TARGET_DIR}/etc/uenv.txt
	fi
	if [ -f "${BR2_EXTERNAL}/local.uenv.txt" ]; then
		grep --invert-match '^#' "${BR2_EXTERNAL}/local.uenv.txt" >> ${TARGET_DIR}/etc/uenv.txt
	fi
fi

if [ -f "${TARGET_DIR}/lib/libconfig.so" ]; then
	rm -vf ${TARGET_DIR}/lib/libconfig.so*
fi

if grep -q ^BR2_TOOLCHAIN_USES_MUSL $BR2_CONFIG; then
	ln -srf ${TARGET_DIR}/lib/libc.so ${TARGET_DIR}/lib/ld-uClibc.so.0
	ln -srf ${TARGET_DIR}/lib/libc.so ${TARGET_DIR}/usr/bin/ldd
fi
