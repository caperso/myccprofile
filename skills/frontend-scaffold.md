---
name: frontend-scaffold
description: origami-trip 项目前端代码编排脚手架。当用户需要新增组件、容器、selector、helpers，或询问"新文件放哪"、"XX 属于哪个 domain"、"怎么组织 types/constants/index"、"怎么编排单测/storybook"时触发。覆盖：domain 归属判定、组件/容器标准目录结构、文件命名（types.tsx / constants.tsx / index.tsx / __tests__ / __stories__ / __mocks__ / helpers/）、index.tsx 导出约定、单测与 storybook 编排规范。
type: skill
---

# Frontend Scaffold Skill (origami-trip)

- 用于在 名字中**包含** `origami-trip` 仓库
  - 在仓库中新建组件/容器/selector 时，决定**落在哪**、**怎么组织文件**、**怎么编排单测与 storybook**。
  - 在仓库用于检查现有文件编排、domain合理性

---

## 1. Domain 归属决策

所有业务代码落在 `src/domains/<Domain>/`。现有 domain：

| Domain            | 职责                                                                                    |
| ----------------- | --------------------------------------------------------------------------------------- |
| `Ancillary`       | 行李、座位、保险、值机等附加服务（baggage / seat / insurance / auto-checkin / bundles） |
| `Flight`          | 航班信息、航段、航班卡展示                                                              |
| `SearchResults`   | SRP 搜索结果、排序、筛选                                                                |
| `Cost`            | 价格、总价、价格明细                                                                    |
| `Payment`         | 支付、支付方式、支付流程                                                                |
| `Customer`        | 乘客信息、乘客证件                                                                      |
| `CustomerService` | 客服、帮助中心                                                                          |
| `Account`         | 账户、登录态、用户中心                                                                  |
| `PostSale`        | 售后、退改签、订单管理                                                                  |
| `CrossSell`       | 交叉售卖（酒店/保险等）                                                                 |
| `Content`         | CMS/文案/营销内容块                                                                     |
| `Core`            | 核心流程、应用级编排                                                                    |
| `Common`          | 跨 domain 通用组件/hooks/helpers（AccentHeading、Form、ErrorCatcher 等）                |
| `MetaPartner`     | 元搜索合作方相关                                                                        |
| `Legal`           | 法律条款、合规弹窗                                                                      |

**归属判定流程：**

1. 如果功能只被一个 domain 使用 → 落到那个 domain
2. 如果被 3+ domain 复用 → 落到 `Common`
3. 如果是页面级编排、跨 domain 状态协调 → 落到 `Core` 或对应 `src/pages/<PageName>/`
   1. Core domain非常严格，必须是跟整体页面框架、基建相关的内容
4. 拿不准时，询问用户而非自行猜测

---

## 2. 组件（Component）目录结构

路径：`src/domains/<Domain>/components/<ComponentName>/`

```
<ComponentName>/
├── <ComponentName>.tsx        # 主组件（纯展示/轻交互，无 redux 连接）
├── index.tsx                   # 桶文件：re-export 主组件和子组件
├── types.tsx                   # Props 类型、局部类型（注意：复数 types 或单数 type 均有历史存在，**新文件统一用 types.tsx**）
├── constants.tsx               # 仅本组件作用域的常量（枚举/字符串表/默认值）
├── helpers/                    # 纯函数辅助（文案拼装、gtmId、aria-label 等）
│   ├── <helperA>.tsx
│   ├── <helperB>.tsx
│   └── index.tsx               # 统一 re-export
├── components/                 # 子组件（只被当前组件使用）
│   └── <SubComponent>/
├── __tests__/                  # 单元测试
│   ├── <ComponentName>.test.tsx
│   └── __snapshots__/
├── __stories__/                # Storybook（可选）
│   └── <ComponentName>.story.tsx
└── __mocks__/                  # 测试/story 共用的 mock 数据（可选）
    └── <name>.mock.tsx
```

