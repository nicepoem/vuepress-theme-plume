# Deploy 部署脚本

一键构建 VuePress 站点，并通过 SSH 上传到服务器（支持宝塔面板）。

## 文件清单

| 文件                  | 说明                                        |
| --------------------- | ------------------------------------------- |
| `deploy.bat`          | Windows 一键部署入口（双击运行）            |
| `deploy.ps1`          | PowerShell 主脚本（构建 + 上传 + 进度显示） |
| `deploy.sh`           | Linux / macOS / Git Bash 脚本               |
| `.env.deploy.example` | 部署配置模板                                |
| `.env.deploy`         | 实际部署配置（含密钥信息，**勿提交 Git**）  |

项目根目录另有 `deploy.bat`，会转发到本目录。

## 快速开始

### 1. 配置

```bash
cp deploy/.env.deploy.example deploy/.env.deploy
```

编辑 `deploy/.env.deploy`，填写服务器信息。

### 2. 部署

**Windows（推荐）**

```text
双击 deploy\deploy.bat
```

或：

```bash
pnpm deploy
pnpm deploy:bat
```

**Linux / macOS / Git Bash**

```bash
pnpm deploy:sh
# 或
bash deploy/deploy.sh
```

## 配置说明

| 配置项          | 必填 | 说明                         | 示例                             |
| --------------- | ---- | ---------------------------- | -------------------------------- |
| `DEPLOY_HOST`   | 是   | 服务器 IP 或域名             | `43.143.210.203`                 |
| `DEPLOY_USER`   | 是   | SSH 用户名                   | `root`                           |
| `DEPLOY_PORT`   | 否   | SSH 端口，默认 `22`          | `22`                             |
| `DEPLOY_PATH`   | 是   | 远程网站根目录               | `/www/wwwroot/docs.penx.cn`      |
| `DEPLOY_KEY`    | 否   | SSH 私钥路径，留空用默认密钥 | `C:/Users/xxx/.ssh/id_rsa`       |
| `DEPLOY_METHOD` | 否   | 上传方式，默认 `auto`        | `auto` / `tar` / `scp` / `rsync` |

### 上传方式

| 值      | 说明                                 |
| ------- | ------------------------------------ |
| `auto`  | 优先 tar（快），其次 rsync，最后 scp |
| `tar`   | 本地打包 → scp 上传 → 服务器解压     |
| `rsync` | 增量同步，适合频繁部署               |
| `scp`   | 直接递归上传                         |

## 部署流程

脚本执行 5 个步骤：

1. **检查环境与配置** — pnpm、ssh、scp、`.env.deploy`
2. **构建站点** — 执行 `pnpm docs:build`
3. **打包文件** — 将 `docs/.vuepress/dist` 打成 tar.gz
4. **上传到服务器** — scp + ssh 解压到 `DEPLOY_PATH`
5. **完成** — 显示耗时与访问地址

运行时会显示步骤编号、文本进度条和 PowerShell 进度条。

## 前置条件

### 本地

- [ ] Node.js `^20.19.0` 或 `>=22.0.0`
- [ ] pnpm
- [ ] OpenSSH 客户端（Windows：设置 → 应用 → 可选功能 → OpenSSH 客户端）
- [ ] `tar` 命令（Windows 10+ 自带）

### 服务器

- [ ] SSH 已开启
- [ ] 已配置 SSH 密钥免密登录（推荐）
- [ ] `DEPLOY_PATH` 目录有写入权限

## 宝塔面板配置

1. **添加站点**，记下网站根目录（如 `/www/wwwroot/docs.penx.cn`）
2. **DEPLOY_PATH** 与网站根目录保持一致
3. **伪静态**（VuePress 路由需要）：

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

4. **安全** → 放行 SSH 端口
5. （可选）**SSL** → 申请证书并开启强制 HTTPS

## SSH 密钥配置

### 本地生成密钥

```powershell
ssh-keygen -t rsa -b 4096
```

### 查看公钥

```powershell
cat ~/.ssh/id_rsa.pub
cat /c/Users/zhaohui/.ssh/id_rsa.pub
```

### 添加到服务器

**方式 A：宝塔面板**

安全 → SSH 管理 → 添加公钥 → 粘贴公钥整行

**方式 B：服务器命令行**

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo '公钥' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```



### 测试连接

```powershell
ssh -i ~/.ssh/id_rsa root@43.143.210.203
```

## 迁移到其他项目

本目录可整体复制到其他项目，上传逻辑通用，构建部分需按项目调整。

### 可直接复用

- `deploy.bat` / `deploy.ps1` / `deploy.sh` 的上传逻辑
- `.env.deploy` 配置方式
- SSH / tar / scp / rsync 流程

### 需要修改

| 场景               | 修改位置                  | 改什么                                      |
| ------------------ | ------------------------- | ------------------------------------------- |
| 当前 VuePress 项目 | `.env.deploy`             | 服务器信息、部署目录                        |
| Vite / Vue 静态站  | `deploy.ps1`、`deploy.sh` | `DistDir` → `dist`，构建命令 → `pnpm build` |
| 仅上传、不构建     | 脚本中 `Invoke-Build`     | 注释或跳过构建步骤                          |
| 访问地址提示       | `deploy.ps1` 末尾         | `http://docs.penx.cn` 改为你的域名          |

当前默认配置：

- 构建命令：`pnpm docs:build`
- 输出目录：`docs/.vuepress/dist`
- 项目根目录：脚本所在目录的上一级

## 常见问题

| 问题                               | 处理                                               |
| ---------------------------------- | -------------------------------------------------- |
| `Missing file: deploy\.env.deploy` | 复制 `.env.deploy.example` 为 `.env.deploy` 并填写 |
| `pnpm not found`                   | 安装 Node.js 和 pnpm                               |
| `Permission denied (publickey)`    | 检查公钥是否已添加到服务器                         |
| `Host key verification failed`     | 执行 `ssh-keygen -R 你的服务器IP`                  |
| 构建失败                           | 检查 Markdown 中是否有无效图片路径                 |
| 部署成功但页面 404                 | 检查宝塔伪静态和 `DEPLOY_PATH` 是否正确            |
| `.bat` 乱码或命令报错              | 使用 `deploy\deploy.bat`，界面由 `deploy.ps1` 输出 |

## 手动部署（不用脚本）

```bash
pnpm docs:build
```

将 `docs/.vuepress/dist` 目录内容上传到服务器网站根目录即可。

## 相关命令

在项目根目录 `package.json` 中：

```json
{
  "deploy": "powershell -ExecutionPolicy Bypass -File ./deploy/deploy.ps1",
  "deploy:bat": "deploy\\deploy.bat",
  "deploy:sh": "bash ./deploy/deploy.sh"
}
```