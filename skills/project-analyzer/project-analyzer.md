---
name: project-analyzer
description: 分析前端/Node/Next.js项目结构、技术栈、构建流程
type: skill
---

# Project Analyzer Skill

用于快速分析和解构前端项目、Node项目、Next.js项目的结构与技术架构。

---

## 1. 项目类型判定

首先识别项目类型：

| 特征 | Next.js | 纯Node | 纯前端 |
|------|---------|--------|--------|
| 存在 `next.config.js` | ✓ | | |
| 存在 `pages/` 或 `app/` 目录 | ✓ | | |
| 存在 `index.js` 入口 | | ✓ | |
| 存在 `src/` + 组件结构 | | | ✓ |
| `package.json` 中 `dependencies` 包含 `next` | ✓ | | |

**origami-trip 示例**:
- `next.config.js` 存在，但实际是 `nfes.config.js`
- `pages/` 目录存在，包含 `_app.tsx`, `_document.tsx`, `[[...slug]].tsx`
- 入口是 `index.js` 调用 `nfesRun()`
- **结论**: Next.js 项目，但使用 **NFES (Next Framework for Enterprise Services)** 封装

---

## 2. 目录结构分析

### 核心目录

| 目录 | 作用 | origami-trip 示例 |
|------|------|-------------------|
| `/src` | 主源码 | `src/domains`, `src/pages`, `src/server`, `src/shared` |
| `/pages` 或 `/app` | 路由/页面 | `pages/_app.tsx`, `pages/[[...slug]].tsx` |
| `/components` | 公共组件 | `src/shared/components/` |
| `/server` 或 `/gateway` | 服务端逻辑 | `src/server/` (Express), `gateway/` |
| `/middleware` | 中间件 | TypeScript编译产物 |
| `/scripts` | 构建/部署脚本 | `scripts/startup.sh` |
| `/build` 或 `.next` | 构建产物 | `build/` |
| `/static` | 静态资源 | `static/` |

### 业务域拆分 (`/src/domains`)

`origami-trip` 按业务能力拆分域：

```
src/domains/
├── Account/        # 账户相关
├── Ancillary/      # 增值服务
├── Common/         # 公共组件
├── Content/        # 内容页
├── Core/           # 核心功能
├── Cost/           # 成本/价格
├── CrossSell/      # 交叉销售
├── Customer/       # 客户
├── CustomerService/# 客服
├── Flight/         # 航班
├── Legal/          # 法律条款
├── MetaPartner/    # 元搜索合作
├── Payment/        # 支付
├── PostSale/       # 售后
└── SearchResults/  # 搜索结果
```

每个域内部结构一致：
```
Domain/
├── components/    # 组件
├── containers/    # 容器组件
├── helpers/       # 工具函数
├── hooks/         # 自定义hooks
├── services/      # API服务
└── types/         # 类型定义
```

---

## 3. 技术基础设施分析

### 3.1 框架层

**React 18** + **TypeScript**

```typescript
// src/pages/index.tsx - 页面工厂
export const CorePageFactory: React.FC = ({ pageData, pageName }) => {
  return (
    <Provider store={store}>
      <Experimentation.Client value={experimentation}>
        <Router location={location} navigation={navigation}>
          {renderRoutes(routeConfig)}
        </Router>
      </Experimentation.Client>
    </Provider>
  );
};
```

### 3.2 状态管理

- **Redux** + 自定义 store 配置
- **React Context** 用于实验性功能 (`Experimentation.Client`)

### 3.3 路由

- **React Router v6** (客户端路由)
- **Next.js 路由** (服务端路由 via `[[...slug]].tsx`)

### 3.4 HTTP层

- 自定义 `httpClient` (基于 axios 封装)
- 服务端直连 HTTP

### 3.5 样式

- **Tailwind CSS** (`tailwind.config.js`)
- **CSS Modules** (按需)

### 3.6 国际化

- `@ctrip/nfes-next` 内置 i18n 支持
- ` captainsOptions.site: 'ares.i18n'`

### 3.7 监控/日志

- **Shark** - 实验/特性监控
- **自研 logger** (`src/logger/`)

### 3.8 组件加载

- `@loadable/component` → 自定义 `dynamic` 包装 (via babel 插件转换)
- 动态导入实现代码分割

---

## 4. 编译/构建过程分析

### 4.1 构建工具链

| 工具 | 用途 |
|------|------|
| **NFES** (`@ctrip/nfes-core`, `@ctrip/nfes-next`) | 企业级 Next.js 封装 |
| **Webpack 5** | 打包 (通过 NFES 封装) |
| **Babel** | JS/JSX 转译 |
| **TypeScript** (`tsc`) | 类型检查 + 编译 |
| **SWC** (`@swc/jest`) | Jest 测试的 TS 转译 |
| **tsc-alias** | 路径别名解析 |

