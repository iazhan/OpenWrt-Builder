#!/bin/bash
# OpenWrt 预处理阶段的共享辅助脚本。
#
# 该脚本会动态发现 scripts/diy-*.sh，目的是让
# fork 用户可以自由删除、修改、重命名或新增 diy 脚本，而不需要
# 同步修改 GitHub Actions workflow。
#
# 执行顺序由文件名排序决定，因此 diy-<数字>-<名称>.sh
# 仍然是约定的自定义接口。
set -euo pipefail

usage() {
  cat <<'EOF'
用法：prepare-openwrt.sh <pre-feeds|load-config|run-diy-scripts|clean-downloads>

可用子命令：
  pre-feeds        在 feeds update 前执行 customize.sh，并覆盖 feeds.conf.default
  load-config      加载 configs/<设备>.config（找不到则回退到 default.config）并执行 make defconfig
  run-diy-scripts  按文件名排序执行所有 diy-*.sh 脚本
  clean-downloads  清理 dl 目录中的异常小文件，但保留 go-mod-cache
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${GITHUB_WORKSPACE:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
OPENWRT_DIR="${OPENWRT_DIR:-${WORKSPACE_DIR}/openwrt}"
CONFIG_NAME="${CONFIG_NAME:-${MATRIX_CONFIG:-default}}"

if [ ! -d "${OPENWRT_DIR}" ]; then
  echo "[ERROR] OpenWrt directory not found: ${OPENWRT_DIR}"
  exit 1
fi
OPENWRT_DIR="$(cd "${OPENWRT_DIR}" && pwd)"

# 在 feeds update 前同步 feeds.conf.default，并执行可选的 customize.sh。
run_customize() {
  if [ -f "${WORKSPACE_DIR}/feeds.conf.default" ]; then
    cp "${WORKSPACE_DIR}/feeds.conf.default" "${OPENWRT_DIR}/feeds.conf.default"
  fi

  if [ -f "${WORKSPACE_DIR}/scripts/customize.sh" ]; then
    chmod +x "${WORKSPACE_DIR}/scripts/customize.sh"
    (
      cd "${OPENWRT_DIR}"
      "${WORKSPACE_DIR}/scripts/customize.sh"
    )
  fi
}

# 加载目标设备的 .config；若不存在则回退到 default.config，并同步 defconfig。
load_config() {
  local config_file="${WORKSPACE_DIR}/configs/${CONFIG_NAME}.config"
  local default_config="${WORKSPACE_DIR}/configs/default.config"

  if [ -f "${config_file}" ]; then
    cp "${config_file}" "${OPENWRT_DIR}/.config"
    echo "已加载配置: ${config_file}"
  elif [ -f "${default_config}" ]; then
    cp "${default_config}" "${OPENWRT_DIR}/.config"
    echo "已加载默认配置"
  else
    echo "未找到配置文件，使用默认配置"
  fi

  (
    cd "${OPENWRT_DIR}"
    make defconfig
  )
}

# 动态发现并执行 diy-*.sh，支持 fork 用户自由增删改脚本文件。
run_diy_scripts() {
  shopt -s nullglob
  local diy_scripts=("${WORKSPACE_DIR}"/scripts/diy-*.sh)

  if [ ${#diy_scripts[@]} -eq 0 ]; then
    echo "⚠️ 未找到任何 diy-*.sh 脚本，跳过"
    return 0
  fi

  mapfile -t diy_scripts < <(printf '%s\n' "${diy_scripts[@]}" | sort)

  local script
  for script in "${diy_scripts[@]}"; do
    echo "▶️ 执行: $(basename "${script}")"
    chmod +x "${script}"
    (
      cd "${OPENWRT_DIR}"
      GITHUB_WORKSPACE="${WORKSPACE_DIR}" \
      MATRIX_CONFIG="${CONFIG_NAME}" \
      OPENWRT_DIR="${OPENWRT_DIR}" \
      bash "${script}"
    )
    echo "✅ 完成: $(basename "${script}")"
  done
}

# 清理下载目录中的异常小文件，避免污染编译，但保留 Go 模块缓存。
clean_downloads() {
  (
    cd "${OPENWRT_DIR}"
    find dl -type f -size -1024c -not -path 'dl/go-mod-cache/*' -exec ls -l {} \;
    find dl -type f -size -1024c -not -path 'dl/go-mod-cache/*' -exec rm -f {} \;
  )
}

case "${1:-}" in
  pre-feeds)
    run_customize
    ;;
  load-config)
    load_config
    ;;
  run-diy-scripts)
    run_diy_scripts
    ;;
  clean-downloads)
    clean_downloads
    ;;
  *)
    usage
    exit 1
    ;;
esac