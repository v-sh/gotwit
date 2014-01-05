FRONT_SRC_DIR=../front
PACKAGE_DIR=gotwit-front
VERSION=`date +"%Y.%m.%d.%H.%M.%S"`
CONTROL_FILE=$PACKAGE_DIR/DEBIAN/control


echo "Version="$VERSION

(cd $FRONT_SRC_DIR; go build) &&
cp $FRONT_SRC_DIR/front $PACKAGE_DIR/usr/local/bin/front_d &&


(cd $PACKAGE_DIR; md5deep -r usr > DEBIAN/md5sums) &&

rm $PACKAGE_DIR"*.deb"
sed 's/Version:.*/Version: '$VERSION'/' -i $CONTROL_FILE &&
fakeroot dpkg-deb --build $PACKAGE_DIR &&
mv $PACKAGE_DIR.deb $PACKAGE_DIR"_"$VERSION"_amd64.deb"

