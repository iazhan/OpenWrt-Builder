#!/bin/bash

OPENWRT_HELLOWORLD_REPO="https://github.com/sbwml/openwrt_helloworld"
OPENWRT_HELLOWORLD_BRANCH="v5"
OPENWRT_HELLOWORLD_COMMIT="a1f228d0be5c6f7021d092e86f67626482120e1c"

GOLANG_REPO="https://github.com/sbwml/packages_lang_golang"
GOLANG_BRANCH="26.x"
GOLANG_COMMIT="dd4792423c1e93788fe25415ba04398f9c34e298"

ARGON_THEME_REPO="https://github.com/jerrykuku/luci-theme-argon"
ARGON_THEME_BRANCH="master"
ARGON_THEME_COMMIT="7aba78ccb84297496f63e1dacefe64c89d83d72e"

ARGON_CONFIG_REPO="https://github.com/jerrykuku/luci-app-argon-config"
ARGON_CONFIG_BRANCH="master"
ARGON_CONFIG_COMMIT="2ddae597f994f8a49358f8dfd03b7e6a732aae63"

AURORA_THEME_REPO="https://github.com/eamonxg/luci-theme-aurora"
AURORA_THEME_BRANCH="master"
AURORA_THEME_COMMIT="8b38d8dd6b4f321c8f146a6d936772d89fc56e77"

AURORA_CONFIG_REPO="https://github.com/eamonxg/luci-app-aurora-config"
AURORA_CONFIG_BRANCH="master"
AURORA_CONFIG_COMMIT="3b15aa3bcb39da16378afdb0f8ce2fa139a48e5b"

EXTRA_PACKAGES_REPO="https://github.com/VIKINGYFY/packages"
EXTRA_PACKAGES_BRANCH="main"
EXTRA_PACKAGES_COMMIT="c7fc2e68e5252768616a3a281ce673bd4b19b7d0"

clone_pinned_repo() {
  local repo="$1"
  local branch="$2"
  local commit="$3"
  local dest="$4"

  rm -rf "$dest"
  git clone --depth=1 --branch "$branch" --single-branch "$repo" "$dest"

  local current
  current="$(git -C "$dest" rev-parse HEAD)"
  if [ "$current" != "$commit" ]; then
    git -C "$dest" fetch --depth=1 origin "$commit"
    git -C "$dest" checkout -q "$commit"
  fi
}

git_sparse_clone_pinned() {
  local branch="$1"
  local repo="$2"
  local commit="$3"
  shift 3

  local repo_name="${repo##*/}"
  repo_name="${repo_name%.git}"
  local tmpdir
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/${repo_name}.XXXXXX")"

  git clone --depth=1 --branch "$branch" --single-branch --filter=blob:none --sparse "$repo" "$tmpdir"

  local current
  current="$(git -C "$tmpdir" rev-parse HEAD)"
  if [ "$current" != "$commit" ]; then
    git -C "$tmpdir" fetch --depth=1 origin "$commit"
    git -C "$tmpdir" checkout -q "$commit"
  fi

  git -C "$tmpdir" sparse-checkout set "$@"
  mkdir -p package
  for path in "$@"; do
    rm -rf "package/${path##*/}"
    mv -f "$tmpdir/$path" package/
  done
  rm -rf "$tmpdir"
}

emit_third_party_markdown() {
  cat <<EOF
## 🔗 第三方依赖版本

- \`openwrt_helloworld\`: [sbwml/openwrt_helloworld@${OPENWRT_HELLOWORLD_COMMIT}](https://github.com/sbwml/openwrt_helloworld/commit/${OPENWRT_HELLOWORLD_COMMIT})
- \`packages_lang_golang\`: [sbwml/packages_lang_golang@${GOLANG_COMMIT}](https://github.com/sbwml/packages_lang_golang/commit/${GOLANG_COMMIT})
- \`luci-theme-argon\`: [jerrykuku/luci-theme-argon@${ARGON_THEME_COMMIT}](https://github.com/jerrykuku/luci-theme-argon/commit/${ARGON_THEME_COMMIT})
- \`luci-app-argon-config\`: [jerrykuku/luci-app-argon-config@${ARGON_CONFIG_COMMIT}](https://github.com/jerrykuku/luci-app-argon-config/commit/${ARGON_CONFIG_COMMIT})
- \`luci-theme-aurora\`: [eamonxg/luci-theme-aurora@${AURORA_THEME_COMMIT}](https://github.com/eamonxg/luci-theme-aurora/commit/${AURORA_THEME_COMMIT})
- \`luci-app-aurora-config\`: [eamonxg/luci-app-aurora-config@${AURORA_CONFIG_COMMIT}](https://github.com/eamonxg/luci-app-aurora-config/commit/${AURORA_CONFIG_COMMIT})
- \`luci-app-wolplus\`: [VIKINGYFY/packages@${EXTRA_PACKAGES_COMMIT}](https://github.com/VIKINGYFY/packages/commit/${EXTRA_PACKAGES_COMMIT})
EOF
}