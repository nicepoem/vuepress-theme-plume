---
title: php
createTime: 2026/08/10 18:21:42
permalink: /linux/gqvpqcat/
---
# php

## 系统环境

- ubuntu 26.04 桌面版本
- PHP版本 8.5.4

## 安装

更新系统软件包

```bash
sudo apt update && sudo apt upgrade -y
```

搜索可用的PHP版本

```bash
apt search php | grep -E "^php[0-9]+\.[0-9]+/"
```

安装PHP

```bash
sudo apt install -y php php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip
```

查看PHP版本

```bash
php -v
```

安装后，PHP-FPM 会自动启动，服务名通常是 `php8.5-fpm`。检查其状态：

```
sudo systemctl status php8.5-fpm
```

状态预览

```bash{3}

● php8.5-fpm.service - The PHP 8.5 FastCGI Process Manager
     Loaded: loaded (/usr/lib/systemd/system/php8.5-fpm.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-08-10 18:21:26 CST; 5min ago
 Invocation: 0c54ab73c3f6429bb601b95ed6291881
       Docs: man:php-fpm8.5(8)
    Process: 70304 ExecStartPost=/usr/lib/php/php-fpm-socket-helper install /run/php/php-fpm.sock /etc/php/8.5/fpm/pool.d/www.conf 85 (code=exited, status=0>
   Main PID: 70300 (php-fpm8.5)
     Status: "Processes active: 0, idle: 2, Requests: 0, slow: 0, Traffic: 0.00req/sec"
      Tasks: 3 (limit: 1558)
     Memory: 11.3M (peak: 13M)
        CPU: 72ms
     CGroup: /system.slice/php8.5-fpm.service
             ├─70300 "php-fpm: master process (/etc/php/8.5/fpm/php-fpm.conf)"
             ├─70302 "php-fpm: pool www"
             └─70303 "php-fpm: pool www"
```

