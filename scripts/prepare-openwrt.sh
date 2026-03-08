#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: prepare-openwrt.sh <pre-feeds|load-config|run-diy-scripts|clean-downloads>
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