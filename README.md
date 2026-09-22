# Windows 资源管理器右键 → Cursor Agent

在文件夹上（或文件夹空白处）右键，输入任务说明后，调用本机 `agent` CLI 对该目录执行。

## 前提

1. 已安装 [Cursor CLI](https://cursor.com/docs/cli/headless)（本机常见路径：`%LOCALAPPDATA%\cursor-agent\agent.cmd`）
2. 已登录，或设置了环境变量 `CURSOR_API_KEY`：

```powershell
agent login
# 或
$env:CURSOR_API_KEY = 'your_api_key'
```

## 安装

在 PowerShell 中执行：

```powershell
cd <本工具所在目录>
.\Install-ContextMenu.ps1
```

无需管理员权限（写入当前用户 HKCU）。

## 使用

1. 在资源管理器中，右键某个**文件夹**，或进入文件夹后在**空白处**右键
2. 选择 **用 Cursor Agent 执行...**
3. 在对话框中输入任务说明，点确定
4. 新开控制台窗口运行 `agent -p --force --trust --workspace <路径>`，结束后按 Enter 关闭

Win11 若只看到精简右键，点「显示更多选项」即可看到本菜单。

## 卸载

```powershell
cd <本工具所在目录>
.\Uninstall-ContextMenu.ps1
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `Invoke-CursorAgent.ps1` | 弹窗取任务并启动 agent |
| `Install-ContextMenu.ps1` | 注册右键菜单 |
| `Uninstall-ContextMenu.ps1` | 删除右键菜单 |

## 自测建议

安装后对任意测试文件夹右键，输入例如：

> 列出本目录主要文件并简要总结用途（不要修改任何文件）

应弹出新控制台并看到 agent 输出。若提示未找到 agent 或未认证，按上方「前提」检查。