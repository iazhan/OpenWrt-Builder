#!/bin/bash
# ================================================
# diy-2-packages.sh - 添加额外软件包
# 使用稀疏克隆将第三方插件加入 package/ 目录
# ================================================

# ---- Git 稀疏克隆函数（只克隆指定子目录到 package/） ----
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# ---- 添加额外插件 ----
# git_sparse_clone master https://github.com/sundaqiang/openwrt-packages luci-app-wolplus
# git_sparse_clone main https://github.com/nikkinikki-org/OpenWrt-nikki nikki
# git_sparse_clone main https://github.com/nikkinikki-org/OpenWrt-nikki luci-app-nikki

# ---- 科学上网插件 ----
# git_sparse_clone ...

# ---- 主题 ----
# git clone --depth=1 https://github.com/xxx/luci-theme-xxx package/luci-theme-xxx

# ---- SmartDNS ----
# git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# ---- 修改默认 IP ----
# sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# ---- 修改默认主机名 ----
# sed -i 's/OpenWrt/MyRouter/g' package/base-files/files/bin/config_generate

# ---- 修改默认时区 ----
# sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia/Shanghai'/g" \
#   package/base-files/files/bin/config_generate

# ---- 修改默认主题 ----
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

echo "✅ diy-2-packages.sh 执行完毕"
