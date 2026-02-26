#!/bin/bash
# ================================================
# diy-1-settings.sh - 系统设置
# 修改路由器的默认参数：IP、主机名、时区、主题等
# ================================================

# ---- 修改默认 IP ----
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# ---- 修改默认主机名 ----
# sed -i 's/OpenWrt/MyRouter/g' package/base-files/files/bin/config_generate

# ---- 修改默认时区为上海 ----
# sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" \
#   package/base-files/files/bin/config_generate

# ---- 修改默认主题 ----
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

echo "✅ diy-1-settings.sh 执行完毕"