# m

A new Flutter project.

## 目录结构

lib/
├── app/
│ ├── app.dart # 应用程序入口
│ └── routes.dart # 路由配置
├── core/
│ ├── constants/ # 常量定义
│ ├── errors/ # 错误处理
│ ├── theme/ # 主题配置
│ │ ├── app_colors.dart
│ │ ├── app_themes.dart
│ │ └── theme_provider.dart
│ └── utils/ # 工具类
├── data/
│ ├── models/ # 数据模型
│ ├── repositories/ # 数据仓库
│ └── services/ # API 服务
│ └── api_client.dart
├── di/ # 依赖注入
│ └── service_locator.dart
├── features/ # 功能模块
│ └── feature_name/ # 具体功能
│ ├── data/
│ ├── domain/
│ └── presentation/
│ ├── pages/
│ ├── widgets/
│ └── providers/
├── i18n/ # 国际化
│ ├── translations/
│ │ ├── en.dart
│ │ └── zh.dart
│ └── i18n.dart
├── shared/ # 共享组件
│ ├── widgets/
│ └── providers/
└── main.dart # 程序入口文件


## 代码质量

- 遵循 Flutter 最佳实践
- 使用 Riverpod 进行状态管理
- 使用 Dio 进行网络请求
- 代码格式化使用 Flutter 官方的 dartfmt
- 代码分析使用 Flutter 官方的 dartanalyzer
- 代码风格使用 Flutter 官方的风格指南
- 注释详细，遵循 Doxygen 风格
- 命名规范清晰，遵循驼峰命名法
- 代码结构清晰，易于维护
- 避免重复代码，使用封装好的组件和库
- 单元测试覆盖率达到 80% 以上
- 集成测试覆盖率达到 80% 以上
- 代码变更需要经过 Code Review
- 代码变更需要更新文档
- 代码变更需要更新版本号


## 质量检测命令

### 代码格式化

flutter format lib

### 代码分析

flutter analyze lib

dart fix --apply lib


### 自动生成 toJson

flutter pub run build_runner build
