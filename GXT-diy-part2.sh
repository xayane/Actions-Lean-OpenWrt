#!/bin/bash
#============================================================
# https://github.com/Lancenas/Actions-Lean-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

ERRORS=0
FEED_LUCI=package/feeds/luci
fail() { echo "::error::$*"; ERRORS=$((ERRORS+1)); }

fetch_pkg() {
  local url="$1" dest="$2"
  shift 2
  local branches=("$@")
  local b tmp ok=0 rc

  tmp=$(mktemp -d) || { fail "mktemp 失败"; return; }
  [ ${#branches[@]} -eq 0 ] && branches=("")

  for b in "${branches[@]}"; do
    rm -rf "$tmp/pkg"
    if [ -n "$b" ]; then
      git clone --depth 1 -b "$b" "$url" "$tmp/pkg" 2>&1 | tee "$tmp/git.log"
      rc=${PIPESTATUS[0]}
    else
      git clone --depth 1 "$url" "$tmp/pkg" 2>&1 | tee "$tmp/git.log"
      rc=${PIPESTATUS[0]}
    fi
    if [ "$rc" -eq 0 ] && [ -e "$tmp/pkg/Makefile" ]; then
      ok=1
      break
    fi
    echo "  克隆失败(分支 '${b:-默认}'): ${url}"
  done

  if [ "$ok" -eq 1 ]; then
    rm -rf "$dest"
    mv "$tmp/pkg" "$dest"
    echo "OK    ${dest}  <- ${url}"
  elif [ -f "$dest/Makefile" ]; then
    echo "::warning::克隆全部失败, 保留 feed 自带版本 ${dest} (不替换)"
  else
    fail "克隆失败且 feed 中没有 ${dest} —— 该包无法编译: ${url}"
  fi
  rm -rf "$tmp"
}

# ---- 主题与应用 ----
fetch_pkg https://github.com/jerrykuku/luci-theme-argon.git \
  "$FEED_LUCI/luci-theme-argon" master
fetch_pkg https://github.com/jerrykuku/luci-app-argon-config.git \
  "$FEED_LUCI/luci-app-argon-config" master
fetch_pkg https://github.com/sirpdboy/luci-theme-kucat \
  "$FEED_LUCI/luci-theme-kucat" master
fetch_pkg https://github.com/sirpdboy/luci-app-kucat-config \
  "$FEED_LUCI/luci-app-kucat-config" master
fetch_pkg https://github.com/derisamedia/luci-theme-alpha \
  "$FEED_LUCI/luci-theme-alpha" master
fetch_pkg https://github.com/derisamedia/luci-app-alpha-config \
  "$FEED_LUCI/luci-app-alpha-config" master
fetch_pkg https://github.com/zzsj0928/luci-app-pushbot \
  "$FEED_LUCI/luci-app-pushbot" master

# ---- 默认 IP / 主机名 / 编译者信息 ----
if [ -f package/base-files/luci2/bin/config_generate ]; then
  sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/luci2/bin/config_generate
else
  fail "package/base-files/luci2/bin/config_generate 不存在, 默认 IP 未修改"
fi

if [ -f package/lean/default-settings/files/zzz-default-settings ]; then
  sed -i "/uci commit system/i\\uci set system.@system[0].hostname='YaYa_Router'" \
    package/lean/default-settings/files/zzz-default-settings
  sed -i "s/OpenWrt /KK build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" \
    package/lean/default-settings/files/zzz-default-settings
else
  fail "package/lean/default-settings/files/zzz-default-settings 不存在, 主机名/编译者信息未修改"
fi


# ---- 收尾自检 ----
echo "----- DIY 包目录自检 -----"
for p in luci-theme-argon luci-app-argon-config luci-theme-design luci-app-design-config \
         luci-theme-kucat luci-app-kucat-config \
         luci-theme-alpha luci-app-alpha-config luci-app-pushbot; do
  if [ -f "$FEED_LUCI/$p/Makefile" ]; then
    echo "  有  $FEED_LUCI/$p"
  else
    fail "缺少 $FEED_LUCI/$p/Makefile, 配置里选中它会导致依赖/镜像组装失败"
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo "::error::DIY part2 有 ${ERRORS} 处失败, 中止构建(不要跑到 package/install 才报错)"
  exit 1
fi
echo "DIY part2 完成, 无错误"


#增加主题
#git clone https://github.com/sirpdboy/luci-app-kucat-config package/feeds/luci/luci-app-kucat-config

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
#sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/luci2/bin/config_generate
## 旧版
#sed -i 's/192.168.1.1/10.0.0.2/g' package/base-files/files/bin/config_generate

# 修改默认主机名
#sed -i '/uci commit system/i\uci set system.@system[0].hostname='YaYa_Router'' package/lean/default-settings/files/zzz-default-settings

# 加入编译者信息
#sed -i "s/OpenWrt /KK build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# 修改默认主题
## 新版（需要使用JS版本主题，否则会进不去后台，提示"Unhandled exception during request dispatching"）
#sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" feeds/luci/collections/luci-light/Makefile
## 旧版
#sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" feeds/luci/collections/luci/Makefile

# 删除冲突插件
# rm -rf feeds/small/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb}

# ============================================
# 替换 zerotier 为 immortalwrt 版本
# ============================================
# 删除 coolsnowwolf 的 zerotier 包
#rm -rf feeds/packages/net/zerotier

# 从 immortalwrt 拉取 zerotier（git sparse-checkout，只下载 net/zerotier 文件夹）
#git clone --depth 1 --filter=blob:none --sparse https://github.com/immortalwrt/packages.git /tmp/immortalwrt-packages
#cd /tmp/immortalwrt-packages
#git sparse-checkout set net/zerotier
#cd -
#cp -r /tmp/immortalwrt-packages/net/zerotier feeds/packages/net/
#rm -rf /tmp/immortalwrt-packages
