---
title: ssh
createTime: 2026/07/10 15:49:47
permalink: /linux/ukt34y3p/
---
## ssh 远程登录

在Ubuntu上开启SSH远程登录，主要需要完成安装 SSH 服务、启动服务和配置防火墙这三步。

## 1. 安装OpenSSH服务器

首先，更新软件包列表，然后安装 `openssh-server`

```bash
sudo apt update
sudo apt install openssh-server
```

### 2. 启动与验证SSH服务

安装完成后，SSH服务通常会自动启动。为确保万无一失，可以执行以下命令启动服务并设置开机自启：

```bash
sudo systemctl enable --now ssh
```

接着，检查服务状态，确认其正在运行：

```bash
sudo systemctl status ssh
```

如果看到输出中有 `active (running)` 字样，说明SSH服务已成功运行。

```bash{3}
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/usr/lib/systemd/system/ssh.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-07-10 15:38:26 CST; 2min 0s ago
 Invocation: 06f230469e404a34a1e53e5a8f945262
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 18206 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 18209 (sshd)
      Tasks: 1 (limit: 6080)
     Memory: 4.1M (peak: 5.9M)
        CPU: 52ms
     CGroup: /system.slice/ssh.service
             └─18209 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```

### 3. 配置防火墙

Ubuntu默认使用 `ufw`（Uncomplicated Firewall）防火墙。如果防火墙已开启，需要放行SSH默认的22端口。

```bash
sudo ufw allow ssh
```

或者，你也可以直接指定端口号：

```bash
sudo ufw allow 22/tcp
```

### 4. 获取IP地址并远程连接

在被控的Ubuntu机器上，使用以下命令查看其IP地址：

```bash
hostname -I
```

然后，在另一台电脑的终端中输入以下命令进行连接：

```bash
ssh 用户名@IP地址
```

- **首次连接**时，系统会提示确认主机指纹，输入 `yes` 即可。
- 随后输入对应用户的密码即可登录。
