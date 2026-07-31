# RustDesk ID 与服务器修改工具

这是一个 Windows 批处理工具，用于修改 RustDesk ID，以及切换公共服务器和私有服务器配置。

[![版本](https://img.shields.io/badge/版本-v3-blue.svg)](https://github.com/RingoCaviar/RustDesk-ID-Server-Changer)

## 下载

- [下载中文版本](https://github.com/RingoCaviar/RustDesk-ID-Server-Changer/archive/refs/heads/chinese-version.zip)
- [RustDesk 官方仓库](https://github.com/rustdesk/rustdesk)

中文脚本文件：`RustDesk_ID_Server_Changer_CN.bat`

## 功能

### 1. 使用计算机名设置 RustDesk ID

将 RustDesk ID 修改为当前计算机名，适合批量部署或系统镜像恢复后的设备。修改后无需重启 Windows。

### 2. 使用随机数字设置 RustDesk ID

生成 9 位随机数字，并将其设置为新的 RustDesk ID。

### 3. 设置自定义 RustDesk ID

输入一个自定义 ID。ID 至少需要 6 个字符。

### 4. 切换到公共服务器

备份当前私有服务器配置，然后清除自定义服务器信息，使 RustDesk 使用默认公共服务器。

### 5. 切换到私有服务器

恢复之前备份的私有服务器配置。如果没有找到备份，脚本会提示先在 RustDesk 中配置私有服务器。

### 6. 设置新的私有服务器

输入私有服务器的 IP 地址或主机名，以及可选的 Key，脚本会自动写入配置并重启 RustDesk。

### 7. 删除私有服务器备份

删除脚本此前保存的私有服务器配置备份。

## 使用方法

1. 下载 `RustDesk_ID_Server_Changer_CN.bat`。
2. 右键脚本，选择“以管理员身份运行”。
3. 根据菜单提示输入选项。

脚本会自动检测 RustDesk 的安装位置，支持注册表记录的安装路径、自定义盘符以及常见的 `Program Files` 目录。

## 注意事项

- 使用修改 ID 或服务器配置的功能前，请先关闭正在运行的 RustDesk 连接。
- 脚本需要管理员权限才能修改系统服务模式下的配置文件。
- 修改服务器配置前，建议保留现有配置备份。
- 当前脚本主要适用于 Windows 安装版 RustDesk。

## 兼容性

- Windows 7、8.1、10、11
- PowerShell 2.0 及更高版本
- RustDesk 安装版

## 预览

![工具预览](https://github.com/RingoCaviar/RustDesk-ID-Server-Changer/blob/chinese-version/preview.jpg)

## 相关链接

- [RustDesk 官方网站](https://rustdesk.com/)
- [项目问题反馈](https://github.com/RingoCaviar/RustDesk-ID-Server-Changer/issues)
