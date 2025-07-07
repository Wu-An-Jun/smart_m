# 快速服务动画效果实现

## 功能描述

在主页的快速服务区域实现了动画效果，当设备展示状态 `_showDeviceSection` 为 `true` 时，快速服务容器会自动缩小高度并调整其子元素尺寸。

## 技术实现

### 核心特性

1. **AnimatedContainer 动画**
   - 使用 `AnimatedContainer` 替代普通的 `Container`
   - 动画持续时间：400毫秒
   - 动画曲线：`Curves.easeInOut`

2. **自适应高度调整**
   - 默认状态：118px 高度
   - 设备区域显示时：80px 高度（缩小 32%）

3. **动态内边距调整**
   - 默认状态：12px 内边距
   - 紧凑模式：8px 内边距

4. **响应式间距**
   - 默认状态：子元素间距 20px
   - 紧凑模式：子元素间距 15px

### 快速服务项目动画

每个快速服务项目也实现了动画效果：

1. **容器尺寸动画**
   - 默认：75x90px
   - 紧凑：65x70px

2. **图标尺寸调整**
   - 默认：40x40px
   - 紧凑：30x30px

3. **文字和间距优化**
   - 默认字体：11px
   - 紧凑字体：9px
   - 动态调整间距

## 触发条件

快速服务动画在以下情况下触发：

1. 用户点击"我的设备"快速服务项
2. `_showDeviceSection` 状态从 `false` 切换到 `true`
3. 设备区域显示时，快速服务自动缩小为紧凑模式

## 视觉效果

- **平滑过渡**：400ms 的平滑动画让界面变化更自然
- **空间优化**：为设备区域让出更多显示空间
- **保持功能性**：即使在紧凑模式下仍保持完整的交互功能

## 代码关键点

```dart
// 主容器动画
AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  height: _showDeviceSection ? 80 : 118,
  padding: EdgeInsets.all(_showDeviceSection ? 8 : 12),
  // ...
)

// 快速服务项动画
AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  width: isCompact ? 65.0 : 75.0,
  height: isCompact ? 70.0 : 90.0,
  // ...
)
```

## 测试方法

1. 启动应用并进入主页
2. 点击快速服务中的"我的设备"项
3. 观察快速服务区域的平滑缩小动画效果
4. 再次点击可以看到恢复动画

这个实现提供了流畅的用户体验，通过动画让界面变化更加自然，同时优化了空间布局。 