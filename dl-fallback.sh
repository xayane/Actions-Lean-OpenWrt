#!/bin/sh
# 通用下载包装器 —— 由 LEDE 的 CONFIG_DOWNLOAD_TOOL_CUSTOM 调用
#
# 契约(download.pl::download_cmd): 本脚本接收 1 个参数 = 完整下载 URL,
# 必须把文件内容写到 stdout; 退出码非 0 表示失败。download.pl 会自己做
# sha256 校验, 校验失败会自动换下一个 mirror 重试 —— 所以这里可以放心
# 尝试多个网络路径, 错的内容会被上层挡掉。
#
# 设计目标:
#   1. 对所有源码包生效, 不再逐包硬编码(erofs 之类只是其中一例)
#   2. 上游修好源后自动失效: 每个候选只在该 URL 真能拿到内容时才输出
#   3. 不碰 LEDE 任何源码文件, 只通过官方 kconfig 选项注入
#
# 候选顺序(只做网络层兜底, 不改 URL 语义):
#   a. 直连原 URL                    —— 上游正常时永远走这条, 零开销
#   b. gh-proxy 代理原 URL           —— 救 GitHub / 部分被墙源
#   c. 对 github.com 的 archive URL, 补 codeload 同构地址
#   d. 对 git.kernel.org 的 cgit snapshot, 补一个正确的 tag 形式
#      (只针对 URL 形态做机械变换, 不含任何包名/版本号硬编码)

url="$1"
[ -n "$url" ] || exit 1

try() {
  # 成功条件: curl 退出码 0 且文件非空。空 body 一律当失败,
  # 这样 cgit 对坏 ref 返回 "200 + 空内容" 不会被误判成功。
  _u="$1"
  _t="$(mktemp)" || return 1
  if curl -fsSL --connect-timeout 15 --retry 2 --retry-delay 2 \
       --max-time 300 -o "$_t" "$_u" 2>/dev/null && [ -s "$_t" ]; then
    cat "$_t"
    rm -f "$_t"
    return 0
  fi
  rm -f "$_t"
  return 1
}

# a) 原 URL 直连
try "$url" && exit 0

# b) 通用代理(对 https 源)
case "$url" in
  http://*|https://*)
    try "https://gh-proxy.com/$url" && exit 0
    ;;
esac

# c) GitHub archive -> codeload 同构 URL
#    .../archive/refs/tags/v1.2.3.tar.gz -> codeload.../tar.gz/refs/tags/v1.2.3
case "$url" in
  https://github.com/*/archive/*)
    suffix=${url#https://github.com/}
    repo=${suffix%%/archive/*}
    rest=${suffix#*/archive/}
    try "https://codeload.github.com/$repo/tar.gz/$rest" && exit 0
    ;;
esac

# d) kernel.org cgit snapshot: 形如
#    .../snapshot/<name>-<ver>.tar.gz  上游有时只存在 v<ver> 的 ref
#    机械生成带 v 的候选, 让 download.pl 的 hash 校验去裁决对不对
case "$url" in
  *git.kernel.org*snapshot/*.tar.gz)
    base=${url##*/}
    name=${base%.tar.gz}
    ver=${name##*-}
    case "$ver" in
      v*) ;;
      [0-9]*)
        vurl=${url%/*}/v${ver}.tar.gz
        try "$vurl" && exit 0
        try "https://gh-proxy.com/$vurl" && exit 0
        ;;
    esac
    ;;
esac

exit 1
