# Smart U - 智能家居Flutter应用

## 📱 项目简介

Smart U 是一个基于 Flutter 开发的智能家居管理应用，集成了设备管理、电子围栏、自动化控制和 AI 助手等功能。

## ✨ 主要功能

### 🏠 智能家居控制
- **设备管理**：支持添加、管理和控制各类智能设备
- **自动化场景**：创建基于时间、位置和环境条件的自动化规则
- **实时监控**：实时查看设备状态和数据

### 🗺️ 电子围栏
- **围栏创建**：支持创建圆形和多边形围栏
- **进出提醒**：自动检测进入/离开围栏区域
- **地图集成**：基于高德地图的可视化围栏管理

### 🤖 AI 智能助手
- **语音交互**：支持语音命令控制设备
- **智能建议**：基于使用习惯提供智能化建议
- **问答系统**：集成 Dify AI 服务

### 🎨 界面设计
- **现代化UI**：Material Design 3 风格界面
- **主题切换**：支持明暗主题切换
- **响应式布局**：适配不同屏幕尺寸

## 🛠️ 技术架构

### 框架与库
- **Flutter**: 跨平台移动应用开发框架
- **Riverpod**: 状态管理
- **AutoRoute**: 路由管理
- **GetIt**: 依赖注入
- **Freezed**: 数据类生成

### 核心技术
- **Clean Architecture**: 清洁架构设计模式
- **Repository Pattern**: 数据持久化模式
- **Controller Pattern**: 业务逻辑控制

### 第三方服务
- **高德地图**: 地图和定位服务
- **Dify AI**: AI 对话服务
- **地理围栏**: 位置感知服务

## 📁 项目结构

```
lib/
├── common/          # 通用工具类
├── controllers/     # 业务逻辑控制器
├── models/          # 数据模型
├── routes/          # 页面路由
├── states/          # 状态管理
└── widgets/         # 自定义组件
```

## 🚀 快速开始

### 环境要求
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/Wu-An-Jun/smart_u.git
cd smart_u
```

2. **安装依赖**
```bash
flutter pub get
```

3. **配置环境**
- 配置高德地图 API Key
- 配置 Dify AI 服务

4. **运行应用**
```bash
flutter run
```

## 📋 功能模块

### 设备管理
- 支持多种设备类型（灯光、空调、安防等）
- 设备状态实时同步
- 批量设备操作

### 自动化控制
- 时间条件触发
- 位置条件触发
- 环境条件触发
- 设备状态联动

### 地理围栏
- 基于GPS的位置检测
- 多种围栏类型支持
- 进出事件通知

### AI助手
- 自然语言处理
- 智能设备控制
- 使用习惯学习

## 🧪 测试

```bash
# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test/
```

## 📄 许可证

MIT License

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

如有问题，请通过 GitHub Issues 联系。
