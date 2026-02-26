# OpenWrt Auto Builder

基于 [LiBwrt/openwrt-6.x](https://github.com/LiBwrt/openwrt-6.x) 的 GitHub Actions 自动编译框架，支持多设备并行编译、自动发布固件。

---

## 特性

- 🚀 推送代码自动触发编译
- 📦 多设备配置并行编译，互不干扰
- 🔍 每6小时自动检测上游更新，有新提交自动开始编译
- 🛠️ 脚本模块化，新增自定义脚本无需修改 workflow
- 📋 编译产物自动发布到 Releases，保留最近5个版本

---

## 仓库结构

```
.
├── .github/
│   └── workflows/
│       ├── build-openwrt.yml   # 主编译流程
│       ├── manual-build.yml    # 手动触发编译（支持 SSH 调试）
│       └── check-update.yml    # 上游更新检查
├── configs/
│   ├── default.config          # 默认配置（无其他 config 时使用）
│   └── <device>.config         # 设备配置文件，支持多个
├── scripts/
│   ├── customize.sh            # feeds 更新前执行（用于添加第三方 feed 源）
│   ├── diy-1-settings.sh       # 系统设置（IP、主机名、时区、主题等）
│   └── diy-2-packages.sh       # 添加额外软件包（稀疏克隆）
└── README.md
```

---

## 快速开始

### 第一步：获取设备配置文件

在本地参考下方[本地生成配置文件](#本地生成配置文件)生成 `.config` 文件，放入 `configs/` 目录，按设备命名：

```
configs/ax3600.config
configs/ax9000.config
```

> 存在非 `default` 的配置文件时，`default.config` 会被自动跳过。

### 第二步：推送到仓库

```bash
git add configs/ax3600.config
git commit -m "add ax3600 config"
git push
```

推送后 GitHub Actions 自动触发编译。

### 第三步：下载固件

编译完成后，固件发布在仓库的 **Releases** 页面。

---

## 触发方式

| 方式 | 说明 |
|------|------|
| 推送代码 | 修改 `configs/`、`scripts/` 目录或 workflow 文件时自动触发 |
| 定时编译 | 每天北京时间 10:00 执行，默认关闭；在仓库 `Settings → Secrets and variables → Actions → Variables` 中新建变量 `ENABLE_SCHEDULE`，值设为 `true` 即可开启 |
| 上游更新 | 每6小时检查一次，有新提交自动触发 |
| 手动触发 | 在 Actions 页面运行 `手动触发编译`，可指定配置名和是否开启 SSH 调试 |

---

## 自定义脚本

所有位于 `scripts/` 目录下的 `diy-*.sh` 脚本会在编译前**按文件名排序自动执行**，无需修改任何 workflow 文件。

### 执行顺序

```
customize.sh          # feeds update 之前运行（添加第三方 feed 源）
        ↓
feeds update & install
        ↓
diy-1-settings.sh     # 系统设置
diy-2-packages.sh     # 添加插件
diy-3-xxx.sh          # 新增脚本，自动执行 ✅
        ↓
开始编译
```

### 新增脚本

只需在 `scripts/` 目录下新建文件，命名遵循 `diy-<数字>-<描述>.sh` 规则，数字决定执行顺序：

```bash
# 示例：新增一个专门处理 SmartDNS 的脚本
touch scripts/diy-3-smartdns.sh
```

### customize.sh

在 `feeds update` 之前运行，用于添加第三方 feed 源：

```bash
echo "src-git helloworld https://github.com/fw876/helloworld.git" >> feeds.conf.default
```

### diy-1-settings.sh

修改路由器默认参数：

```bash
# 修改默认 IP
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名
sed -i 's/OpenWrt/MyRouter/g' package/base-files/files/bin/config_generate

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
```

### diy-2-packages.sh

使用稀疏克隆添加第三方软件包，只拉取仓库中指定的子目录，速度快、节省空间：

```bash
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

git_sparse_clone main https://github.com/nikkinikki-org/OpenWrt-nikki nikki luci-app-nikki
```

---

## 多设备并行编译

`configs/` 目录下每个 `.config` 文件对应一个独立的编译 job，所有 job 并行运行：

```
configs/
├── ax3600.config   →  编译 job 1 ──┐
├── ax9000.config   →  编译 job 2 ──┤ 同时运行
└── r4s.config      →  编译 job 3 ──┘
```

每个 job 产出独立的 Release，tag 名包含设备名和时间戳以便区分。

---

## 本地生成配置文件

```bash
# 克隆上游源码
git clone --depth 1 --single-branch --branch main-nss \
  https://github.com/LiBwrt/openwrt-6.x openwrt
cd openwrt

# 更新 feeds
./scripts/feeds update -a && ./scripts/feeds install -a

# 图形化配置，选择目标设备和需要的软件包
make menuconfig

# 将生成的 .config 复制到本仓库
cp .config /path/to/this-repo/configs/your-device.config
```

---

## 默认参数

| 参数 | 值 |
|------|----|
| 上游源码 | [LiBwrt/openwrt-6.x](https://github.com/LiBwrt/openwrt-6.x) |
| 编译分支 | `main-nss` |
| 默认登录 IP | `192.168.100.1` |
| 默认密码 | 无 |
| Release 保留数量 | 最近 5 个 |
| Artifact 保留天数 | 7 天 |

---

## License

MIT