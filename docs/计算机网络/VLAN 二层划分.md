---
title:  VLAN二层划分
createTime: 2026/07/23 22:42:05
permalink: /计算机网络/mjoouvkk/
---
## 实验目的

1. 掌握华为交换机VLAN创建、Access接入端口、Trunk级联端口配置命令。
2. 实现分组通信：PC1与PC2互通、PC3与PC4互通，VLAN10与VLAN20二层完全隔离。
3. 理解Trunk干道作用，实现跨交换机同VLAN终端正常转发。
4. 学会使用display系列命令排查VLAN配置故障。

## 实验拓扑

组网设备：华为二层交换机LSW1、LSW2，PC1~PC4。
- LSW1 GE0/0/1连接PC1；LSW1 GE0/0/2连接PC2；LSW1 GE0/0/3对接LSW2 GE0/0/3
- LSW2 GE0/0/1连接PC3；LSW2 GE0/0/2连接PC4；LSW2 GE0/0/3对接LSW1 GE0/0/3

## 软硬件环境

- 仿真软件：eNSP/PC Simulator
- 设备型号：华为S5700系列交换机
- 操作系统：Windows PC模拟器

![](https://cdn.jsdelivr.net/gh/nicepoem/static/images/20260813181805738.png)

## 地址与VLAN规划

### 2.1 IP地址规划

子网掩码统一：255.255.255.0，网关统一配置192.168.100.254（二层通信网关无影响）

| 终端设备 | IP地址 | 所属VLAN | 接入交换机 | 接入端口 |
| ---- | ---- | ---- | ---- | ---- |
| PC1 | 192.168.100.5 | VLAN 10 | LSW1 | GE 0/0/1 |
| PC2 | 192.168.100.6 | VLAN 10 | LSW1 | GE 0/0/2 |
| PC3 | 192.168.100.7 | VLAN 20 | LSW2 | GE 0/0/1 |
| PC4 | 192.168.100.8 | VLAN 20 | LSW2 | GE 0/0/2 |

### 2.2 端口模式规划
1. 接PC端口：Access模式，仅归属单个业务VLAN
2. 交换机互联端口GE0/0/3：Trunk模式，放行VLAN10、VLAN20，承载多VLAN带标签流量

## 3 完整设备配置

### 3.1 LSW1（S1）配置命令

```bash
# 进入系统视图，重命名设备
system-view
sysname LSW1

# 批量创建VLAN10、VLAN20
vlan batch 10 20

# 配置PC1接入口GE0/0/1
interface GigabitEthernet 0/0/1
	port link-type access
	port default vlan 10
	undo shutdown

# 配置PC2接入口GE0/0/2
interface GigabitEthernet 0/0/2
 	port link-type access
 	port default vlan 10
 	undo shutdown

# 配置交换机互联Trunk口GE0/0/3
interface GigabitEthernet 0/0/3
	port link-type trunk
 	port trunk allow-pass vlan 10 20
 	undo shutdown

# 保存配置
save
```



### 3.2 LSW2（S2）配置命令
```bash
# 进入系统视图，重命名设备
system-view
sysname LSW2

# 创建所需VLAN
vlan batch 10 20

# PC3接入端口配置
interface GigabitEthernet 0/0/1
	port link-type access
	port default vlan 20
    undo shutdown

# PC4接入端口配置
interface GigabitEthernet 0/0/2
    port link-type access
    port default vlan 20
    undo shutdown

# 互联Trunk端口配置
interface GigabitEthernet 0/0/3
    port link-type trunk
    port trunk allow-pass vlan 10 20
    undo shutdown

save
```

### 3.3 PC终端静态IP配置表

| 设备 | IPv4地址 | 子网掩码 | 网关 |
| ---- | ---- | ---- | ---- |
| PC1 | 192.168.100.5 | 255.255.255.0 | 192.168.100.254 |
| PC2 | 192.168.100.6 | 255.255.255.0 | 192.168.100.254 |
| PC3 | 192.168.100.7 | 255.255.255.0 | 192.168.100.254 |
| PC4 | 192.168.100.8 | 255.255.255.0 | 192.168.100.254 |

## 4 配置核验命令与结果
### 4.1 核验常用命令
```
display port vlan
display vlan brief
display interface brief
display current-configuration interface GigabitEthernet 0/0/3
```

### 4.2 最终核验结果（现场回显）
#### LSW1端口VLAN表
| 端口 | 链路类型 | PVID | 允许VLAN |
| ---- | ---- | ---- | ---- |
| GE0/0/1 | access | 10 | 仅VLAN10 |
| GE0/0/2 | access | 10 | 仅VLAN10 |
| GE0/0/3 | trunk | 1 | 1、10、20 |

#### LSW2端口VLAN表
| 端口 | 链路类型 | PVID | 允许VLAN |
| ---- | ---- | ---- | ---- |
| GE0/0/1 | access | 20 | 仅VLAN20 |
| GE0/0/2 | access | 20 | 仅VLAN20 |
| GE0/0/3 | trunk | 1 | 1、10、20 |

优化建议：两台交换机Trunk口删除默认VLAN1放行

```bash
interface GigabitEthernet 0/0/3
undo port trunk allow-pass vlan 1
port trunk allow-pass vlan 10 20
```



## 5 连通性测试
### 5.1 测试对照表
| 测试源 | 测试目的 | 预期结果 | 实际测试结果 |
| ---- | ---- | ---- | ---- |
| PC1(192.168.100.5) | PC2(192.168.100.6) | 互通 | 正常连通，0丢包 |
| PC1(192.168.100.5) | PC3(192.168.100.7) | 隔离不通 | 目的主机不可达，100%丢包 |
| PC1(192.168.100.5) | PC4(192.168.100.8) | 隔离不通 | 目的主机不可达，100%丢包 |
| PC3(192.168.100.7) | PC4(192.168.100.8) | 互通 | 正常连通，0丢包 |
| PC2 | PC3、PC4 | 隔离不通 | 全部ping失败 |

### 5.2 测试日志节选
```bash
PC>ping 192.168.100.6
Ping正常连通，无丢包
PC>ping 192.168.100.7
目标主机不可达，全部丢包
PC>ping 192.168.100.8
目标主机不可达，全部丢包
```

## 6 故障排查记录
### 6.1 初期故障1：PC1无法ping通PC2
原因：LSW1 GE0/0/1只配置access，未配置port default vlan 10，端口默认属于VLAN1，两台终端跨VLAN隔离。
解决：Access端口必须手动指定归属VLAN。

### 6.2 初期故障2：Trunk只放行VLAN1
原因：GE0/0/3默认Trunk仅允许VLAN1，VLAN10、20跨交换机无法转发。
解决：Trunk端口手动放行业务VLAN。

### 6.3 异常现象：PC1曾意外连通PC3
原因：端口VLAN配置颠倒，PC1被划入VLAN20；修正端口VLAN归属后，隔离恢复正常。

## 7 实验原理总结
1. VLAN切割二层广播域，不同VLAN二层天然隔离，哪怕IP网段一致也无法互通。
2. Access端口：接入终端，仅承载一个VLAN；Trunk端口：交换机级联，可同时携带多个VLAN标签。
3. 跨交换机同VLAN通信依靠Trunk转发带VLAN标签的数据帧。
4. 若需要VLAN10和VLAN20互相访问，必须借助三层设备（三层交换机VLANIF/路由器单臂路由）做路由转发。

## 8 实验心得
1. Access端口必须配置port default vlan，否则端口默认在VLAN1。
2. Trunk端口需要按需放行VLAN，不能依赖默认配置。
3. display port vlan是VLAN排错最高效命令，可快速查看端口模式、PVID、允许VLAN清单。
4. 网段相同不等于可以互通，VLAN是二层隔离核心手段。