---
title: 库/表的创建和删除
createTime: 2026/08/25 00:50:48
permalink: /mysql/hkomfc9c/
---

## 创建数据库

```sql
CREATE DATABASE <数据库名>

#　创建一个名为 student 的数据库
CREATE DATABASE student
```

## 删除数据库

```sql
DROP DATABASE <数据库名> 

# 删除名为 student 的数据库 
DROP DATABASE student
```

## 修改数据库名称

```sql
ALTER DATABASE <数据库名> 

# 把名为 student 的数据库重命名为 teacher 
ALTER DATABASE teacher 
```

## 创建数据表

```sql
CREATE TABLE <表名> 

# 创建一张名为 student 的数据库
CREATE TABLE student 
```

## 删除数据表

```sql
DROP TABLE <表名> 

# 删除名为 student 的数据库 
DROP TABLE student
```

| 关键字   | 说明                                                       |
| -------- | ---------------------------------------------------------- |
| SELECT   | 指定要显示数据的列                                         |
| FROM     | 指定查询对象（基本表或视图）                               |
| WHERE    | 指定查询条件                                               |
| GROUP BY | 对查询结果按指定列的值分类，该属性列值相等的元组作为一个组 |
| HAVING   | 筛选出只满足条件的组                                       |
| ORDER BY | 对查询结果表按指定列值的升序或降序排列                     |
