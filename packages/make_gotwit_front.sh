FRONT_SRC_DIR=../front
PACKAGE_DIR=gotwit-front
DEBIAN_DIR=$PACKAGE_DIR/DEBIAN
VERSION=`date +"%Y.%m.%d.%H.%M.%S"`
CONTROL_FILE=$DEBIAN_DIR/control
CONFIGFILES_FILE=$DEBIAN_DIR/conffiles
PACKAGE_FULL_NAME=$PACKAGE_DIR"_"$VERSION"_amd64.deb"
BIN_DIR=$PACKAGE_DIR/usr/bin
CONF_DIR=$PACKAGE_DIR/etc
INITS_DIR=../init_scripts
DEBIAN_SRC_DIR=front_debian_src

CONFS_DIR=../confs

REPO_DIR=$HOME/rep_apt

rm -rf $PACKAGE_DIR/usr
rm -rf $PACKAGE_DIR/etc
rm -r $DEBIAN_DIR
mkdir -p $BIN_DIR
mkdir -p $CONF_DIR
mkdir -p $PACKAGE_DIR/etc/init.d
mkdir -p $PACKAGE_DIR/usr/share/gotwit/
mkdir -p $DEBIAN_DIR

echo "Version="$VERSION


#build and collect
(cd $FRONT_SRC_DIR; go build) &&
cp $FRONT_SRC_DIR/front $BIN_DIR/front_d &&
cp -R $CONFS_DIR/* $CONF_DIR &&
cp $INITS_DIR/front_d $PACKAGE_DIR/etc/init.d/ &&
cp -R ../tmpl ../third_party/static ../static $PACKAGE_DIR/usr/share/gotwit/ &&

#make meta-info
cp $DEBIAN_SRC_DIR/* $DEBIAN_DIR &&
sed 's/Version:.*/Version: '$VERSION'/' -i $CONTROL_FILE &&
(cd $PACKAGE_DIR; md5deep -l -r usr etc > DEBIAN/md5sums) &&

chmod -R g-w $PACKAGE_DIR &&

#make package
rm $PACKAGE_DIR*.deb
fakeroot dpkg-deb --build $PACKAGE_DIR &&
mv $PACKAGE_DIR.deb $PACKAGE_FULL_NAME &&


#check package
lintian $PACKAGE_FULL_NAME

#update apt-server
(cd $REPO_DIR; rm -f $PACKAGE_DIR*.deb) &&

cp *.deb $REPO_DIR &&
(cd $REPO_DIR; reprepro -C gotwit-soft includedeb gotwit *.deb)
