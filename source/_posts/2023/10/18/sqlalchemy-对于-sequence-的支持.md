---
title: sqlalchemy 对于 sequence 的支持
top: false
cover: false
toc: false
date: 2023-10-18 15:16:52
img:
coverImg:
password:
keywords:
tags:
    - python
categories:
    - python
---

sqlalchemy 对于 sequence 的支持（底层数据库引擎必须具有 sequence 功能），具有简单易用性。
比如下面这个例子：
假设创建不同类型的 World 时，需要一个序列码，此序列码单类型内唯一。

```
import pinyin
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy_serializer import SerializerMixin
from sqlalchemy import String, BigInteger, Sequence

db = SQLAlchemy()

@dataclass
class World(db.Model, SerializerMixin):
    __tablename__ = 'world'
    id = db.Column(BigInteger, primary_key=True)
    serial_number = db.Column(String(32), nullable=False)

    @staticmethod
    def create(world_category_id):
        world_category = WorldCategory.get(world_category_id)
        style_pinyin = pinyin.get(world_category.style, format="strip")
        sequence = Sequence(style_pinyin, start=1)
        seq_ddl = CreateSequence(sequence, if_not_exists=True)
        session = db.session
        session.execute(seq_ddl)

        next_value = session.scalar(sequence)
        world = World(world_category_id=world_category_id, serial_number=next_value)
        session.add(world)
        session.commit()
        return world
```
也正如上面所说，对于不支持 Sequence 的数据库，此段代码并不能生效。

有时候，反思一下业务，是否真的需要连续性的序列码？其实，序列码的初衷是唯一性，使用 Sequence 来实现，由于其连续和记数性，
反而会造成一些业务上统计数据的泄露，并且给技术上 hack API 和 数据带来便捷。
因此，是否使用 Sequence 视情况而定。
如序列码这样的生成，可以接受数字、字符规则的，可以使用 UUID，仅能接受数字的，可以使用 snowflake 算法。

