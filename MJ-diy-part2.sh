#!/bin/bash
#============================================================
# https://github.com/Lancenas/Actions-Lean-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

#增加主题
rm -rf package/feeds/luci/luci-theme-argon
rm -rf package/feeds/luci/luci-app-argon-config
rm -rf package/feeds/luci/luci-theme-infinityfreedom
rm -rf package/feeds/luci/luci-theme-design
rm -rf package/feeds/luci/luci-app-unblockneteasemusic
git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/feeds/luci/luci-theme-infinityfreedom
git clone https://github.com/SAENE/luci-theme-design.git package/feeds/luci/luci-theme-design
git clone -b master https://github.com/jerrykuku/luci-theme-argon.git package/feeds/luci/luci-theme-argon
git clone -b master https://github.com/jerrykuku/luci-app-argon-config.git package/feeds/luci/luci-app-argon-config
git clone https://github.com/zzsj0928/luci-app-pushbot package/feeds/luci/luci-app-pushbot
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/feeds/luci/luci-app-unblockneteasemusic
git clone https://github.com/sirpdboy/luci-app-kucat-config package/feeds/luci/luci-app-kucat-config
