#!/bin/bash
# ================================================
# 自定义脚本 - 修改 feeds 源 (在 feeds update 之前执行)
# 可在此修改 feeds.conf.default 或添加自定义 feed
# ================================================

# 示例：添加自定义 feed
# echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default
# echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall-packages" >> feeds.conf.default

# ---- 添加 nikki feed ----
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

echo "✅ customize.sh 执行完毕"