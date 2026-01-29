import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulse_mark/db_pulse_mark/data.dart';
import 'package:pulse_mark/utils/index.dart';

class PulseMarkSettingsLogic extends GetxController {
  final WatermarkHistoryDao _watermarkDao = WatermarkHistoryDao();
  final GridCutHistoryDao _gridCutDao = GridCutHistoryDao();

  Future<void> deleteAllData() async {
    try {
      await _watermarkDao.deleteAll();
      await _gridCutDao.deleteAll();
      successToast('All data deleted successfully');
    } catch (e) {
      errorToast('Failed to delete data: ${e.toString()}');
    }
  }

  void showDeleteConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete all data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteAllData();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void onViewTutorial() {
    Get.toNamed('/pulse_mark_onboarding');
  }
}

