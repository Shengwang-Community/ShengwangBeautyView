# 模板列表

本文档记录所有可用模板的名称与中英文对照，供 Agent 在帮用户裁剪素材包、修改 UI 列表时使用。

## 说明

- `模板名（templateName）`：传入 `addOrUpdateVideoEffect` 的字符串参数
- 贴纸分动态款和静态款（`-Lite` 后缀），中英文名相同，静态款性能消耗更低，适合低端机
- 裁剪素材包后，代码中的模板列表需同步更新，只保留实际存在的模板

---

## 如何从素材包读取实际可用模板

客户拿到的素材包可能已经过裁剪，实际可用模板以素材包内的 `config.json` 为准。

### 素材包路径

素材包有两种形式：

- **Bundle（已解压）**：`AgoraBeautyMaterial.bundle/`
- **Zip（需先解压）**：`AgoraBeautyMaterial.zip` → 解压后同上

解压后，根据加密状态进入对应目录：

| 目录名 | 说明 |
|--------|------|
| `beauty_material_functional/` | 非加密素材包 |
| `beauty_material_encrypted/` | 加密素材包 |

目标文件：`<上述目录>/config.json`

> ⚠️ 当素材包在加密（`beauty_material_encrypted`）和非加密（`beauty_material_functional`）之间切换时，需要同步更新代码中的目录名：
> - Android：`BeautyMainActivity.kt` 中的 `FUNCTIONAL` 常量
> - iOS：`ShengwangBeautySDK` 会自动优先检测 `beauty_material_encrypted`，其次 `beauty_material_functional`，无需手动修改

### config.json 结构

```json
{
  "user_interface_option": {
    "Makeup-Natural": "stylemakeup_baixi/",
    "Makeup-Aura":    "stylemakeup_qizhi/",
    ...
  },
  "beauty_config": "Beauty-Basic"
}
```

- `user_interface_option` 的 **key** 即为实际可用的风格妆/贴纸/滤镜模板名
- `beauty_config` 为当前使用的美颜模板名
- **config.json 中没有出现的模板，说明已被裁剪，UI 中对应 item 需删除**

### 根据 config.json 更新 UI 的规则

1. 读取 `user_interface_option` 的所有 key，得到实际可用模板列表
2. 按模板名前缀判断类型：
   - `Beauty-` 开头 → 美颜 tab
   - `Makeup-Custom` → 自定义美妆 tab（默认加载，不需要按素材包裁剪 UI 选项）
   - `Makeup-` 开头（非 Custom）→ 风格妆 tab
   - `Sticker-` 开头 → 贴纸 tab
   - `Filter-` 开头 → 滤镜 tab
3. 某类型的模板全部不存在于 `user_interface_option` → 整个 tab 删除（自定义美妆除外，见下方校验规则）
4. 某类型只保留了部分 → 只保留 config.json 中出现的 item，其余删除
5. Android、iOS 和 Flutter 需同步修改
6. **风格妆校验**：如果用户要风格妆，但 `user_interface_option` 中没有任何 `Makeup-` 前缀（排除 `Makeup-Custom`）的模板 → 告知用户素材包打包不正确，缺少风格妆模板
7. **自定义美妆校验**：如果用户明确要自定义美妆，但 `user_interface_option` 中没有 `Makeup-Custom`，或 `makeup_config` 未设置为 `Makeup-Custom` → 告知用户素材包打包不正确
5. 美颜 tab 的特殊处理：
   - `user_interface_option` 中没有任何 `Beauty-*` → 美颜 tab 删除
   - 有一个 `Beauty-*` → 直接使用该模板
   - 有多个 `Beauty-*` → 以 `beauty_config` 的值为准，其余忽略（设计上不支持多模板切换）

### 示例

假设 `user_interface_option` 只有以下内容：

```json
{
  "Makeup-Natural": "...",
  "Makeup-Aura": "...",
  "Sticker-Christmas": "..."
}
```

则 UI 应调整为：
- 美颜 tab：保留（不受影响）
- 风格妆 tab：只保留 `Makeup-Natural`、`Makeup-Aura` 两项
- 贴纸 tab：只保留 `Sticker-Christmas` 一项
- 滤镜 tab：**整个删除**（config.json 中无任何 `Filter-` 模板）

---

## 美颜模板（Beauty）

| 模板名 | 中文名 |
|--------|--------|
| `Beauty-Basic` | 模板-通用 |
| `Beauty-Ordinary` | 模板-素人 |
| `Beauty-Anchor` | 模板-主播 |
| `Beauty-Show` | 模板-秀场 |

> 美颜模板决定各参数的初始默认值，通常选一个作为默认即可，不需要让用户切换。

---

## 自定义美妆模板（Custom Makeup）

| 模板名 | 说明 |
|--------|------|
| `Makeup-Custom` | 自定义美妆（需在 config.json 的 `user_interface_option` 中存在，且 `makeup_config` 配置为 `Makeup-Custom`） |

> **判断逻辑**：
> - 用户不说"自定义美妆"时，默认按风格妆走，不涉及此模板
> - 用户明确要"自定义美妆"时，需检查 config.json：
>   1. `user_interface_option` 中是否有 `Makeup-Custom` key
>   2. `makeup_config` 是否设置为 `Makeup-Custom`
>   - 任一条件不满足 → 告知用户素材包打包不正确
> - 自定义美妆对应 `CustomMakeupPageBuilder`，内部全是逐项调参（唇妆/腮红/修容/眼影/眉毛/睫毛/美瞳），不需要像风格妆那样按模板名裁剪 UI 选项

