#!/bin/bash
# ============================================================
# lib-nowifi.sh - NOWIFI 剔除逻辑（共享）
#
# 三个地方会用到它：
#   diy-4-nowifi.sh（defconfig 之前，改 Makefile 包列表）
#   prepare-openwrt.sh post-defconfig（defconfig 之后，修 .config）
# ============================================================

# 需要剔除的包名（避免匹配 iwlwifi 之类的无关项）
#
# 注意 iwinfo / rpcd-mod-iwinfo / iw 必须保留：
#   luci-mod-network: LUCI_DEPENDS:=+luci-base +rpcd-mod-iwinfo +luci-lib-uqr
#   luci-mod-status:  LUCI_DEPENDS:=+luci-base +libiwinfo +rpcd-mod-iwinfo
#                     PKG_BUILD_DEPENDS:=iwinfo
# 关掉它们会直接让 rootfs 组装报缺依赖，而它们编进来只是多几十 KB，
# 没有无线设备时 ubus 返回空列表，LuCI 自然显示"无无线设备"。
NOWIFI_PKG_RE='(ipq-wifi-[a-z0-9_-]+|ath[0-9]*k-firmware-[a-z0-9_-]+|kmod-(ath|qcom|cfg80211|mac80211|lib80211)[0-9a-z-]*|wpad[a-z0-9-]*|hostapd[a-z0-9-]*|wifi-scripts|wireless-regdb)'

# *.config 里需要关闭的符号
NOWIFI_SYM_RE='CONFIG_(PACKAGE_(wpad|hostapd|wifi-scripts|wireless-regdb|kmod-(ath|qcom|cfg80211|mac80211|lib80211)|ath[0-9]*k-firmware|ipq-wifi)[A-Za-z0-9_.-]*|ATH[0-9]*K_[A-Z0-9_]*|DRIVER_11[A-Z0-9_]*_SUPPORT|WLAN_SUPPORT)'

# 无线栈所在目录：目录下任何一个子包被选中，整个包都会被拉去编译
# 不含 iwinfo / iw —— 它们要留着给 LuCI 用
NOWIFI_PKG_DIRS="
package/kernel/mac80211
package/network/services/hostapd
package/network/config/wifi-scripts
package/firmware/wireless-regdb
"


# ---- 从 Makefile 的 *_PACKAGES 行里剔掉无线包 ----
# 只动未被注释的包列表行，其他行原样保留
nowifi_prune_package_lists() {
  local f
  for f in "$@"; do
    [ -f "$f" ] || continue
    sed -i -E "/^[^#]*[A-Z_]*PACKAGES[[:space:]]*[:+]?=/ s/${NOWIFI_PKG_RE}//g" "$f"
  done
}

# ---- 把某个无线包的目录下所有子包全部关掉 ----
# OpenWrt 里只要目录下有一个子包被选中，整个包都会被拉去编译。
# 典型：kmod-ath11k 被关掉后，kmod-qcom-qmi-helpers 仍然 =y，
# mac80211 照样编译，但 qmi_helpers.ko 需要 ATH11K 才生成，打包时报模块缺失。
nowifi_disable_subpackages() {
  local dir="$1" cfg="${2:-.config}"
  [ -d "$dir" ] && [ -f "$cfg" ] || return 0

  local files=()
  [ -f "$dir/Makefile" ] && files+=("$dir/Makefile")
  shopt -s nullglob
  files+=("$dir"/*.mk)
  shopt -u nullglob
  [ ${#files[@]} -gt 0 ] || return 0

  local names
  names="$(grep -hoE '(KernelPackage|Package)/[a-z0-9][a-z0-9._-]*' "${files[@]}" 2>/dev/null \
    | sed 's#^KernelPackage/#kmod-#; s#^Package/##' \
    | sort -u || true)"
  [ -n "$names" ] || return 0

  local n n_esc
  for n in $names; do
    n_esc="${n//./\\.}"
    sed -i -E "/^#? ?CONFIG_PACKAGE_${n_esc}[= ]/d" "$cfg"
    echo "# CONFIG_PACKAGE_${n} is not set" >> "$cfg"
  done
}

# ---- 把 .config 里的无线符号统一改成 "# CONFIG_X is not set" ----
# 顺带清空 CONFIG_TARGET_DEVICE_PACKAGES_* 里被塞进来的无线包
nowifi_prune_config() {
  local cfg="${1:-.config}"
  [ -f "$cfg" ] || return 0

  local tmp="${cfg}.nowifi.$$"
  awk -v symer="^${NOWIFI_SYM_RE}=" -v pkgre="${NOWIFI_PKG_RE}" '
    $0 ~ symer {
      sub(/=.*/, "")
      print "# " $0 " is not set"
      next
    }
    /^CONFIG_TARGET_DEVICE_PACKAGES_[A-Za-z0-9_.]*=/ {
      key = $0
      sub(/=.*/, "", key)
      val = substr($0, length(key) + 2)
      gsub(pkgre, "", val)
      gsub(/  +/, " ", val)
      sub(/[[:space:]]+$/, "", val)
      print key "=" val
      next
    }
    { print }
  ' "$cfg" > "$tmp" && mv "$tmp" "$cfg"
}

# ---- 校验：defconfig 之后还有没有无线包被依赖强制选中 ----
# 返回 0 表示干净，1 表示仍有残留（残留项打印到 stdout）
nowifi_verify() {
  local cfg="${1:-.config}"
  [ -f "$cfg" ] || return 0

  local leaked
  leaked="$(grep -E "^${NOWIFI_SYM_RE}=y" "$cfg" 2>/dev/null || true)"
  if [ -n "$leaked" ]; then
    printf '%s\n' "$leaked"
    return 1
  fi

  local dev_pkgs
  dev_pkgs="$(grep -E '^CONFIG_TARGET_DEVICE_PACKAGES_[A-Za-z0-9_.]*=' "$cfg" 2>/dev/null \
    | grep -E "$NOWIFI_PKG_RE" || true)"
  if [ -n "$dev_pkgs" ]; then
    printf '%s\n' "$dev_pkgs"
    return 1
  fi

  return 0
}