**关键约定：**

- 入口文件名与文件夹同名：`BaggageChip/BaggageChip.tsx`
- 文件名用 PascalCase；文件夹用 PascalCase
- `index.tsx` 只做 re-export，**不放任何实现**
- `types.tsx` / `constants.tsx` 即使只有一两个导出也独立成文件，保持可扩展
- 所有文件后缀 `.tsx`（即便不含 JSX，仓库约定如此）

**index.tsx 模板：**

```tsx
export { BaggageChip } from "./BaggageChip";
export { PersonalItemChip } from "./PersonalItemChip";
export type { BaggageChipProps } from "./types";
```

---

## 3. 容器（Container）目录结构

路径：`src/domains/<Domain>/containers/<ContainerName>/`

容器 = 组件 + redux（actions / reducer / epics / selectors）。

```
<ContainerName>/
├── <ContainerName>.tsx         # 主容器：connect + compose + injectReducer/injectEpic
├── index.tsx                   # export { default } from './<ContainerName>';
├── actions.tsx                 # redux action creators
├── reducer.tsx                 # reducer
├── epics/                      # redux-observable epics
│   ├── <epicA>.tsx
│   └── index.tsx
├── selectors/                  # reselect selectors
│   ├── <selectorA>.tsx
│   └── index.tsx
├── constants.tsx               # 至少包含 KEY（用作 store 注入键）
├── types.tsx
├── helpers/
└── __tests__/
```

**关键约定：**

- `index.tsx` 必须用 `export { default }` 保持默认导出：`export { default } from './BaggageContainer';`
- `constants.tsx` 里导出 `KEY`，`injectReducer({ key: KEY, reducer })` / `injectEpic({ key: KEY, epic })` 用它作为命名空间
- 容器通过 `connect(mapStateToProps, mapDispatchToProps)` + `createStructuredSelector` 组合 selector
- 有 render-prop 时定义 `RenderProps` 类型放在 `types.tsx`

---

## 4. Selectors 独立目录

selector 的**归属落位**看它依赖谁、谁依赖它：

- **输入只来自单个 container** → 落到该 container 的 `selectors/` 下（即使子目录形式）。不要为了"跨容器复用"而提到 domain 级——否则会制造 domain → page 或 domain → 无关 container 的反向依赖
- **真正跨 2+ container 共用、且依赖方向干净** → 才放到 `src/domains/<Domain>/selectors/<selectorName>/`
- 拿不准时就贴近输入

子目录形式：

```
<containerOrDomain>/selectors/<selectorName>/
├── <selectorName>.tsx          # createSelector(...) 装配，无纯函数
├── index.tsx                   # barrel
├── types.tsx                   # 导出的类型
├── constants.tsx               # 魔法值常量
├── helpers/                    # 所有纯函数拆进来
│   └── index.tsx
└── __tests__/
    └── <selectorName>.test.tsx
```

小而独立的 selector 直接写 `selectors/<name>.tsx` 单文件。

**⚠️ ESLint 陷阱**：`.eslintrc.js` 的 `max-params` 关闭 override 需要用 `**/selectors/**/*.tsx`（双星）才能匹配子目录。如果仓库里还是 `**/selectors/*.tsx`（单星），子目录形式的 selector 会挨 `max-params` 打——**修 eslint pattern，不要 `eslint-disable`**。

---

## 5. 单元测试编排

**强制遵循全局 CLAUDE.md 中的测试规范。** 要点复述：

- 测试文件位置：与被测文件**同级**的 `__tests__/` 下
- 文件名：`<被测文件名>.test.tsx`
- 覆盖率：100%
- 使用 `react-test-renderer` 的 `create`
- 所有组件依赖一律 mock 为字符串组件：`jest.mock('../components/ChipWithTooltip', () => ({ ChipWithTooltip: 'ChipWithTooltip' }))`
- 禁止 mock `@xivart/tangram/*`、`localize`、`helpers` 函数（注：helpers mock 出现在历史代码中，**新测试遵守全局规范不 mock helpers**；如必须，仅为隔离被测逻辑）
- 断言统一用 `toMatchSnapshot()` / `toMatchInlineSnapshot()`
- 禁止 `as any`；测试数据用真实类型
- 禁止任何注释
- 统一提取 `renderComponent` 工厂函数，用 `...` 展开默认 props
- 完成后运行 `npm run check:format` 与 `npm run check:types`

