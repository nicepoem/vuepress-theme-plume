---
date: 2026-06-07T21:07:43.000Z
title: Tomcat
categories:
  - 知识笔记
  - linux
  - 中间件
createTime: 2026/07/10 15:49:47
permalink: /linux/uyarnjur/
---

[参考文章](https://xiexuewu.blog.csdn.net/article/details/155606348)

## 安装

```bash
cd /usr/local
tar -zxvf apache-tomcat-9.0.96.tar.gz
mv apache-tomcat-9.0.96 tomcat9
useradd -s /sbin/nologin tomcat
chown -R tomcat:tomcat /usr/local/tomcat9
```

## 管理与配置

核心目录

```bash
/usr/local/tomcat9
├── bin         #启停脚本
├── conf        #所有配置文件
│   ├─server.xml        #主配置（端口、连接器）
│   ├─web.xml           #全局web应用配置
│   ├─tomcat‑users.xml  #后台管理账号密码
│   └─context.xml
├── webapps     #项目war部署目录
├── logs        #日志
├── temp        #临时文件
└── work        #JSP编译缓存
```

系统服务管理命令

```bash
#启动
systemctl start tomcat
#停止
systemctl stop tomcat
#重启（改配置后必须执行）
systemctl restart tomcat
#查看运行状态
systemctl status tomcat
#开机自启
systemctl enable tomcat
#取消开机自启
systemctl disable tomcat
#重载systemd（修改tomcat.service后必须执行）
systemctl daemon‑reload
```

