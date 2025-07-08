import 'package:get/get.dart';
import 'package:smart_u_new/routes/add_device_page.dart';
import 'package:smart_u_new/routes/ai_assistant_test_page.dart';
import 'package:smart_u_new/routes/ai_chat_history_page.dart';
import 'package:smart_u_new/routes/amap_geofence_test_page.dart';
import 'package:smart_u_new/routes/app_routes.dart';
import 'package:smart_u_new/routes/assistant_page.dart';
import 'package:smart_u_new/routes/automation_creation_page.dart';
import 'package:smart_u_new/routes/data_recharge_page.dart';
import 'package:smart_u_new/routes/device_list_page.dart';
import 'package:smart_u_new/routes/device_management_page.dart';
import 'package:smart_u_new/routes/device_management_demo_page.dart';
import 'package:smart_u_new/routes/home_page.dart';
import 'package:smart_u_new/routes/login_page.dart';
import 'package:smart_u_new/routes/main_page.dart';
import 'package:smart_u_new/routes/map_page.dart';
import 'package:smart_u_new/routes/device_location_map_page.dart';
import 'package:smart_u_new/routes/notification_page.dart';
import 'package:smart_u_new/routes/profile_page.dart';
import 'package:smart_u_new/routes/qr_code_scanner_page.dart';
import 'package:smart_u_new/routes/service_page.dart';
import 'package:smart_u_new/routes/smart_home_automation_page.dart';
import 'package:smart_u_new/routes/smart_life_page.dart';
import 'package:smart_u_new/routes/more_settings_demo_page.dart';
import 'package:smart_u_new/routes/toggle_button_demo_page.dart';
import 'package:smart_u_new/routes/splash_page.dart';
import 'add_device_manual_page.dart';

abstract class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.main, page: () => const MainPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(
      name: AppRoutes.deviceManagement,
      page: () => const DeviceManagementPage(),
    ),
    GetPage(
      name: AppRoutes.deviceManagementDemo,
      page: () => const DeviceManagementDemoPage(),
    ),
    GetPage(name: AppRoutes.deviceList, page: () => const DeviceListPage()),

    GetPage(name: AppRoutes.assistant, page: () => const AssistantPage()),
    GetPage(name: AppRoutes.aiChatHistory, page: () => const AiChatHistoryPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.map, page: () => const MapPage()),
    GetPage(name: AppRoutes.deviceLocationMap, page: () => const DeviceLocationMapPage()),
    GetPage(name: AppRoutes.smartLife, page: () => const SmartLifePage()),
    GetPage(name: AppRoutes.service, page: () => const ServicePage()),
    GetPage(name: AppRoutes.dataRecharge, page: () => const DataRechargePage()),
    GetPage(name: AppRoutes.notifications, page: () => NotificationPage()),
    GetPage(
      name: AppRoutes.aiAssistantTest,
      page: () => const AiAssistantTestPage(),
    ),
    GetPage(
      name: AppRoutes.smartHomeAutomation,
      page: () => const SmartHomeAutomationPage(),
    ),
    GetPage(
      name: AppRoutes.automationCreation,
      page:
          () => AutomationCreationPage(
            onAutomationCreated: (automation) {
              // 可以在这里处理自动化创建完成的回调
            },
          ),
    ),
    GetPage(
      name: AppRoutes.moreSettingsDemo,
      page: () => const MoreSettingsDemoPage(),
    ),
    GetPage(
      name: AppRoutes.toggleButtonDemo,
      page: () => const ToggleButtonDemoPage(),
    ),
    GetPage(
      name: AppRoutes.amapGeofenceTest,
      page: () => const AMapGeofenceTestPage(),
    ),
    GetPage(
      name: AppRoutes.qrCodeScanner,
      page: () => const QrCodeScannerPage(),
    ),
    GetPage(
      name: AppRoutes.addDeviceManual,
      page: () => const AddDeviceManualPage(),
    ),
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
  ];
}
