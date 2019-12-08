/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:58 AM
 *
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/sale_online/services/report_service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';

import 'app.dart';
import 'sale_online/services/remote_config_service.dart';

Future main() async {
  // setup locator
  await App.getAppVersion();
  await setupLocator();
  await locator<ISettingService>().initService();
  await locator<IAppService>().init();
  await locator<RemoteConfigService>().setupRemoteConfig();

  // Loging seting
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen(
    (record) {
      //test
      // debugPrint(
      //'${record.level.name}: ${record.time}| ${record.loggerName} | message:  ${record.message} ${record.error != null ? "|error: " + record.error.toString() : ""} ${record.stackTrace != null ? "\n|||||stackTrace>>>>>>>>>: " + record.stackTrace.toString() : ""}');

      if (isInDebugMode) {
        debugPrint(
            '${record.level.name}: ${record.time}| ${record.loggerName} | message:  ${record.message} ${record.error != null ? "|error: " + record.error.toString() : ""} ${record.stackTrace != null ? "\n|||||stackTrace>>>>>>>>>: " + record.stackTrace.toString() : ""}');
      } else {
        if (record.level == Level.SEVERE) {
          //sendReport(record.error, record.stackTrace);
        }
      }
    },
  );

  // Capture error on flutter
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      // In development mode simplyflu print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    runApp(new MainApp());
  }, onError: (error, stackTrace) async {
    await locator<IReportService>().sendUncaughtError(error, stackTrace);
  });
}