---

## 风格妆模板（Style Makeup）

| 模板名 | 中文名 | 英文名 |
|--------|--------|--------|
| `Makeup-Natural` | 白皙妆 | natural |
| `Makeup-Charm` | 粉晕妆 | charm |
| `Makeup-Perkey` | 俏皮妆 | perky |
| `Makeup-Aura` | 气质妆 | aura |
| `Makeup-Maiden` | 少女妆 | maiden |
| `Makeup-Mature` | 学姐妆 | mature |
| `Makeup-Young` | 学妹妆 | young |
| `Makeup-Misty` | 氤氲妆 | misty |
| `Makeup-Insight` | 深邃妆 | insight |
| `Makeup-Graceful` | 优雅妆 | graceful |

---

## 贴纸模板（Sticker）

动态款与静态款（`-Lite`）中英文名相同，静态款适合低端机或对性能敏感的场景。

| 模板名 | 中文名 | 英文名 |
|--------|--------|--------|
| `Sticker-Christmas` | 圣诞节 | christmas |
| `Sticker-Christmas-Lite` | 圣诞节（静态） | christmas |
| `Sticker-Squid` | 章鱼 | squid |
| `Sticker-Squid-Lite` | 章鱼（静态） | squid |
| `Sticker-Piggy` | 猪可爱 | piggy |
| `Sticker-Piggy-Lite` | 猪可爱（静态） | piggy |
| `Sticker-Longcat` | 辫子猫 | longcat |
| `Sticker-Longcat-Lite` | 辫子猫（静态） | longcat |
| `Sticker-Hairhoop` | 粉色发箍 | hairhoop |
| `Sticker-Hairhoop-Lite` | 粉色发箍（静态） | hairhoop |
| `Sticker-Relax` | 没有烦恼 | relaxtime |
| `Sticker-Relax-Lite` | 没有烦恼（静态） | relaxtime |
| `Sticker-Cartooncat` | 卡通猫 | cartooncat |
| `Sticker-Cartooncat-Lite` | 卡通猫（静态） | cartooncat |
| `Sticker-Butterfly` | 蝴蝶 | butterfly |
| `Sticker-Butterfly-Lite` | 蝴蝶（静态） | butterfly |
| `Sticker-Brush` | 粉刷时光 | brush |
| `Sticker-Brush-Lite` | 粉刷时光（静态） | brush |
| `Sticker-Glass` | 赛博眼镜 | cyberglass |
| `Sticker-Glass-Lite` | 赛博眼镜（静态） | cyberglass |
| `Sticker-Tiara` | 霓虹皇冠 | neontiara |
| `Sticker-Tiara-Lite` | 霓虹皇冠（静态） | neontiara |
| `Sticker-Love` | 爱心眼镜 | loveglass |
| `Sticker-Love-Lite` | 爱心眼镜（静态） | loveglass |

---

## 滤镜模板（Filter）

### 暖色系

| 模板名 | 中文名 | 英文名 |
|--------|--------|--------|
| `Filter-Serene` | 沉稳 | serene |
| `Filter-Urban` | 都市 | urban |
| `Filter-Gilt` | 鎏金 | gilt |
| `Filter-Glow` | 流光 | glow |
| `Filter-Cream` | 奶油 | cream |
| `Filter-Summer` | 柠夏 | summer |
| `Filter-Latte` | 拿铁 | latte |
| `Filter-Daily` | 日常 | daily |
| `Filter-Gentleman` | 绅士 | gentleman |
| `Filter-Vanilla` | 香草 | vanilla |
| `Filter-Bright` | 白瓷 | bright |

### 冷色系

| 模板名 | 中文名 | 英文名 |
|--------|--------|--------|
| `Filter-Peach` | 白桃 | peach |
| `Filter-Ink` | 苍墨 | ink |
| `Filter-Film` | 胶片 | film |
| `Filter-Sunny` | 霁晴 | sunny |
| `Filter-Comic` | 漫画 | comic |
| `Filter-Dreamy` | 梦幻 | dreamy |
| `Filter-Cotton` | 棉绒 | cotton |
| `Filter-Soda` | 苏打 | soda |
| `Filter-Moonlight` | 月白 | moonlight |
| `Filter-Whitetea` | 白茶 | WhiteTea |

### 氛围系

| 模板名 | 中文名 | 英文名 |
|--------|--------|--------|
| `Filter-Tranquil` | 沉谧 | tranquil |
| `Filter-Ins` | ins风 | insta-style |
| `Filter-Street` | 老街 | street |
| `Filter-Puff` | 泡芙 | puff |
| `Filter-Collection` | 私藏 | collection |
| `Filter-Salty` | 盐汽水 | salty |
| `Filter-Texture` | 质感 | texture |
| `Filter-Colorful` | 气色 | colorful |
| `Filter-Snow` | 初雪 | snow |

### 环境系

| 模板名 | 中文名 | 英文名 |
|--------|--------|--------|
| `Filter-Blush` | 粉霞 | blush |
| `Filter-Nostalgia` | 怀旧 | nostalgia |
| `Filter-Caramel` | 焦糖 | caramel |
| `Filter-Tipsy` | 微醺 | tipsy |
| `Filter-Lavender` | 薰衣草 | lavender |
| `Filter-Rouge` | 胭脂 | rouge |
| `Filter-Misty` | 氤氲 | misty |
