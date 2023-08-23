---
title: MongoDB 查询语句
date: 2017-02-17 17:40:00  
tags: 
    - MongoDB
    - NoSQL
categories: 
    - NoSQL  
---

[Get Started](https://docs.mongodb.com/getting-started/shell/)  
[Official Manual](https://docs.mongodb.com/manual/)

借用官网的例子数据：db.inventory
```
{ item: "journal", qty: 25, status: "A", size: { h: 14, w: 21, uom: "cm" }, tags: ["blank", "red"], dim_cm: [ 14, 21 ] }
{ item: "notebook", qty: 50, status: "A", size: { h: 8.5, w: 11, uom: "in" }, tags: ["red", "blank"], dim_cm: [ 14, 21 ] }
{ item: "paper", qty: 100, status: "D", size: { h: 8.5, w: 11, uom: "in" }, tags: ["red", "blank", "plain"], dim_cm: [ 14, 21 ] }
{ item: "planner", qty: 75, status: "D", size: { h: 22.85, w: 30, uom: "cm" }, tags: ["blank", "red"], dim_cm: [ 22.85, 30 ] }
{ item: "postcard", qty: 45,  status: "A", size: { h: 10, w: 15.25, uom: "cm" }, tags: ["blue"], dim_cm: [ 10, 15.25 ] }
```
#### 查找所有：
```
db.inventory.find( {} )
```

#### 简单匹配普通属性：
```
db.inventory.find( { status: "D" } )
```
使用操作符匹配普通属性：
```
db.inventory.find( { status: { $in: [ "A", "D" ] } } )
```
多个属性匹配，之间是且的关系：
```
db.inventory.find( { status: "A", qty: { $lt: 30 } } )
```
或的关系需要另加操作符：
```
db.inventory.find( { $or: [ { status: "A" }, { qty: { $lt: 30 } } ] } )
```
且 和 或 共同使用的时：  
```
db.inventory.find( {  
    status: "A",  
    $or: [ { qty: { $lt: 30 } }, { item: /^p/ } ]  } )
```
#### 查找，数组/对象属性中有满足匹配的子项
```
db.inventory.find( { tags: "red" } )
db.inventory.find( { "size.uom": "in" } )
```
数组/对象完全匹配查找（子项顺序必须完全相同，不然匹配不到）
```
db.inventory.find( { size: { h: 14, w: 21, uom: "cm" } } )
db.inventory.find( { tags: ["red", "blank"] } )
```
#### 匹配数组时注意：默认多元素子项可分摊匹配
```
db.inventory.find( { dim_cm: { $gt: 15, $lt: 20 } } )
```
> The following example queries for documents where the dim_cm array contains elements that in some combination satisfy the query conditions; e.g., one element can satisfy the greater than 15 condition and another element can satisfy the less than 20 condition, or a single element can satisfy both.  

#### 匹配数组：期望元素子项内匹配
  ```
  db.inventory.find( { dim_cm: { $elemMatch: { $gt: 22, $lt: 30 } } } )
  ```
>The following example queries for documents where the dim_cm array contains at least one element that is both greater than ($gt) 22 and less than ($lt) 30.

#### 匹配数组可以用索引（索引从0开始）
```
db.inventory.find( { "dim_cm.1": { $gt: 25 } } )
```
#### 匹配数组，可以多元素捆绑匹配
```
db.inventory.find( { tags: { $all: ["red", "blank"] } } )
```
同（既包含'red', 也包含'blank'的）：
```
db.inventory.find({ $and: [ { tags: "red" }, { tags: "blank" } ] })
```