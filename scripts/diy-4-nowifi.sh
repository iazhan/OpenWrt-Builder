#!/bin/bash
# ================================================
# diy-4-nowifi.sh - 彻底剔除无线（仅 NOWIFI=true 生效）
#
# 为什么需要这个脚本：
#   .config 里的 "# CONFIG_PACKAGE_xxx is not set" 只是「声明」，
#   后面 workflow 会再跑一次 make defconfig，被 select 的符号会回到 y；
#   而 DEVICE_PACKAGES / DEFAULT_PACKAGES 是 Makefile 变量，
#   压根不读 .config，写什么都拦不住。
#   所以要在 defconfig 之前，把上游的包列表本身改掉。
#
# defconfig 之后的二次修剪见：
#   prepare-openwrt.sh post-defconfig
# ================================================

set -euo pipefail

source "$GITHUB_WORKSPACE/scripts/lib-builder-config.sh"
source "$GITHUB_WORKSPACE/scripts/lib-nowifi.sh"

CFG_FILE="$(builder_cfg_path "${MATRIX_CONFIG}")"
load_builder_cfg "$CFG_FILE"

if [ "${NOWIFI}" != "true" ]; then
  echo "ℹ️ NOWIFI 未开启，跳过无线剔除"
  exit 0
fi

echo "▶️ NOWIFI=true，开始剔除无线相关包"

# ---- 1. 改写 target 的包列表：这一步才真正决定包会不会进 rootfs ----
nowifi_prune_package_lists \
  target/linux/qualcommax/image/*.mk \
  target/linux/qualcommax/Makefile \
  include/target.mk

# ---- 2. 清掉 .config 里的无线符号，避免 defconfig 把它们算回来 ----
nowifi_prune_config .config

# ---- 3. 让固件里不再有 /etc/config/wireless ----
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/97-nowifi-cleanup <<'SCRIPT'
#!/bin/sh
# 无 WiFi 固件兜底清理：驱动可能缺失，但配置/服务仍可能残留
rm -f /etc/config/wireless
uci -q delete wireless >/dev/null 2>&1
for svc in hostapd wpad; do
    [ -x "/etc/init.d/$svc" ] && "/etc/init.d/$svc" disable >/dev/null 2>&1
done
exit 0
SCRIPT
chmod +x files/etc/uci-defaults/97-nowifi-cleanup

# ---- 4. 从 LuCI 菜单里摘掉「无线」条目（有就摘，结构变了就跳过）----
MENU_JSON="$(find feeds/luci/modules/luci-mod-network -type f -name 'luci-mod-network.json' -path '*menu.d*' 2>/dev/null | head -n1)"
if [ -n "$MENU_JSON" ] && command -v python3 >/dev/null 2>&1; then
  mkdir -p files/usr/share/luci/menu.d
  python3 - "$MENU_JSON" files/usr/share/luci/menu.d/luci-mod-network.json <<'PY'
import json
import sys

src, dst = sys.argv[1], sys.argv[2]
with open(src, encoding="utf-8") as fh:
    data = json.load(fh)

for key in list(data):
    if "wireless" in key.split("/"):
        data.pop(key, None)

with open(dst, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent="\t")
    fh.write("\n")
PY
  echo "  已处理 LuCI 菜单: $MENU_JSON"
fi

echo "✅ diy-4-nowifi.sh 执行完毕"
