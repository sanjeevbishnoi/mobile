/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:logging/logging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/src/tpos_apis/models/SaleOnlineLiveCampaign.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class SaleOnlineLiveCampaignViewModel extends Model {
  //log
  final log = new Logger("SaleOnlineLiveCampaignViewModel");
  ITposApiService _tposApi;
  SaleOnlineLiveCampaignViewModel({ITposApiService tposAPi}) {
    _tposApi = tposAPi ?? locator<ITposApiService>();
  }
  List<SaleOnlineLiveCampaign> saleOnlineLiveCampaign =
      new List<SaleOnlineLiveCampaign>();
  getSaleOnlineLiveCampaign() async {
    try {
      saleOnlineLiveCampaign = await _tposApi.getSaleOnlineLiveCampaign();
      notifyListeners();
    } catch (ex, stack) {
      log.severe("getSaleOnlineLiveCampaign fail", ex, stack);
      print("Loi getSaleLive " + ex.toString());
    }
  }
}
