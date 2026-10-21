# 跨平台兼容性规则 (Windows / Linux / macOS)

## 概述

确保 TinyCast 项目在 Windows、Linux 和 macOS 上都能正常克隆、构建和运行，避免因文件系统差异导致的兼容性问题。

---

## 1. 文件名限制

### Windows 非法字符（绝对禁止）

文件名和目录名**不得包含**以下字符：

```
:  *  ?  "  <  >  |
```

### 其他限制

- 路径总长度不超过 260 字符（Windows MAX_PATH）
- 不使用保留名：`CON`, `PRN`, `AUX`, `NUL`, `COM1-9`, `LPT1-9`
- 文件名末尾不能是空格或句点（`.`）

### 安全命名规范

| 场景 | 错误示例 | 正确示例 |
|------|----------|----------|
| 时间戳 | `2026-04-08 11:37:10 data.md` | `2026-04-08_11-37-10_data.md` |
| 特殊字符 | `file:name.txt` | `file_name.txt` |
| 空格 | `my file.dart` | `my_file.dart` |

**规则**：
- 使用 `_`（下划线）或 `-`（连字符）替代空格和特殊字符
- 时间戳中的冒号 `:` 替换为 `-`
- 统一使用 `snake_case` 作为文件名

---

## 2. 换行符统一

不同操作系统的默认换行符不同：
- Windows: `CRLF` (`\r\n`)
- Linux/macOS: `LF` (`\n`)

### Git 配置

项目根目录创建 `.gitattributes` 文件：

```gitattributes
# 文本文件统一使用 LF
* text=auto eol=lf

# Windows 批处理文件使用 CRLF
*.bat text eol=crlf
*.cmd text eol=crlf

# 特定文件标记为二进制
*.png binary
*.jpg binary
*.gif binary
*.ico binary
```

### 本地 Git 设置

```bash
# macOS/Linux
git config --global core.autocrlf input

# Windows
git config --global core.autocrlf true
```

---

## 3. 路径长度控制

### 限制

Windows 默认最大路径长度为 260 字符。

### 规范

- 目录层级不超过 8 层
- 文件名不超过 50 字符
- 避免深层嵌套的目录结构

---

## 4. 大小写敏感

### 问题

- Windows/macOS（默认）：大小写不敏感
- Linux：大小写敏感

### 风险

```
File.dart 和 file.dart 在 Linux 是两个文件
在 Windows/macOS 会被视为同一个文件
```

### 规范

- 严格遵循命名约定：
  - 文件名：`snake_case`
  - 类名：`PascalCase`
  - 变量/函数：`camelCase`
- 重命名文件时使用 `git mv` 而非直接 `mv`
- 定期检查：`git config --get core.ignorecase`

---

## 5. IDE 生成的临时文件

### 当前实际状态

`.gitignore` 已忽略以下 IDE / 工具目录：

```gitignore
# VS Code
.vscode/

# Trae IDE 的日志与 MCP 本地配置
.trae/log/
.trae/mcp.json

# Qoder Harness 运行产物
.qoder/better-harness/
.qoder/better-harness-runs/
```

### 必须跟踪的文件

- `.agents/rules/` 是项目编码约定的 canonical 内容源，**必须提交**，
  不能被 `.gitignore` 忽略；`CLAUDE.md` / `GEMINI.md` / `.windsurfrules`
  是指向 `AGENTS.md` 的 symlink，同样需要跟踪。
- `.trae/specs/`、`.trae/summary/`、`.trae/prompt/`、`.trae/rules/`
  在当前仓库中已被跟踪，属于项目既有约定。新增这些目录下的文件时，遵循
  第 1 节的文件命名规则（时间戳不用冒号），不要把它们加入忽略列表。
- `.gitattributes` 已统一文本换行为 LF，并声明了图片、音频、字体等二进制类型；
  新增二进制资产时记得补充 `binary` 标记。

### 原因

- IDE 日志、MCP 本地配置和 Harness 运行产物因机器而异，提交后会制造无意义 diff；
- 规则文件是团队共享的约束，必须随仓库分发；
- 规范文档与 spec 是项目历史的一部分，是否跟踪应由项目决定，而不是由
  IDE 默认目录名决定。

---

## 6. 脚本文件跨平台兼容

### Shell 脚本

- 使用 `#!/bin/bash` 或 `#!/usr/bin/env bash` 作为 shebang
- 避免使用平台特定的路径（如 `/usr/bin/xxx`）
- 提供 `.bat` 或 `.ps1` 版本供 Windows 用户使用

### 示例：跨平台运行脚本

```bash
#!/bin/bash
# 检测操作系统
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
  Darwin)    echo "macOS";;
  Linux)     echo "Linux";;
  MINGW*)    echo "Windows";;
  MSYS*)     echo "Windows";;
  CYGWIN*)   echo "Windows";;
  *)         echo "Unknown: $OS_TYPE"; exit 1;;
esac
```

---

## 7. Flutter 多平台构建

### 支持的平台

| 平台 | 设备标识 | 构建命令 |
|------|----------|----------|
| macOS | `macos` | `flutter run -d macos` |
| Linux | `linux` | `flutter run -d linux` |
| Windows | `windows` | `flutter run -d windows` |

### 平台特定代码

```dart
import 'dart:io';

String getPlatformName() {
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isLinux) return 'Linux';
  if (Platform.isWindows) return 'Windows';
  return 'Unknown';
}
```

---

## 8. 新建文件检查清单

创建新文件时，确认：

- [ ] 文件名不包含 `: * ? " < > |`
- [ ] 文件名使用 `snake_case`
- [ ] 文件名不超过 50 字符
- [ ] 文件路径不超过 260 字符
- [ ] 文件末尾没有空格或 `.`
- [ ] 文件已加入适当的 `.gitignore` 规则（如果是临时文件）

---

## 9. 克隆和提交检查

### 克隆前检查（Windows 用户）

```bash
# 如果遇到文件名错误，先运行：
git config --global core.protectNTFS false

# 然后重新克隆
git clone <repo-url>
```

### 提交前检查

```bash
# 检查是否有非法文件名
git ls-files | grep -E "[<>:\"\\|?\\*]"

# 检查路径长度
git ls-files | awk '{print length, $0}' | sort -rn | head -10
```

---

trigger: always_on
