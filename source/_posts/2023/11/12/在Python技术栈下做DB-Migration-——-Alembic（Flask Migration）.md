---
title: 在 Python 技术栈下做 DB Migration —— Alembic（Flask Migration）
top: false
cover: false
toc: true
date: 2023-11-12 17:09:13
img:
coverImg:
password:
keywords:
tags:
categories:
---


在 Java 技术栈常用的 DB Migration 工具有 Flyway、Liquibase，可以快速集成在Spring boot中运行。
那在 Python 技术栈中，相似功能的工具有么？自然是有的。
有人编写了 pyliquibase，想要将 liquibase 在 Python中运用，可惜在 github上只有30个star。
我这里比较推荐的是 [Alembic](https://alembic.sqlalchemy.org/en/latest/)，它本身是一个基于 SQLAlchemy（Python下的ORM库，类比Java里的 JPA/Hibernate）的轻量级的DB Migration工具，并且与 Flask 有现成的集成工具包 —— Flask Migration。

当然，它最打动我的功能 —— 是可以从 ORM 的 Model class 自动对比 DB 现有结构，针对差异生成 migration 脚本文件并且版本管理。
这在 Groovy/Grails 时代是非常常见的功能，但是在 Java 的 DB Migration 工具中却并不常见。

以下，是我在 Flask + Flask-SQLAlchemy 中直接使用 Flask-Migration 的过程。
### 安装 Flask-Migration
```
$ pipenv install Flask-Migrate
```

### Flask 应用启动项添加 Migration
下面是一个普通的Flask + Flask-SQLAlchemy 的应用启动项 Demo 代码，使用 Flask-Migration 仅需要添加第3行、8行即可 —— Flask-Migration 可以读取到 SQLAlchemy 和 DB 的配置信息。
```
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate #为使用flask-migrate添加

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'

db = SQLAlchemy(app) #为使用flask-migrate添加

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128))
```

### 初始化 DB Migration 的目录文件结构（Alembic的目录文件结构）
```
$ pipenv run flask db init
```
这时，会在你的项目目录下生成 migration 以下目录结构。
```
yourproject/
    migrations/
        alembic.ini
        env.py
        README
        script.py.mako
        versions/
            3512b954651e_add_account.py
            2b1ae634e5cd_add_order_id.py
            3adcc9a56557_rename_username_field.py
```
DB migration 脚本，就存放在 migrations/versions 文件夹下。

Flask-Migration 将 Alembic 的命令进行了封装，相同的命令在 Alembic 是 `alembic init`。
其他命令基本都如此，因此想要看更详细的命令功能说明，可以查找 Alembic 命令说明。

### 修改配置，为 migration script 添加带时间戳的命名规则
使用 Flyway/Liquibase 习惯了的同学，可能比较喜欢 script 文件名上标记有时间 —— 这样可以一眼明了脚本执行的顺序，而不用打开文件查找可读性差的版本号。如下面截图这样
![vesrions-with-timestamp](./在Python技术栈下做DB-Migration-——-Flask-Migration/version-with-timestamp.png)

只用打开配置文件`script.py.mako`，在相同项下面修改`file_template`即可。
```
[alembic]
# template used to generate migration files
# file_template = %%(rev)s_%%(slug)s
file_template = %%(year)d_%%(month).2d_%%(day).2d_%%(hour).2d%%(minute).2d-%%(rev)s_%%(slug)s
```

### 对比ORM model 和 DB 现有结构，针对差异自动生成 version migration脚本
```
$ pipenv run flask db migrate -m "Initial migration."
```
这时 Flask-Migration 会生成如下这样的迁移脚本。
```
"""Initial migration.

Revision ID: e059cb3579d7
Revises: 
Create Date: 2023-11-01 15:49:13.366391

"""

# revision identifiers, used by Alembic.
revision = 'e059cb3579d7'
down_revision = None
branch_labels = None

from alembic import op
import sqlalchemy as sa

def upgrade():
    op.create_table('account',
    sa.Column('id', sa.BigInteger(), nullable=False),
    sa.Column('username', sa.String(length=50), nullable=False),
    sa.Column('password', sa.String(length=50), nullable=False),
    sa.PrimaryKeyConstraint('id')
    )

def downgrade():
    op.drop_table('account')
```

### 执行 DB migration脚本，进行数据库变更
```
$ pipenv run flask db upgrade <revision>
# 或者降级 pipenv run flask db downgrade <revision>
```
revison 可以是版本号前缀，也可以是 head（最新版本）、+1（相对位置加一）、-x(相对位置减x)。
如果 upgrade 不指定 revision，则默认是 head。
downgrade 不指定 revision，则默认是 -1。

### 不能依赖flask db migrate 生成的情况，需要手动编写迁移upgrade()/downgrade()方法
比如 Account 表格中需要初始化一个system admin record 时，这种无法通过flask db migrate自动生成。
使用命令：
```
$ pipenv run flask db revision 'Init system admin record.'
```
这时会生成一个空的版本脚本文件，其中 upgrade()/downgrade()方法需要程序员使用脚本自行编写。
语法查看[Alembic Operation Reference](https://alembic.sqlalchemy.org/en/latest/ops.html)


**以上日常开发中的基本用法，更多功能探索可以查阅 Alembic official document。**