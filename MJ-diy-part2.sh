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
#rm -rf package/feeds/luci/luci-theme-argon
#rm -rf package/feeds/luci/luci-app-argon-config
#rm -rf package/feeds/luci/luci-theme-infinityfreedom
#rm -rf package/feeds/luci/luci-theme-design
#rm -rf package/feeds/luci/luci-app-unblockneteasemusic
#git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/feeds/luci/luci-theme-infinityfreedom
#git clone -b master https://github.com/jerrykuku/luci-theme-argon.git package/feeds/luci/luci-theme-argon
#git clone -b master https://github.com/jerrykuku/luci-app-argon-config.git package/feeds/luci/luci-app-argon-config
#git clone https://github.com/derisamedia/luci-theme-alpha package/feeds/luci/luci-theme-alpha
#git clone https://github.com/derisamedia/luci-app-alpha-config package/feeds/luci/luci-app-alpha-config
#git clone -b js https://github.com/sirpdboy/luci-theme-kucat package/feeds/luci/luci-theme-kucat
#git clone https://github.com/sirpdboy/luci-app-kucat-config package/feeds/luci/luci-app-kucat-config

#添加软件
#git clone https://github.com/zzsj0928/luci-app-pushbot package/feeds/luci/luci-app-pushbot
#git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/feeds/luci/luci-app-unblockneteasemusic

#修改初始设置
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "5a\ \tset system.@system[0].hostname=ironman" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci commit luci" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set luci.main.mediaurlbase=/luci-static/argon" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set luci.themes.Argon=/luci-static/argon" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci commit network" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.ifname='lan'" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.type='bridge'" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.proto='static'" package/lean/default-settings/files/zzz-default-settings
#[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "23a\uci set network.lan.ipaddr='10.0.0.1'" package/lean/default-settings/files/zzz-default-settings

ERRORS=0
FEED_LUCI=package/feeds/luci

# fetch_pkg <仓库地址> <目标目录> [分支...]
#
# 旧写法是 `rm -rf 目录; git clone ...`:
#   一旦 clone 失败(仓库改名/删除/分支不存在), 被删掉的 feed 自带包再也补不回来,
#   而脚本仍会继续往下跑 —— 结果编到 package/install 阶段才炸, 白费一整轮构建。
# 新做法: 先 clone 到临时目录, 成功才替换目标目录;
#   失败时若 feed 里本来就有这个包, 保留 feed 版本并告警, 不破坏可编译状态。
fetch_pkg() {
  local url="$1" dest="$2"
  shift 2
  local branches=("$@")
  local b tmp ok=0 rc

  tmp=$(mktemp -d) || { echo "::error::mktemp 失败"; ERRORS=$((ERRORS+1)); return; }
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
    echo "::error::克隆失败且 feed 中没有 ${dest} —— 该包无法编译, 请检查仓库地址: ${url}"
    ERRORS=$((ERRORS+1))
  fi
  rm -rf "$tmp"
}

# ---- 主题 ----
# luci-theme-design: 不再 rm, 也不再从 SAENE/luci-theme-design 克隆 —— 该仓库已 404
# (git 报 "could not read Username for 'https://github.com'", 实质就是仓库不存在)。
# LEDE luci feed(openwrt-25.12) 自带 themes/luci-theme-design(PKG_VERSION 7.1),
# 而 feed 的 luci-app-design-config 声明了 LUCI_DEPENDS:=+luci-theme-design;
# 之前"先删 feed 版本、再用坏地址克隆"直接让该依赖无法满足, 镜像组装阶段必失败。
fetch_pkg https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git \
  "$FEED_LUCI/luci-theme-infinityfreedom"
fetch_pkg https://github.com/jerrykuku/luci-theme-argon.git \
  "$FEED_LUCI/luci-theme-argon" master
fetch_pkg https://github.com/jerrykuku/luci-app-argon-config.git \
  "$FEED_LUCI/luci-app-argon-config" master
fetch_pkg https://github.com/derisamedia/luci-theme-alpha \
  "$FEED_LUCI/luci-theme-alpha" master
fetch_pkg https://github.com/derisamedia/luci-app-alpha-config \
  "$FEED_LUCI/luci-app-alpha-config" master
# kucat: 原来写死 `-b js`, 本轮构建报 "Remote branch js not found";
# 改为按 js -> master -> 默认分支 依次尝试。
fetch_pkg https://github.com/sirpdboy/luci-theme-kucat \
  "$FEED_LUCI/luci-theme-kucat" js master
fetch_pkg https://github.com/sirpdboy/luci-app-kucat-config \
  "$FEED_LUCI/luci-app-kucat-config" master

# ---- 应用 ----
fetch_pkg https://github.com/zzsj0928/luci-app-pushbot \
  "$FEED_LUCI/luci-app-pushbot" master


# ---- 收尾自检: 配置里选中的主题/应用, 目录里必须真有 Makefile ----
echo "----- DIY 包目录自检 -----"
for p in luci-theme-argon luci-app-argon-config luci-theme-kucat luci-app-kucat-config \
         luci-theme-alpha luci-app-alpha-config luci-app-pushbot; do
  if [ -f "$FEED_LUCI/$p/Makefile" ]; then
    echo "  有  $FEED_LUCI/$p"
  else
    echo "::error::缺少 $FEED_LUCI/$p/Makefile, 配置里选中它会导致依赖/镜像组装失败"
    ERRORS=$((ERRORS+1))
  fi
done

if [ "$ERRORS" -gt 0 ]; then
  echo "::error::DIY part2 有 ${ERRORS} 处失败, 中止构建(不要跑到 package/install 才报错)"
  exit 1
fi
echo "DIY part2 完成, 无错误"
