---
title: Mysql
createTime: 2026/07/10 15:49:47
permalink: /linux/viwmsl2i/
---
## 准备工作

### 更新系统软件包

```bash
sudo apt update && sudo apt upgrade -y
```

- -y 参数表示自动确认更新，避免中途交互等待，适合批量部署场景。

### 防火墙放行

```bash
# 放行端口
sudo ufw allow 3306/tcp
# 查看防火墙规则
sudo ufw status
```

### 检查系统环境

确认系统架构与 Ubuntu 版本，确保与 MySQL 安装包兼容，执行命令：

```bash
# 查看系统版本
lsb_release -a
# 查看系统架构
uname -m
```

Ubuntu 20.04/22.04/26.04 推荐安装 MySQL 8.0 版本，兼容性最优，后续操作均以 MySQL 8.0 为例。

## MySQL 安装

### 安装 MySQL

```bash
sudo apt install -y mysql-server
```

安装过程中会弹出设置 root 密码的窗口，务必设置强密码（包含大小写字母、数字、特殊符号），并牢记密码，后续登录与配置需使用。

### 安装验证

```bash
# 查看版本
mysql --version
查看服务状态
sudo systemctl status mysql
```

服务状态显示 `active (running)`，说明成功启动。

```mysql{3}
mysql.service - MySQL Community Server
     Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-07-10 23:06:38 CST; 10min ago
 Invocation: 32f28849100e4aa8a7717e61787f61ab
    Process: 346590 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, >
   Main PID: 346600 (mysqld)
     Status: "Server is operational"
      Tasks: 35 (limit: 6080)
     Memory: 479.1M (peak: 479.4M)
        CPU: 3.599s
     CGroup: /system.slice/mysql.service
             └─346600 /usr/sbin/mysqld
```

## MySQL 初始化配置

MySQL 安装后存在默认安全隐患，需执行官方安全脚本优化配置，执行命令：

```bash
sudo mysql_secure_installation
```

执行后会依次出现以下交互选项，按以下建议配置：

- Enter password for user root：输入安装时设置的 root 密码，回车确认。
- VALIDATE PASSWORD COMPONENT：是否开启密码强度验证，建议选 Y（开启），提升安全性。
- Password validation policy level：选择密码强度等级，推荐选 2（STRONG，强等级），要求密码长度≥8，包含大小写、数字、特殊符号。
- Change the password for root：是否修改 root 密码，若安装时已设置强密码，可选 N；若需修改，选 Y 并重新设置。
- Remove anonymous users：是否删除匿名用户，建议选 Y，避免未授权访问。
- Disallow root login remotely：是否禁止 root 用户远程登录，建议选 Y（后续可创建专用远程用户，更安全）。
- Remove test database and access to it：是否删除测试数据库，建议选 Y，清理无用数据。
- Reload privilege tables now：是否立即重新加载权限表，选 Y，使配置生效。

## 登录 MySQL 验证

初始化完成后，登录 MySQL 验证配置，Ubuntu 通过 apt 安装的 MySQL，默认对 root 用户启用了 `auth_socket` 认证。只需要用系统 `sudo` 权限登录即可，输入密码时直接回车。

```bash
sudo mysql -u root -p
```

进入 MySQL 命令行（显示 ``mysql>` ），说明登录成功。可执行 `show databases;` 查看默认数据库，验证服务正常。

```mysql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)
```

## 基础配置

### 配置文件修改

MySQL 主配置文件为 `/etc/mysql/mysql.conf.d/mysqld.cnf`，运维中常用配置项如下，修改前建议先备份配置文件：

```bash
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
```

使用 vim 编辑配置文件：

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

### 常用配置项说明

- bind-address：监听地址，默认 127.0.0.1（仅本地访问），若需远程访问，修改为 0.0.0.0（允许所有地址访问），或指定固定 IP。
- port：监听端口，默认 3306，若需修改，直接修改数值（如 3307），修改后需重启服务。
- max_connections：最大连接数，默认 151，根据业务需求调整（如 500、1000），避免连接数不足。
- character-set-server：默认字符集，推荐设置为 utf8mb4，支持 emoji 表情，避免中文乱码。
- collation-server：字符集排序规则，对应 utf8mb4，设置为 utf8mb4_unicode_ci。

修改示例（关键配置）：

```ini
[mysqld]
# 监听地址，允许远程访问
bind-address = 0.0.0.0
# 监听端口
port = 3306
# 最大连接数
max_connections = 500
# 默认字符集
character-set-server = utf8mb4
# 排序规则
collation-server = utf8mb4_unicode_ci
# 关闭只读模式（主从复制场景需开启，单节点关闭）
read-only = 0
```

修改完成后，保存退出 vim（按 Esc，输入 :wq 回车），重启 MySQL 服务使配置生效：

```bash
sudo systemctl restart mysql
```

### 字符集配置验证

登录 MySQL，执行以下命令验证字符集配置：

```sql
show variables like '%character%';
show variables like '%collation%';
```

若结果中 character_set_server、collation_server 均为 utf8mb4 相关配置，说明配置生效。

## 用户与权限管理

MySQL 中 root 用户权限过高，运维中建议创建专用用户，分配对应权限，避免使用 root 用户直接操作业务数据库。

### 创建新用户

登录 MySQL 后，执行以下命令创建新用户（示例：创建用户 tom，允许远程访问，密码为 123456）：

```sql
CREATE USER 'tom'@'%' IDENTIFIED BY '123456';
```

说明：

- 'tom'：用户名，可根据业务自定义。
- '%'：允许该用户从任意地址远程访问，若仅允许本地访问，改为 'localhost'；若允许指定 IP 访问，改为 '192.168.1.100'（替换为实际 IP）。
- 密码需符合安全初始化时设置的强度要求，避免弱密码。

## 远程连接

默认情况下，MySQL 仅允许本地访问，若需远程连接（如通过 Navicat、DBeaver 等工具），需完成以下两步配置。

### 修改 MySQL 配置文件（允许远程监听）

将配置文件中的 bind-address 修改为 0.0.0.0，重启 MySQL 服务。

### 开放系统防火墙端口

Ubuntu 系统默认使用 ufw 防火墙，需开放 MySQL 监听端口（默认 3306），执行以下命令：

```bash
# 开放3306端口
sudo ufw allow 3306/tcp
# 重启防火墙使配置生效
sudo ufw reload
# 查看防火墙规则，验证端口是否开放
sudo ufw status
```

若服务器使用云服务器（如阿里云、腾讯云），还需在云平台安全组中开放 3306 端口，否则远程连接会失败。

### 远程连接验证

使用远程工具连接 MySQL，输入服务器 IP、端口、用户名、密码，若能成功连接，说明远程访问配置生效。

```
ALTER USER 'tom'@'%' IDENTIFIED BY '123456';
```

