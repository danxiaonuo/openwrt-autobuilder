#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

OPENWRT_PATH=`pwd`
echo "Openwrt path: $OPENWRT_PATH"

##################################
# Custom feed
##################################
# add lienol feed: such like passwall and themes
echo ""
echo "Adding lienol packages feed"
echo "src-git lienol https://github.com/chenshuo890/lienol-openwrt-package.git" >> feeds.conf.default

echo ""
echo "add helloworld feeds"
sed -i "s/^#\(src-git helloworld .*\)$/\1/" feeds.conf.default

echo ""
echo "Updating feeds"
./scripts/feeds update -a

echo ""
echo "Installing feeds"
./scripts/feeds install -a

##################################
# Custom package
##################################

echo ""
echo "Using luci-theme-argon offical source code"
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon

echo ""
echo "Downloading Custom packages"
mkdir -p package/icyleaf
cd package/icyleaf

git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome.git
git clone --depth=1 https://github.com/tty228/luci-app-serverchan.git
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash

cd $OPENWRT_PATH

##################################
# Settings
##################################
echo ""
echo "Configuring ..."
# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

if [ -n $OPENWRT_ROOT_PASSWORD ]; then
  echo "WARN: root password is changed from your secret, make sure you add 'OPENWRT_ROOT_PASSWORD' secret"
  # Modify password of root if present (encoded password)
  # For example: passwot = $1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.
  sed -i "s|root::0:0:99999:7:::|root:$OPENWRT_ROOT_PASSWORD:0:0:99999:7:::|g" package/base-files/files/etc/shadow
fi

# Modify default theme
# sed -i 's/bootstrap/argon/g' package/feeds/luci/luci-base/root/etc/config/luci