**renderComponent 模板：**

```tsx
const renderComponent = (props: Partial<BaggageChipProps> = {}) =>
  create(
    <BaggageChip
      baggageDetails={baggageDetailsWithRelatedProducts}
      baggageStatus={BaggageStatus.Optional}
      baggageType={BaggageType.CheckedBaggage}
      isReturnFlight={false}
      onClickBaggageLink={jest.fn()}
      {...props}
    />,
  );
```

---

## 6. Storybook 编排

- 位置：组件目录下的 `__stories__/<ComponentName>.story.tsx`（注意仓库里用 `.story.tsx` 也用 `.stories.tsx`，**新文件统一用 `.story.tsx` 随 Ancillary 多数约定**；若该 domain 已有 `.stories.tsx`，与就近保持一致）
- `title` 用 `<Domain>/<SubArea>/<ComponentName>` 形式：`'Ancillary/Baggage/BaggageArea'`
- 使用 CSF3：`Meta<typeof X>` / `StoryObj<typeof X>`
- 复杂依赖（redux / router / final-form）在 story 里用 `Provider` / `MemoryRouter` / `Form` 包裹
- Mock 数据优先从同组件的 `__mocks__/` 或 `~app/internal/apiMocks/` 导入，**不要在 story 中硬编码大对象**
- `argTypes` 给出可选项与控件类型
- 有 Figma 来源时填 `parameters.design`

**story 骨架：**

```tsx
import { Meta, StoryObj } from "@storybook/react";

import { BaggageChip } from "..";
import { BaggageChipProps } from "../types";

const meta: Meta<typeof BaggageChip> = {
  title: "Ancillary/Baggage/BaggageChip",
  component: BaggageChip,
};
export default meta;

export const Default: StoryObj<typeof BaggageChip> = {
  args: {
    /* ... */
  },
};
```

---

## 7. Mock 数据（`__mocks__/`）

- 命名 `<name>.mock.tsx`，导出 const 与被测组件/容器同级使用
- 测试与 story **共用**同一份 mock，避免重复
- 跨组件共享的 mock 提升到 domain 级：`src/domains/<Domain>/__mocks__/` 或就近选择已有 `__mocks__` 文件夹
- 全局 API mock 在 `src/internal/apiMocks/`

---

## 8. 新建流程 Checklist，约束文件内容

当用户让你新建 `XxxCard` 组件：

1. 问清/判断归属 domain
2. 确认是"纯组件"还是"需要 redux"——决定 `components/` 还是 `containers/`
3. 创建目录骨架（组件用组件模板，容器用容器模板）
4. `index.tsx` 只 re-export
5. `types.tsx` 先定义 Props
6. `constants.tsx` 抽出枚举/魔法值
7. `helpers/` 拆纯函数
8. 在 `__tests__/` 建测试，达 100% 覆盖
9. 询问是否建 `__stories__/` 与 `__mocks__/`（默认不需要）
10. 询问是否运行 `npm run check:format` 与 `npm run check:types`（默认运行）

---

## 9. 一些标准做法模式（要这么做）

- ✅ 使用`import type` `export type`的形式将types.tsx文件的type内容对外暴露

---

## 9. 反模式（不要这么做）

- ❌ 把多个组件塞进同一个 `XxxComponents.tsx`
- ❌ 在 `index.tsx` 里写实现逻辑
- ❌ 把只有单一消费者的子组件放到 `Common`
- ❌ 跨 domain 从 `~app/domains/A/...` 深入到对方的 `components/内部/子组件`——应通过对方 `index.tsx` 暴露的公共接口
- ❌ 测试里 mock `@xivart/tangram/*` 或 `localize`
- ❌ 源代码中留除了 `TODO` 以外的解释性注释

