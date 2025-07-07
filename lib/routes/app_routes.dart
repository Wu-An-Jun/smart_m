// lib/routes/app_routes.dart
abstract class AppRoutes {
  static const login = '/login';
  static const main = '/main';
  static const home = '/home';
  static const deviceManagement = '/device-management';
  static const deviceManagementDemo = '/device-management-demo';
  static const deviceList = '/device-list';
  static const deviceDetail = '/device-detail';
  static const assistant = '/assistant';
  static const aiAssistant = '/ai-assistant';
  static const profile = '/profile';
  static const map = '/map';
  static const mapLocation = '/map/location';
  static const deviceLocationMap = '/device-location-map';
  static const smartLife = '/smart-life';
  static const service = '/service';
  static const notifications = '/notifications';
  
  // 智能家居相关路由
  static const smartHome = '/smart-home';
  static const smartHomeAutomation = '/smart-home-automation';
  static const deviceControl = '/device-control';
  static const sceneManager = '/scene-manager';
  static const deviceAdd = '/device-add';
  static const addDevice = '/add-device';
  static const deviceSettings = '/device-settings';
  static const automationRules = '/automation-rules';
  static const automationCreation = '/automation-creation';
  static const securityCenter = '/security-center';
  static const energyMonitor = '/energy-monitor';
  static const qrCodeScanner = '/qr-code-scanner';
  
  // 测试页面
  static const aiAssistantTest = '/ai-assistant-test';
  static const moreSettingsDemo = '/more-settings-demo';
  static const toggleButtonDemo = '/toggle-button-demo';
  static const amapGeofenceTest = '/amap-geofence-test';
  static const splash = '/splash';
  static const addDeviceManual = '/add_device_manual';
} 