### 4.2 编译流程图

```
┌─────────────────────────────────────────────────────────────┐
│  npm run build (nfes build)                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Middleware 编译                                          │
│     tsc -p tsconfig.middleware.json                         │
│     tsc-alias -p tsconfig.middleware.json                   │
│     → 输出到 /middleware/                                    │
│                                                              │
│  2. Webpack 构建 (通过 NFES)                                  │
│     ├── babel-loader (js/jsx)                                │
│     │   preset: @ctrip/nfes-next/babel                      │
│     ├── swc-loader (ts/tsx)                                  │
│     ├── @loadable/component → @ctrip/nfes-next/dynamic      │
│     │   (babel-plugin-transform-loadable.js)                │
│     └── 路径别名解析 (module-resolver)                       │
│         ~app/* → src/*                                      │
│         ~gateway/* → gateway/*                              │
│                                                              │
│  3. 输出到 /build/                                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 关键配置文件

| 文件 | 作用 |
|------|------|
| `nfes.config.js` | CDN、站点配置、Shark analytics、affiliates 初始化 |
| `app.config.js` | 域名映射、重定向规则、S3 配置 |
| `.babelrc.js` | Babel preset + 路径别名解析 |
| `tsconfig.json` | TypeScript 配置，路径别名 |
| `tsconfig.middleware.json` | 中间件 TypeScript → CommonJS |
| `paths.json` | 路径别名映射 |
| `jest.config.js` | Jest + SWC 配置 |
| `tailwind.config.js` | Tailwind CSS 配置 |

### 4.4 开发流程

```bash
npm run dev      # nfes start - 开发服务器
npm run build    # nfes build - 生产构建
npm run storybook # Storybook 组件开发
```

### 4.5 SWC vs Babel

| 场景 | 工具 | 原因 |
|------|------|------|
| Jest 测试 | SWC (`@swc/jest`) | 速度快 |
| Webpack 构建 | Babel (`babel-loader`) | NFES 定制支持 |

---

## 5. 测试架构

### Jest 配置 (`jest.config.js`)

```javascript
{
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.(ts|tsx)$': '@swc/jest',  // SWC for TypeScript
    '^.+\\.(js|jsx)$': 'babel-jest'    // Babel for JavaScript
  },
  setupFilesAfterEnv: ['src/internal/jest/setup.tsx'],
  testMatch: ['**/__tests__/?(*.)+(test).(ts|tsx)'],
  coverageThreshold: {
    statements: 99,
    branches: 99,
    functions: 99,
    lines: 99
  }
}
```

### 测试文件位置

- 位置: `**/__tests__/**/*.test.tsx`
- 示例: `src/domains/PostSale/components/PostSaleFinalize/__tests__/PostSaleFinalize.test.tsx`

### 测试工具

- `@testing-library/react` - 组件测试
- `@testing-library/user-event` - 事件模拟
- `@testing-library/jest-dom` - 自定义断言

---

## 6. 多应用构建

`origami-trip` 支持多 APPID 构建：

| 应用 | APPID | 构建命令 |
|------|-------|----------|
| 主应用 | 100062066 | `npm run build` |
| Content | 100063494 | `npm run onlinebuildContent` |
| MyAccount | 100066988 | `npm run onlinebuildMyAccount` |

---

## 7. 快速读项目清单

1. **看入口**: `index.js` → `nfesRun()`
2. **看页面**: `pages/_app.tsx` + `pages/[[...slug]].tsx`
3. **看业务域**: `src/domains/` 按功能划分
4. **看构建**: `nfes.config.js` + `.babelrc.js`
5. **看路由**: `src/pages/index.tsx` 的 `CorePageFactory`
6. **看配置**: `package.json` scripts + `tsconfig.json`
7. **看测试**: `jest.config.js` + `src/internal/jest/setup.tsx`

---

## 8. 关键代码模式

### 页面组件模式

```typescript
// pages/[[...slug]].tsx
import { RootComponent } from '~app/src/pages';

export default function Page() {
  return <RootComponent />;
}

export getServerSideProps = () => { ... };
```

### 域组件结构

```typescript
// src/domains/{Domain}/{Component}/index.tsx
export const ComponentName: React.FC<Props> = ({ prop1, prop2 }) => {
  const { data, loading } = useCustomHook();

  if (loading) return <LoadingSpinner />;

  return (
    <Container>
      <SubComponent data={data} />
    </Container>
  );
};
```

### API 服务模式

```typescript
// src/domains/{Domain}/services/{Service}.ts
import { httpClient } from '~app/src/shared/utils/httpClient';

export const fetchData = (params: Params) => {
  return httpClient.get<Response>('/api/endpoint', { params });
};
```
