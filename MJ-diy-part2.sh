#!/bin/bash
#============================================================
# https://github.com/Lancenas/Actions-Lean-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================


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
git clone https://github.com/derisamedia/luci-theme-alpha package/feeds/luci/luci-theme-alpha
git clone https://github.com/derisamedia/luci-app-alpha-config package/feeds/luci/luci-app-alpha-config
git clone -b js https://github.com/sirpdboy/luci-theme-kucat package/feeds/luci/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-kucat-config package/feeds/luci/luci-app-kucat-config

#添加软件
git clone https://github.com/zzsj0928/luci-app-pushbot package/feeds/luci/luci-app-pushbot
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/feeds/luci/luci-app-unblockneteasemusic

#修改初始设置
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "5a\ \tset system.@system[0].hostname=ironman" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci commit luci" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set luci.main.mediaurlbase=/luci-static/argon" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set luci.themes.Argon=/luci-static/argon" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci commit network" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.ifname='lan'" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.type='bridge'" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.proto='static'" package/lean/default-settings/files/zzz-default-settings
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.ipaddr='10.0.0.1'" package/lean/default-settings/files/zzz-default-settings
