---
title: chown
createTime: 2026/08/24 01:19:31
permalink: /linux/8z72h7vj/
---
chown‌‌‌（Change⁢ ⁢O⁢wner）؜命令؜用于؜修改文⁢件或目⁢录的所⁢有‌者和所属‌组：

## 英文全拼

## 语法格式

```bash
# 只更改所有者
chown yupi file.txt

# 同时更改所有者和组
chown yupi:developers file.txt

# 只更改组（也可以用chgrp）
chown :developers file.txt

# 递归更改目录及其内容
chown -R yupi:developers project/

```

