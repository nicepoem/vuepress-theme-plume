---
title: chmod
createTime: 2026/07/10 15:49:47
permalink: /linux/d2u6zhun/
---
# chmod

Linux 文件权限修改专属命令，用于变更文件、目录的读写执行权限，管控用户访问权限，保障系统安全。

- who：u(所有者)，g(组)，o(其他人)，a(所有人)
- operator：+(添加权限)，-(移除权限)，=(设置精确权限)
- permissions：r(读)，w(写)，x(执行)

### 英文全拼

```
chmod = change mode
```

## 语法格式

```bash
chmod 755 test.sh
chmod 777 test.log   # 全开权限（测试用）
# 语法：chmod [who][operator][permissions] file

# 为所有者添加执行权限
chmod u+x script.sh

# 为所有者和组添加写入权限
chmod ug+w config.json

# 移除其他用户的所有权限
chmod o-rwx sensitive_data.txt

# 为所有用户设置相同的权限
chmod a=r README.md

```

