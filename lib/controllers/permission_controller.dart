import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class PermissionController extends GetxController {
  final RxBool locationGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    requestLocationPermission();
  }

  /// 申请定位权限
  Future<void> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationGranted.value = false;
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      locationGranted.value = false;
      return;
    }
    locationGranted.value = true;
  }
} 