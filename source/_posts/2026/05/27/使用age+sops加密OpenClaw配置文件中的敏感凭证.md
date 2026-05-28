---
title: 使用age+sops加密OpenClaw配置文件中的敏感凭证
top: false
cover: true
toc: true
date: 2026-05-27 23:16:32
img:
coverImg:
password:
keywords:
tags:
  - OpenClaw
  - AI Agent
categories:
  - AI Agent
---

## 1. 审计 OpenClaw Agent安装目录中的凭证风险
一键 check OpenClaw 本地保存的 Secrets 。
```
$ openclaw secrets audit --check
```

Output 示例：
```
Secrets audit: findings. plaintext=3, unresolved=0, shadowed=0, legacy=0.
- [PLAINTEXT_FOUND] /root/.openclaw/openclaw.json:gateway.auth.token gateway.auth.token is stored as plaintext.
- [PLAINTEXT_FOUND] /root/.openclaw/openclaw.json:plugins.entries.minimax.config.webSearch.apiKey plugins.entries.minimax.config.webSearch.apiKey is stored as plaintext.
- [PLAINTEXT_FOUND] /root/.openclaw/agents/main/agent/auth-profiles.json:profiles.minimax:cn.key Auth profile API key is stored as plaintext.
```
{% note warning %}
需要注意：plaintext 形式的 gateway.auth.token 无法使用本文的方式迁移。
博主迁移 gateway token 后出现 gateway 启动异常，如果是仅回环地址访问，这个 token 的安全级别并不是特别重要，于是暂时没深究。
{% endnote %}

## 2. 使用 age + sops 进行本地秘钥文件加解密 
### 2.1 预先安装 age + sops
```shell
# linux apt 安装 age
$ sudo apt install age
# curl 拉取 sops 包，访问 github repo 选择合适的 release 版本
$ curl -LO https://github.com/getsops/sops/releases/download/v3.13.1/sops-v3.13.1.linux.amd64
$ sudo mv sops-v3.13.1.linux.amd64 /usr/local/bin/sops
$ sudo chmod +x /usr/local/bin/sops
```

### 2.2 配置 age + sops
```shell
$ mkdir -p ~/.config/sops/age
# 使用 age 生成主密钥对
$ age-keygen -o ~/.config/sops/age/keys.txt
# 控制密钥文件的权限
$ chmod 600 ~/.config/sops/age/keys.txt

# 配置环境变量，给 sops 解密时查找私钥使用
$ echo 'export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"' >> ~/.bashrc
$ source ~/.bashrc
```

进入 ~/.openclaw 目录，创建项目的 sops 规则文件 `.sops.yaml`：
```shell
$ cat > .sops.yaml << EOF
creation_rules:
    - path_regex: \.enc\.(yaml|json|env)$
      age: $(cat ~/.config/sops/age/keys.txt | grep -oE "age1[^\s]+")
EOF
```

创建和编辑（加密的）secrets.enc.json 文件：
```shell
$ sops secrets.enc.json
# 控制 secrets 文件的权限
$ chmod 600 *.enc.json
```

## 3. 在 OpenClaw 进行集成配置
使用OpenClaw 的 keyRef 机制（选项env/file/exec三种可选策略），为了与sops集成选择 `exec`策略。可见[Openclaw官方链接](https://docs.openclaw.ai/gateway/secrets/#exec-integration-examples)

### 3.1 在 secrets.enc.json 中配置 OpenClaw 
记得使用 sops 指令进行操作：
```json
{
    "models": {
        "providers": {
            "minimax": {
                "apiKey": "sk-cp-xxx"
            }
        }
    },
    "feishu": {
        "appSecret": "xxx"
    }
}
```

### 3.2 验证 secrets.enc.json 是否合格
```shell
$ sops -d --extract '["models"]["providers"]["minimax"]["apiKey"]' /root/.openclaw/secrets.enc.json
```


### 3.3 使用 openclaw secrets configure 命令进行配置
`openclaw secrets configure --allow-exec`提供了命令交互式，引导对敏感凭证配置的变更。
```shell
🦞 OpenClaw 2026.5.4 (325df3e) — Give me a workspace and I'll give you fewer tabs, fewer toggles, and more oxygen.

│
◇  Configure secret providers (only env refs are available until file/exec providers are added)
│  Add provider
│
◇  Provider source
│  exec
│
◇  Provider alias
│  sops-minimax
│
◇  Command path (absolute)
│  /usr/local/bin/sops
│
◇  Args JSON array (blank for none)
│  ["-d", "--extract", "[\"models\"][\"providers\"][\"minimax\"][\"apiKey\"]", "/root/.openclaw/secrets.enc.json"]
│
◇  Timeout ms (blank for default)
│  5000
│
◇  No-output timeout ms (blank for default)
│  5000
│
◇  Max output bytes (blank for default)
│
│
◇  Require JSON-only response?
│  No
│
◇  Pass-through env vars (comma-separated, blank for none)
│  SOPS_AGE_KEY_FILE,HOME
│
◇  Trusted dirs (comma-separated absolute paths, blank for none)
│  /usr/local/bin
│
◇  Allow insecure command path checks?
│  No
│
◇  Allow symlink command path?
│  No
│
◇  Configure secret providers
│  Continue
│
◇  Select credential field
│  profiles.minimax:cn.key (auth profile, agent main)
│
◇  Secret source
│  exec
│
◇  Provider alias
│  sops-minimax
│
◇  Secret id
│  value
│
◇  Configure another credential?
│  No
Preflight: changed=true, files=1, warnings=0.
Plan: targets=1, providerUpserts=1, providerDeletes=0.
│
◇  Apply this plan now?
│  Yes
Secrets applied. Updated 1 file(s).
```

### 3.4 验证配置
用 `openclaw secrets audit --allow-exec` 看看能不能正常解析 secret。

成功示例：
```Shell
🦞 OpenClaw 2026.5.4 (325df3e) — I've read more man pages than any human should—so you don't have to.

Secrets audit: clean. plaintext=0, unresolved=0, shadowed=0, legacy=0.
```

失败示例：
```shell
🦞 OpenClaw 2026.5.4 (325df3e) — I'm the middleware between your ambition and your attention span.

Secrets audit: unresolved. plaintext=1, unresolved=2, shadowed=0, legacy=0.
……
- [REF_UNRESOLVED] /root/.openclaw/agents/main/agent/auth-profiles.json:profiles.minimax:cn.key Failed to resolve exec:sops:models/providers/minimax/apiKey (Exec provider "sops" exited with
 code 2.).
……

```

**查看原先的配置位置（比如 ~/.openclaw/agents/main/agent/auth-profiles.json）**
```json
{
  "version": 1,
  "profiles": {
    "minimax:cn": {
      "type": "api_key",
      "provider": "minimax",
      "keyRef": {
        "source": "exec",
        "provider": "sops-minimax",
        "id": "value"
      }
    }
  }
}
```

### 3.5 最后一步，重启 gateway
重启后，验证是否有效
```
$ openclaw gateway restart
```