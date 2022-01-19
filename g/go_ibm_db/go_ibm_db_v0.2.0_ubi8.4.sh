#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package	: go_ibm_db
# Version	: v0.2.0
# Source repo	: https://github.com/ibmdb/go_ibm_db
# Tested on	: UBI 8.4
# Language      : GO
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer	: Vikas Gupta <vikas.gupta8@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------
set -e

PACKAGE_NAME=go_ibm_db
PACKAGE_VERSION=${1:-v0.2.0}
PACKAGE_URL=https://github.com/ibmdb/go_ibm_db

dnf -y --disableplugin=subscription-manager install http://mirror.centos.org/centos/8/BaseOS/ppc64le/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm http://mirror.centos.org/centos/8/BaseOS/ppc64le/os/Packages/centos-linux-repos-8-3.el8.noarch.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

yum install -y go git tar pam wget numactl

# Install Go and setup working directory

export GO_VERSION=go1.17.4.linux-ppc64le.tar.gz

wget https://golang.org/dl/$GO_VERSION && \
    tar -C /bin -xf $GO_VERSION && \
    mkdir -p /home/tester/go/src /home/tester/go/bin /home/tester/go/pkg /home/tester/output

rm -rf $GO_VERSION
export HOME_DIR=/home/tester
export PATH=$PATH:/bin/go/bin
export GOPATH=/home/tester/go
export PATH=$GOPATH/bin:$PATH
export GO111MODULE=on

cd $HOME_DIR
rm -rf $PACKAGE_NAME

echo "Building $PACKAGE_NAME with $PACKAGE_VERSION"
if ! git clone $PACKAGE_URL; then
	echo "------------------$PACKAGE_NAME: clone failed-------------------------"
	exit 1
fi

cd $PACKAGE_NAME

go mod init github.com/ibmdb/go_ibm_db
go mod tidy 

if ! git checkout $PACKAGE_VERSION; then
	echo "------------------$PACKAGE_NAME: checkout failed to version $PACKAGE_VERSION-------------------------"
	exit 1
fi

echo "------------------$PACKAGE_NAME: running setup for clidriver -------------------------"
cd installer
go run setup.go
cd ..

export DB2HOME=$HOME_DIR/go_ibm_db/installer/clidriver
export CGO_CFLAGS=-I$DB2HOME/include
export CGO_LDFLAGS=-L$DB2HOME/lib
export LD_LIBRARY_PATH=$HOME_DIR/go_ibm_db/installer/clidriver/lib

echo `pwd`

if ! go build -v ./...; then
	echo "------------------$PACKAGE_NAME: build failed-------------------------"
	exit 1
fi

if ! go test -v ./...; then
	echo "------------------$PACKAGE_NAME: test failed-------------------------"
	exit 1
else
	echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
	echo "$PACKAGE_VERSION $PACKAGE_NAME" > /home/tester/output/test_success
	echo "$PACKAGE_NAME  |  $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success" > /home/tester/output/version_tracker
	exit 1
fi
