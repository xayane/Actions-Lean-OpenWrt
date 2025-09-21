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
git clone https://github.com/sirpdboy/luci-app-kucat-config package/feeds/luci/luci-app-kucat-config

##20250922作废修改初始设置
#sed -i "5a\ \tset system.@system[0].hostname=YaYa.WRT" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci commit luci" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci set luci.main.mediaurlbase=/luci-static/argon" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci set luci.themes.Argon=/luci-static/argon" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci commit network" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci set network.lan.ifname='lan'" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci set network.lan.type='bridge'" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci set network.lan.proto='static'" package/lean/default-settings/files/zzz-default-settings
#sed -i "23a\uci set network.lan.ipaddr='192.168.123.1'" package/lean/default-settings/files/zzz-default-settings

# 修改默认IP为 192.168.123.1
## 新版
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/luci2/bin/config_generate
## 旧版
#sed -i 's/192.168.1.1/10.0.0.2/g' package/base-files/files/bin/config_generate

# 修改默认主机名
sed -i '/uci commit system/i\uci set system.@system[0].hostname='YaYa_Router'' package/lean/default-settings/files/zzz-default-settings

# 加入编译者信息
sed -i "s/OpenWrt /KK build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# 修改默认主题
## 新版（需要使用JS版本主题，否则会进不去后台，提示"Unhandled exception during request dispatching"）
sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" feeds/luci/collections/luci-light/Makefile
## 旧版
sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" feeds/luci/collections/luci/Makefile
