<div align="center">

# OpenWrt Builder

基于 [LiBwrt/openwrt-6.x](https://github.com/LiBwrt/openwrt-6.x) 的 OpenWrt 自动化编译模板仓库

[![Build OpenWrt](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/build-openwrt.yml/badge.svg)](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/build-openwrt.yml)
[![Manual Build](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/manual-build.yml/badge.svg)](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/manual-build.yml)
[![Check Update](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/check-update.yml/badge.svg)](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/check-update.yml)
[![Validate](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/validate-configs.yml/badge.svg)](https://github.com/iazhan/OpenWrt-Builder/actions/workflows/validate-configs.yml)
[![Latest Release](https://img.shields.io/github/v/release/iazhan/OpenWrt-Builder?display_name=tag)](https://github.com/iazhan/OpenWrt-Builder/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

</div>

> [!IMPORTANT]
> 这个仓库当前只维护并发布 **兆能 M2 无 Wi-Fi 版（ZN M2 / NOWiFi）** 固件。  
> 仓库虽然是模板形式，支持 fork 后继续扩展，但本仓库默认 **只编译兆能 M2（NOWiFi）**。

## 项目定位

本仓库不是 OpenWrt 源码仓库，而是 [LiBwrt/openwrt-6.x](https://github.com/LiBwrt/openwrt-6.x) 的自动化编译外壳，用来完成以下事情：

- 拉取上游 OpenWrt 源码
- 加载 `configs/*.config` 与 `configs/*.cfg`
- 在编译前执行 `scripts/customize.sh` 和 `scripts/diy-*.sh`
- 自动上传 Artifact 与发布 Release
- 定时检查上游更新并触发构建
- 为 fork 用户提供一个可自由改造的编译模板

当前仓库默认使用的上游信息：

- 上游仓库：`LiBwrt/openwrt-6.x`
- 上游分支：`main-nss`

## 当前仓库实际编译范围

当前仓库内真正维护、编译并发布的设备只有 1 个：

| 设备型号 | 平台 | Target / Subtarget | 配置文件 | 说明 |
| --- | --- | --- | --- | --- |
| 兆能 M2 无 Wi-Fi 版（ZN M2 / NOWiFi） | Qualcomm IPQ60xx | `qualcommax/ipq60xx` | `configs/ZN_M2-NOWiFi.config` / `configs/ZN_M2-NOWiFi.cfg` | 当前仓库唯一实际维护的固件目标 |

补充说明：

- `configs/ZN_M2-NOWiFi.cfg` 中设置了 `NOWIFI=true`，表示当前发布的是 **无 Wi-Fi 变体**。
- `configs/default.config` 和 `configs/default.cfg` 只是模板 / 回退配置，不代表一个实际维护中的设备型号。
- 如果你 fork 这个仓库并新增自己的 `configs/<device>.config`，才会扩展到你自己的设备。

## 上游支持设备清单

下面这份列表是按 **2026-03-08** 查询上游 `LiBwrt/openwrt-6.x` 的 `main-nss` 分支后整理的，主要对应 `qualcommax/ipq60xx` 与 `qualcommax/ipq807x` 设备。  
这表示 **上游源码支持这些型号**，不表示本仓库都会编译它们；**本仓库当前仍然只编译兆能 M2（NOWiFi）**。  

<details>
<summary><b>IPQ60xx 设备（中文名称）</b></summary>

- ALFA Network AP120C-AX
- AnySafe E1
- Cambium Networks XE3-4
- 中移物联 AX18
- GL.iNet GL-AX1800、GL-AXT1800
- 京东云 亚瑟、雅典娜、太乙
- KT AR06-012H
- LG GAPD-7500
- LINK NN6000 v1、NN6000 v2
- 领势 MR7350、MR7500
- 网件 Orbi RBR350、Orbi RBS350、WAX214、WAX610、WAX610Y
- 360 V6
- 红米 AX5、AX5 京东云版
- 普联 EAP610 室外版、EAP623 室外高密版 v1、EAP625 室外高密版 v1 / v1.6、EAP620 HD v3
- 小米 AX1800
- 云科 FAP650
- 兆能 M2

</details>

<details>
<summary><b>IPQ807x 设备（中文名称）</b></summary>

- 阿里云 AP8220
- Arcadyan AW1000
- 华硕 RT-AX89X
- 巴法络 WXR-5950AX12
- 中国移动 RM2-6
- Compex WPQ873
- Dynalink DL-WRX36
- Edgecore EAP102
- 讯舟 CAX1800
- Inseego FG2000
- 领势 HomeWRK、MX4200 v1、MX4200 v2、MX4300、MX5300、MX8500
- 网件 RAX120 v2、Orbi RBR750、Orbi RBS750、SXR80、SXS80、WAX218、WAX620、WAX630
- prpl Foundation Haze
- 威联通 301w
- 红米 AX6（含 stock 变体）
- Spectrum SAX1V1K
- TCL LINKHUB HH500V
- 普联 Deco X80-5G、EAP620 HD v1、EAP660 HD v1
- 威瑞森 CR1000A
- 小米 AX3600、小米 AX9000（均含 stock 变体）
- 云科 AX880
- ZBTLink ZBT-Z800AX
- 中兴 MF269（含 stock 变体）
- 合勤 NBG7815、NWA110AX、NWA210AX

</details>

## 仓库特性

- `push` 后自动构建
- 支持 GitHub Actions 手动选择配置编译
- 支持定时检查上游更新并触发构建
- 构建成功后自动上传 Artifact 与 Release
- 构建失败后自动上传失败日志
- 提供 `validate-configs.yml` 校验配置文件与脚本命名
- 通过 `scripts/prepare-openwrt.sh` 动态发现并执行 `scripts/diy-*.sh`

## 工作流说明

| 工作流 | 文件 | 作用 |
| --- | --- | --- |
| 自动编译 | `.github/workflows/build-openwrt.yml` | 代码变更后自动构建，支持矩阵遍历 `configs/*.config` |
| 手动编译 | `.github/workflows/manual-build.yml` | 在 Actions 页面手动指定配置名称进行构建 |
| 上游更新检查 | `.github/workflows/check-update.yml` | 检查 `LiBwrt/openwrt-6.x` 是否有新提交 |
| 定时触发 | `.github/workflows/schedule-build.yml` | 配合仓库变量按计划触发构建 |
| 配置校验 | `.github/workflows/validate-configs.yml` | 校验 `.config`、`.cfg` 和脚本命名 / 语法 |

## 目录结构

```text
.
├─ .github/workflows/
│  ├─ build-openwrt.yml
│  ├─ manual-build.yml
│  ├─ check-update.yml
│  ├─ schedule-build.yml
│  └─ validate-configs.yml
├─ configs/
│  ├─ default.config
│  ├─ default.cfg
│  ├─ ZN_M2-NOWiFi.config
│  └─ ZN_M2-NOWiFi.cfg
├─ scripts/
│  ├─ customize.sh
│  ├─ diy-1-settings.sh
│  ├─ diy-2-packages.sh
│  ├─ diy-3-fix_mbedtls.sh
│  ├─ lib-builder-config.sh
│  ├─ prepare-openwrt.sh
│  └─ third-party-sources.sh
├─ docs/
├─ LICENSE
└─ README.md
```

## `diy-*.sh` 的设计目的

这个仓库保留 `diy-*.sh` 的初衷，就是为了让 fork 用户能更方便地定制自己的 OpenWrt 固件，而不需要同步修改工作流文件。

当前实现方式是：

- `scripts/prepare-openwrt.sh` 会自动发现 `scripts/diy-*.sh`
- 按文件名排序执行这些脚本
- workflow 不会把某一个固定脚本名写死

所以 fork 用户可以自由：

- 删除不需要的 `diy-*.sh`
- 修改现有 `diy-*.sh` 的内容
- 新增自己的 `diy-*.sh`
- 调整编号来改变执行顺序

推荐命名格式：

```text
diy-<数字>-<描述>.sh
```

例如：

- `scripts/diy-1-settings.sh`
- `scripts/diy-2-packages.sh`
- `scripts/diy-3-fix_mbedtls.sh`
- `scripts/diy-9-my-custom.sh`

## 第三方依赖如何获取

当前仓库里的第三方包，主要通过下面两部分获取：

- `scripts/diy-2-packages.sh`：负责在编译前拉取或整理第三方包
- `scripts/third-party-sources.sh`：统一维护第三方仓库地址、分支和固定 revision

这样做的好处是：

- 当前示例仓库的依赖来源更清晰
- 构建结果更容易复现
- fork 用户要替换依赖时，改动入口更集中

如果你 fork 后不想沿用这些第三方包，直接修改或删除对应 `diy-*.sh` 即可。

## 如何 fork 后定制自己的设备

如果你想把这个仓库当成模板，通常只需要做下面几步：

### 1. 生成你自己的 `.config`

```bash
git clone --depth 1 --single-branch --branch main-nss https://github.com/LiBwrt/openwrt-6.x openwrt
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

生成完成后，把 `.config` 保存到本仓库：

```bash
cp .config /path/to/your-repo/configs/your-device.config
```

### 2. 新增对应的 `.cfg`

例如：

```text
configs/your-device.cfg
```

这个文件可用于设置默认 IP、主机名、主题、Wi-Fi、Release 描述等参数。

### 3. 按需修改 `diy-*.sh`

你可以：

- 保留当前脚本
- 删除不需要的脚本
- 重写脚本内容
- 新增自己的 `diy-*.sh`

### 4. 推送并触发构建

```bash
git add .
git commit -m "customize build"
git push
```

## 当前仓库的默认说明

| 项目 | 当前值 |
| --- | --- |
| 上游源码 | `LiBwrt/openwrt-6.x` |
| 上游分支 | `main-nss` |
| 当前仓库实际编译设备 | `兆能 M2 无 Wi-Fi 版（ZN M2 / NOWiFi）` |
| 设备配置 | `configs/ZN_M2-NOWiFi.config` |
| 参数配置 | `configs/ZN_M2-NOWiFi.cfg` |

## FAQ

### 这个仓库是不是多设备固件仓库？

不是。它是一个 **多设备可扩展模板仓库**，但当前这个仓库本身只维护并发布：

- **兆能 M2 无 Wi-Fi 版（ZN M2 / NOWiFi）**

### `default.config` 是不是一个设备型号？

不是。`default.config` / `default.cfg` 只是模板和回退配置。

### fork 后能不能自由增删 `diy-*.sh`？

可以，这正是当前脚本设计的目的之一。只要文件名符合 `diy-<数字>-<描述>.sh`，就会被自动发现并按顺序执行。

## License

MIT
