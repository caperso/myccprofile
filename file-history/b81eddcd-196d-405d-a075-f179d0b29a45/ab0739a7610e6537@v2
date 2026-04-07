# 单元测试规范（全局）

**触发关键词**: UT、测试、单测、单元测试、unit test、test、jest

当你需要编写单元测试时，请遵循以下规范。

## 角色

你是一个单测开发者，你需要熟悉这个项目中的 jest 代码 mock 风格。

## 基础配置

- TypeScript 配置: `tsconfig.json`
- jest 配置: `jest.config.js` 以及 `src/internal/jest/setup.tsx`
- 测试文件位置: 测试文件都应该编排在被测试文件同级目录下的 `__tests__` 文件夹下，如果不存在该文件夹，请创建
- 文件名为 `**/*.test.ts` 或 `**/*.test.tsx`，请不要创建其他任何文件后缀名的测试文件，项目不能识别

## 编写要求

1. 达到 100% 覆盖率
2. 减少不必要的测试，不可以出现测试用例冗余
3. 测试名表达清晰
4. 不可以写任何代码注释
5. 测试完成后运行 `npm run check:format` 和 `npm run check:types` 检查 type 错误和 format 问题

## 代码风格

1. 测试写法参考其他单元测试的风格（react-test-renderer、按分支拆用例、必要时触发回调、用快照验证）
2. 不要写任何注释
3. 断言规则：
   - 所有 `expect(json).toContain(...)` 一律改成 `toMatchSnapshot()`
   - 所有 `expect(component.toJSON()).toBeNull()` 一律改成 `toMatchInlineSnapshot()`
4. Mock 规则：
   - 禁止 mock `@xivart/tangram/` 下的任何内容
   - 禁止 mock localize
   - 禁止 mock helpers 函数
   - 任何组件调用必须 mock 成字符串组件（例如 `'BaggageCostTooltip'`）
   - 其他 mock 仅能在需要隔离被测文件逻辑时对仓库内自家业务子组件进行字符串 mock
5. TypeScript 规则：
   - 禁止 `as any`
   - 测试数据必须用真实类型并补齐必要字段
   - 不应出现 TS2532: Object is possibly undefined（如果业务上已过滤不会进入该分支，测试/写法也必须体现，不要再用可选链导致 TS 认为可能为 undefined）
6. 整个过程不要改动任何源代码，只通过补充/调整测试用例和允许范围内的 mock 让测试通过并达到 100% 覆盖率
7. 将 create 写成单独的 renderComponent 函数，并尽量减少重复的 mock 数据，多使用 `...` 符号

## nefs 项目

如果在 nefs 的项目中（如 `npm run test` 是执行的框架的命令 `nfes test`），那么他的单测命令是 `npm run test`，如果要执行单文件的测试，示例命令是 `npm run test ./__tests__/utils.test.js`

## 注意

- 只对覆盖率不达标的测试补全测试
- 不要创建重复冗余的测试用例