#!/bin/bash
# ================================================
# diy-2-packages.sh - 添加额外软件包
# 这是一个示例 diy 阶段：fork 用户可以自由删改它，
# 也可以新增别的 diy-*.sh 文件来替代或补充它。
# 使用固定 commit 版本，保证第三方依赖可复现。
# ================================================

set -euo pipefail

source "$GITHUB_WORKSPACE/scripts/third-party-sources.sh"

# ---- 移除 feeds 中的旧版包，替换为固定版本 ----
rm -rf feeds/packages/net/sing-box
rm -rf feeds/packages/lang/golang
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-aurora

# ---- sing-box 及相关包（固定 openwrt_helloworld 版本）----
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
clone_pinned_repo "$OPENWRT_HELLOWORLD_REPO" "$OPENWRT_HELLOWORLD_BRANCH" "$OPENWRT_HELLOWORLD_COMMIT" package/helloworld

# ---- 固定 golang 工具链版本 ----
rm -rf feeds/packages/lang/golang
clone_pinned_repo "$GOLANG_REPO" "$GOLANG_BRANCH" "$GOLANG_COMMIT" feeds/packages/lang/golang

# ---- 主题（固定 commit）----
clone_pinned_repo "$ARGON_THEME_REPO" "$ARGON_THEME_BRANCH" "$ARGON_THEME_COMMIT" feeds/luci/themes/luci-theme-argon
clone_pinned_repo "$ARGON_CONFIG_REPO" "$ARGON_CONFIG_BRANCH" "$ARGON_CONFIG_COMMIT" feeds/luci/applications/luci-app-argon-config
clone_pinned_repo "$AURORA_THEME_REPO" "$AURORA_THEME_BRANCH" "$AURORA_THEME_COMMIT" feeds/luci/themes/luci-theme-aurora
clone_pinned_repo "$AURORA_CONFIG_REPO" "$AURORA_CONFIG_BRANCH" "$AURORA_CONFIG_COMMIT" feeds/luci/applications/luci-app-aurora-config

# ---- 额外插件（固定 commit 稀疏克隆）----
git_sparse_clone_pinned "$EXTRA_PACKAGES_BRANCH" "$EXTRA_PACKAGES_REPO" "$EXTRA_PACKAGES_COMMIT" luci-app-wolplus

# ---- 重新 install，让编译系统识别替换后的包 ----
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ diy-2-packages.sh 执行完毕"
