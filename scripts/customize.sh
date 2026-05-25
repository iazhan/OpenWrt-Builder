#!/bin/bash
# ================================================
# customize.sh - 修改 feeds 源（在 feeds update 之前执行）
# ================================================

set -euo pipefail

# ---- 预留 feeds 自定义入口 ----
# 默认代理栈已从 Nikki 切换为 DAED；DAED 通过 diy-2-packages.sh
# 固定 commit 稀疏克隆到 package/，这里不再追加 Nikki feed。

echo "✅ customize.sh 执行完毕"
