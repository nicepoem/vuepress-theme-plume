---
title: Mysql
createTime: 2026/07/10 15:49:47
permalink: /linux/viwmsl2i/
---
### 更新系统软件包

```bash
sudo apt update && sudo apt upgrade -y
```

- `-y` 参数表示自动确认更新，避免中途交互等待，适合批量部署场景。

### 安装 MySQL

```bash
sudo apt install -y mysql-server
```

安装过程中会弹出设置 root 密码的窗口，务必设置强密码，并牢记密码，后续登录与配置需使用。

安装完成后我们可以查看 mysql 版本验证是否安装成功。

```bash
# 查看版本
mysql --version
# 查看服务状态
sudo systemctl status mysql
```

查看服务状态若显示 `active (running)`，说明成功启动。

```mysql{3}
● mysql.service - MySQL Community Server
     Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-08-10 17:53:51 CST; 1min 48s ago
 Invocation: a7f6e47b40744479828f4152600647d6
    Process: 56896 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, s>
   Main PID: 56906 (mysqld)
     Status: "Server is operational"
      Tasks: 34 (limit: 1558)
     Memory: 480.7M (peak: 481.1M)
        CPU: 1.090s
     CGroup: /system.slice/mysql.service
             └─56906 /usr/sbin/mysqld
```

## 初始化配置

MySQL 安装后存在默认安全隐患，需执行官方安全脚本优化配置，执行命令：

```bash
sudo mysql_secure_installation
```

执行后会依次出现以下交互选项，按以下建议配置：

```bash{10,18,31,39,58}
Securing the MySQL server deployment.

Connecting to MySQL using a blank password.

VALIDATE PASSWORD COMPONENT can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD component?

Press y|Y for Yes, any other key for No: y

There are three levels of password validation policy:

LOW    Length >= 8
MEDIUM Length >= 8, numeric, mixed case, and special characters
STRONG Length >= 8, numeric, mixed case, special characters and dictionary                  file

Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 1

Skipping password set for root as authentication with auth_socket is used by default.
If you would like to use password authentication instead, this can be done with the "ALTER_USER" command.
See https://dev.mysql.com/doc/refman/8.0/en/alter-user.html#alter-user-password-management for more information.

By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Success.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Success.

By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.

Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done! 
```

- `Press y|Y for Yes, any other key for No`：启用后，MySQL 会强制检查你设置的 root 密码是否符合一定的强度规则（如长度、字符组合等），避免使用弱密码。选择1(MEDIUM)
- `Remove anonymous users`：是否删除匿名用户，建议选 Y，避免未授权访问。
- `Disallow root login remotely`：是否禁止 root 用户远程登录，建议选 Y。
- `Remove test database and access to it`：是否删除测试数据库，建议选 Y，清理无用数据。
- `Reload privilege tables now`：是否立即重新加载权限表，选 Y，使配置生效。
- `Enter password for user root`：输入安装时设置的 root 密码，回车确认。

## 登录 MySQL

初始化完成后，登录 MySQL 验证配置，Ubuntu 通过 apt 安装的 MySQL，默认对 root 用户启用了 `auth_socket` 认证。只需要用系统 `sudo` 权限登录即可，输入任意密码后直接回车。

```bash
sudo mysql -u root -p
```

进入 MySQL 命令行（显示 `mysql>` ），说明登录成功。执行 `show databases;` 可以查看默认数据库，验证服务正常。

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
4 rows in set (0.01 sec)
```

## 配置文件

MySQL 主配置文件为 `/etc/mysql/mysql.conf.d/mysqld.cnf`，运维中常用配置项如下，修改前建议先备份配置文件：

```bash
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
```

使用 vim 编辑配置文件：

```bash
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

常用配置项说明

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

修改完成后，保存退出 vim（按 Esc，输入 `:wq` 回车），重启 MySQL 服务使配置生效：

```bash
sudo systemctl restart mysql
```

## 用户与权限管理

MySQL 中 root 用户权限过高，运维中建议创建专用用户，分配对应权限，避免使用 root 用户直接操作业务数据库。

### 本地完整库权限

```mysql
-- 创建本地账号
CREATE USER 'tom'@'localhost' IDENTIFIED BY 'Aa@620521';
-- 仅 wp_db 所有表完整权限
GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
```

### 远程完整管理账号

```mysql
CREATE USER 'tom'@'%' IDENTIFIED BY '强密码';
GRANT ALL PRIVILEGES ON wp_db.* TO 'tom_db'@'%';
FLUSH PRIVILEGES;
```

### 只读账号

适合查看日志、数据浏览

```mysql
CREATE USER 'read_user'@'localhost' IDENTIFIED BY '密码';
GRANT SELECT ON wp_db.* TO 'read_user'@'localhost';
FLUSH PRIVILEGES;
```

### 远程连接

默认情况下，MySQL 仅允许本地访问，若需远程连接（如通过 Navicat、DBeaver 等工具），需完成以下两步配置。

修改 MySQL 配置文件（允许远程监听）将配置文件中的 `bind-address` 修改为 `0.0.0.0`，重启 MySQL 服务。

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

