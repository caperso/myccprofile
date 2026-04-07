# 创建 Jira Story

创建 CTRIP 的 Jira Story

## 使用方式

`/jira-story <标题>`

## 执行步骤

1. 首先在终端上执行：`source ~/.zprofile`
2. 标题是 "FE: " 开头
3. 全部使用英文内容描述
4. 描述开头使用："As a developer, I want"
5. 请根据标题大致填补 story 的内容描述和验收标准
6. 添加 story point，值为 1，字段 id 10004
7. 这个 story 的 parent 是 "Ancillary BAU 2025"，请找到这个 parent story
8. 创建完成后：
   - 将 story labels 增加 frontend 和 Tech
   - 将 story team 改为 Vesta：
     - team 字段 id 为：13600
     - 如果你知道 Vesta 的 team id：`ari:cloud:identity::team/3d4924ca-6d08-44d3-9ea2-892807bea4eb`
     - 如果不知道 team id：帮我找到这个 team
9. 最后返回给我这个 story url