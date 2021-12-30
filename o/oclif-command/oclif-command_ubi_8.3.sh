#----------------------------------------------------------------------------
#
# Package         : oclif/command
# Version         : v1.8.0
# Source repo     : https://github.com/oclif/command.git
# Tested on       : ubi:8.3
# Script License  : MIT License
# Maintainer      : srividya chittiboina <Srividya.Chittiboina@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------
#!/bin/bash
#
#
# ----------------------------------------------------------------------------

REPO=https://github.com/oclif/command.git

# Default tag oclif/command
if [ -z "$1" ]; then
  export VERSION="v1.8.0"
else
  export VERSION="$1"
fi

yum install git wget -y
wget "https://nodejs.org/dist/v12.22.4/node-v12.22.4-linux-ppc64le.tar.gz" 
tar -xzf node-v12.22.4-linux-ppc64le.tar.gz 
export PATH=$CWD/node-v12.22.4-linux-ppc64le/bin:$PATH
npm install yarn -g

#Cloning Repo
git clone $REPO
cd command
git checkout ${VERSION}

#Build repo
yarn install
#Test repo
yarn test
 


         