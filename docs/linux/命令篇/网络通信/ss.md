---
title: ss
createTime: 2026/07/10 15:49:47
permalink: /linux/gxqm779g/
---
# ss
查看端口占用


## 英文全拼

```
ss = Socket Statistics，套接字状态统计命令
```

## 语法格式

```bash
ss -tulpn                 # 查看所有监听端口
ss -tulpn | grep 8080     # 查看8080端口是否被占用
```