---

## 10. Git push 约定

- 本仓库默认远程为 `origin` 主分支`dev-master`
- 推送使用 force：`git push origin <branch> --force`（或等价的 `--force-with-lease`）
- 用户说 "push" / "推一下" / "git push" 时，按上述命令直接执行，无需再次确认远程名或 force 策略
- 例外：若用户显式指定其它远程或禁止 force，按用户指令

---

## 11. ESLint 约束（写代码时主动遵守）

**Import**

- 两组，组间空行，组内按字母升序：① `builtin`+`external`（`react*` 最前）② `sibling`+`parent`+`~app/...`+`index`。本地 `./x` 要排在 `~app/x` 之前
- 不带扩展名；不用 default export；跨 domain 必须走对方 `index.tsx`（例外：`Common` / `Core/index` / `Ancillary/index` / `Content/components/SearchBox` / `Content/containers/SearchBoxContainer`）
- 禁 `@xivart/edge/src/**`、`@ctrip/travix-edge/src/**`、`rxjs/**`（只留 `rxjs` / `rxjs/ajax` / `rxjs/operators` / `rxjs/testing`）
- Core 以外不能 import `selectExperiments`

**TS/语言**

- `max-params: 3`（selector 文件关闭）；`max-len: 100`（忽略字符串/URL/行尾注释）
- 启用：`no-use-before-define`、`no-shadow`、`prefer-destructuring`、`camelcase`、`no-constructor-return`
- 禁全局 `sessionStorage` / `localStorage`，用 `Common/services/WebStorage`
- `no-underscore-dangle`（仅允许 `__REDUX_DEVTOOLS_EXTENSION_COMPOSE__`、`__TRAVIX_WEB_HELPER_ENHANCE__`）
- **避免 `any`**：
  - 绝对禁 `any`、`as any`、`cost?: any` 这类泛型/字段约束 —— 会让整条数据流丢失类型检查
  - 需要"弱约束字段上的值"时，从 domain 类型包导入准确类型（如 `BaggageCost` from `@ctrip/booking-edge/types/order`），作为独立参数传递或在 interface 里声明
  - 上游已守卫过的可选字段（如 `option.cost?.amountTotal` 被 `if` 过滤）：把守卫后的值作为显式参数往下传，而不是在下游重复 `?.` 然后 cast `any`
  - 测试里唯一允许 `as unknown as X`（仍不允许 `as any`）的场景：构造运行时有但 TS 类型不完整的 mock 对象（如把 `benefits: string[]` 写进 `CabinBaggageOption` 时）
  - 如果你确实需要一个"任意对象"占位，用 `unknown` 而不是 `any`

**React**

- 文件后缀 `.tsx`
- 禁止传 `className` / `style` 到组件（用 tangram）
- 禁 props spread（HTML 标签 / test / story / connect / variantSelection 例外）
- 必填：`destructuring-assignment: always`、`jsx-sort-props`、`no-array-index-key`、`require-default-props`、`jsx-no-useless-fragment`、`react-hooks/rules-of-hooks` + `exhaustive-deps`
- 禁 `react/forbid-prop-types: any`
- `react/react-in-jsx-scope` 关（新 JSX runtime）

**其他**

- `TODO` 必须带 JIRA 链接：`TODO https://travix.atlassian.net/browse/<TICKET>`，否则删掉
- `localize` 的字符串实参走 `@xivart/l10ns` 严格检查（`i18n` key 例外）
- `describe` / `it` / `test` 块前后留空行

**落地清单**

```bash
npx eslint <改动文件>      # 0 error
npm run check:format
npm run check:types
```

pre-commit/pre-push 被 pre-existing 错误挡住时可 `--no-verify`，但本次改动必须干净。
