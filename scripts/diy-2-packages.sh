#!/bin/bash
# ================================================
# diy-2-packages.sh - 添加额外软件包
# 所有包克隆到 package/ 目录，末尾统一 feeds update + install
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

# ---- 移除 feeds 中的旧版包（防止与 package/ 下的新版冲突）----
rm -rf feeds/packages/net/sing-box
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config

# ---- sing-box 最新版 ----
git_sparse_clone main https://github.com/sbwml/openwrt_helloworld net/sing-box

# ---- 主题 ----
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# ---- 额外插件 ----
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus

# ---- 科学上网插件 ----
# git_sparse_clone ...

# ---- SmartDNS ----
# git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# ---- 修复 package/ 下各包的 Makefile 路径引用 ----
# find package/*/ -maxdepth 2 -path "*/Makefile" | \
#   xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
# luci.mk 路径修正
# find package/*/ -maxdepth 2 -path "*/Makefile" | \
#   xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}

# ---- 统一更新并安装所有 feeds（包括 package/ 下新增的包）----
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ diy-2-packages.sh 执行完毕"