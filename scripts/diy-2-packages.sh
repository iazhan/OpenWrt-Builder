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

# ---- 移除 feeds 中的旧版包，替换为最新版 ----
rm -rf feeds/packages/net/sing-box
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/themes/luci-theme-argon
# rm -rf feeds/packages/lang/golang

# ---- sing-box 最新版（放回 feeds 目录）----
git_sparse_clone main https://github.com/sbwml/openwrt_helloworld net/sing-box
mv -f package/sing-box feeds/packages/net/sing-box

# ---- ariang & golang & frp（放回 feeds 目录）----
# git_sparse_clone master https://github.com/laipeng668/packages lang/golang
# mv -f package/golang feeds/packages/lang/golang

# ---- 主题 ----
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config feeds/luci/applications/luci-app-argon-config
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora feeds/luci/themes/luci-theme-aurora
git clone --depth=1 https://github.com/eamonxg/luci-app-aurora-config feeds/luci/applications/luci-app-aurora-config

# ---- 额外插件 ----
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus
# git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter


# ---- 科学上网插件 ----
# git_sparse_clone ...

# ---- SmartDNS ----
# git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# ---- 重新注册替换后的包到 feeds ----
# 直接克隆到 feeds 目录的包需要重新 install 才能被编译系统识别
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ diy-2-packages.sh 执行完毕"