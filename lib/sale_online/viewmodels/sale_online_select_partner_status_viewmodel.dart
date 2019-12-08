/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_status.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

import '../../app_service_locator.dart';

class SaleOnlineSelectPartnerStatusViewModel extends Model
    implements ViewModelBase {
  //log
  final log = new Logger("SaleOnlineSelectPartnerStatusViewModel");
  ITposApiService _tposApi;

  SaleOnlineSelectPartnerStatusViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  // Status
  List<PartnerStatus> _statuss;

  List<PartnerStatus> get statuss => _statuss;

  set statuss(List<PartnerStatus> value) {
    _statuss = value;
    if (_statussController.isClosed == false) {
      _statussController.sink.add(_statuss);
    }
  }

  BehaviorSubject<List<PartnerStatus>> _statussController =
      new BehaviorSubject();
  Stream<List<PartnerStatus>> get statusStream => _statussController.stream;

  void init() {
    loadStatus();
  }

  Future<void> loadStatus() async {
    try {
      statuss = await _tposApi.getPartnerStatus();
    } catch (ex, stack) {
      log.severe("loadStatus fail", ex, stack);
      _statussController.addError("Đã xảy ra lỗi. vui lòng thử lại");
    }
  }

  @override
  void dispose() {
    _statussController.close();
  }
}
