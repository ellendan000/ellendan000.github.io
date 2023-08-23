---
title: Markdown 书写方式
date: 2016-07-15 01:35:00  
tags: 
    - 轻量型文档
categories: 
    - 轻量型文档
---

1. 斜体  
    `_content_`

2. 粗体  
    `**content**`

3. header  
    `#(number) 代表header number`
```
###This is header 3.
```

4. 链接  
    `[text context](url)`
```
[Search for it.](www.google.com)
[You're *really, really* going to want to see this](www.dailykitten.com).
```

5. 图片  
    `![text](url)`
```
![A Catburn](http://octodex.github.com/images/octdrey-catburn.jpg)
```

6. reference   
>Do you want to [see something fun][a fun place]?
>Well, do I have [the website for you][another fun place]!
>[a fun place]: www.zombo.com
>[another fun place]: www.stumbleupon.com  
>
>![The first father][First Father]
>![The second first father][Second Father]
>[First Father]: http://octodex.github.com/images/founding-father.jpg
>[Second Father]: http://octodex.github.com/images/foundingfather_v2.png

7. Blockquotes  

    `> paragraph `  

8. 列表  
    无序列表 `* content`  
    有序列表 `1. content`  
    嵌套列表 `<空格>* content`  

9. 换行  
    hard（间距大） 空一行  
    soft（间距小） 结尾用两个空格  

10. 画表格
```
| Number     | Next number | Previous number |
| :--------- |:----------- | :-------------- |
| Five       | Six         | Four            |
| Ten        | Eleven      | Nine            |
| Seven      | Eight       | Six             |
| Two        | Three       | One             |
```

11. 代码书写

~~~
    ```
    code
    ```
~~~

或者

```
    ~~~
    code
    ~~~
```

详情可见[markdown tutorial](http://www.markdowntutorial.com/)
