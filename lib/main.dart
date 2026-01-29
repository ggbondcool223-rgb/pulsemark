import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_mark/common/colors.dart' as app_colors;
import 'package:pulse_mark/db_pulse_mark/data.dart';
import 'package:pulse_mark/pages/pulse_mark_auth/pulse_mark_auth_binding.dart';
import 'package:pulse_mark/pages/pulse_mark_auth/pulse_mark_auth_view.dart';
import 'package:pulse_mark/pages/pulse_mark_camera/pulse_mark_camera_call.dart';
import 'package:pulse_mark/pages/pulse_mark_tab/pulse_mark_tab_view.dart';
import 'package:pulse_mark/pages/pulse_mark_tab/pulse_mark_tab_binding.dart';
import 'package:pulse_mark/pages/pulse_mark_camera/pulse_mark_camera_view.dart';
import 'package:pulse_mark/pages/pulse_mark_camera/pulse_mark_camera_binding.dart';
import 'package:pulse_mark/pages/pulse_mark_watermark_select/pulse_mark_watermark_select_view.dart';
import 'package:pulse_mark/pages/pulse_mark_watermark_select/pulse_mark_watermark_select_binding.dart';
import 'package:pulse_mark/pages/pulse_mark_watermark_edit/pulse_mark_watermark_edit_view.dart';
import 'package:pulse_mark/pages/pulse_mark_watermark_edit/pulse_mark_watermark_edit_binding.dart';
import 'package:pulse_mark/pages/pulse_mark_grid_cut/pulse_mark_grid_cut_view.dart';
import 'package:pulse_mark/pages/pulse_mark_grid_cut/pulse_mark_grid_cut_binding.dart';
import 'package:pulse_mark/pages/pulse_mark_onboarding/pulse_mark_onboarding_view.dart';
import 'package:pulse_mark/pages/pulse_mark_onboarding/pulse_mark_onboarding_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final isFirstLaunch = await _checkFirstLaunch();

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
}

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

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: PMarks,
          initialRoute: '/',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: app_colors.primaryColor,
            scaffoldBackgroundColor: app_colors.bgColor,
            colorScheme: ColorScheme.light(
              primary: app_colors.primaryColor,
              surface: const Color(0xFFFFFFFF),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F0F0F),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22, color: Colors.white),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Color(0xFFFF6090),
              unselectedItemColor: Color(0xFF6B7280),
              elevation: 0,
              backgroundColor: Color(0xFFFFFFFF),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            dividerTheme: const DividerThemeData(
              thickness: 1,
              color: Color(0xFFE5E7EB),
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> PMarks = [
  GetPage(
    name: '/',
    page: () => const PulseMarkAuthView(),
    binding: PulseMarkAuthBinding(),
  ),
  GetPage(
    name: '/pulse_mark_tab',
    page: () => const PulseMarkTabView(),
    binding: PulseMarkTabBinding(),
  ),
  GetPage(
    name: '/pulse_mark_camera',
    page: () => const PulseMarkCameraView(),
    binding: PulseMarkCameraBinding(),
  ),
  GetPage(
    name: '/pulse_mark_call',
    page: () => const PulseMarkCameraCall(),
  ),
  GetPage(
    name: '/pulse_mark_watermark_select',
    page: () => const PulseMarkWatermarkSelectView(),
    binding: PulseMarkWatermarkSelectBinding(),
  ),
  GetPage(
    name: '/pulse_mark_watermark_edit',
    page: () => const PulseMarkWatermarkEditView(),
    binding: PulseMarkWatermarkEditBinding(),
  ),
  GetPage(
    name: '/pulse_mark_grid_cut',
    page: () => const PulseMarkGridCutView(),
    binding: PulseMarkGridCutBinding(),
  ),
  GetPage(
    name: '/pulse_mark_onboarding',
    page: () => const PulseMarkOnboardingView(),
    binding: PulseMarkOnboardingBinding(),
  ),
];