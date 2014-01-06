FRONT_SRC_DIR=../front
PACKAGE_DIR=gotwit-front
VERSION=`date +"%Y.%m.%d.%H.%M.%S"`
CONTROL_FILE=$PACKAGE_DIR/DEBIAN/control
PACKAGE_FULL_NAME=$PACKAGE_DIR"_"$VERSION"_amd64.deb"
BIN_DIR=$PACKAGE_DIR/usr/bin
REPO_DIR=$HOME/rep_apt

rm -r $PACKAGE_DIR/usr
mkdir -p $BIN_DIR

echo "Version="$VERSION

(cd $FRONT_SRC_DIR; go build) &&
cp $FRONT_SRC_DIR/front $BIN_DIR/front_d &&

cp control-gotwit-front $CONTROL_FILE
(cd $PACKAGE_DIR; md5deep -l -r usr > DEBIAN/md5sums) &&

rm $PACKAGE_DIR*.deb
chmod -R g-w $PACKAGE_DIR
sed 's/Version:.*/Version: '$VERSION'/' -i $CONTROL_FILE &&
fakeroot dpkg-deb --build $PACKAGE_DIR &&
mv $PACKAGE_DIR.deb $PACKAGE_FULL_NAME

lintian $PACKAGE_FULL_NAME

(cd $REPO_DIR; rm $PACKAGE_DIR*.deb)

cp *.deb $REPO_DIR &&
(cd $REPO_DIR; reprepro -C gotwit-soft includedeb gotwit *.deb)
