#!/bin/bash

PACKAGE_DIR=gotwit-repo
DEBIAN_DIR=$PACKAGE_DIR/DEBIAN
VERSION=`date +"%Y.%m.%d.%H.%M.%S"`
SRC_DIR=src
PACKAGE_FULL_NAME=$PACKAGE_DIR"_"$VERSION"_amd64.deb"
CONTROL_FILE=$DEBIAN_DIR/control

echo "Version="$VERSION &&

rm -rf $PACKAGE_DIR &&
mkdir $PACKAGE_DIR &&

cp -R $SRC_DIR/* $PACKAGE_DIR/ &&
sed 's/Version:.*/Version: '$VERSION'/' -i $CONTROL_FILE &&
(cd $PACKAGE_DIR; md5deep -l -r usr etc > DEBIAN/md5sums) &&

chmod -R g-w $PACKAGE_DIR &&

rm $PACKAGE_DIR*.deb
fakeroot dpkg-deb --build $PACKAGE_DIR &&
mv $PACKAGE_DIR.deb $PACKAGE_FULL_NAME &&

lintian $PACKAGE_FULL_NAME
