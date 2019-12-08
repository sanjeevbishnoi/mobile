import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';

import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models/get_facebook_partner_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_facebook_post_summary_user.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class SaleOnlineFacebookPostSummaryViewModel extends ViewModel {
  Logger _log = new Logger("SaleOnlineFacebookPostSummaryViewModel");
  ITposApiService _tposApi;
  IFacebookApiService _fbApi;
  String _postId;
  CRMTeam _crmTeam;

  SaleOnlineFacebookPostSummaryViewModel(
      {SaleOnlineFacebookPostSummaryViewModel tposApi,
      IFacebookApiService fbApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _fbApi = fbApi ?? locator<IFacebookApiService>();
  }

  SaleOnlineFacebookPostSummaryUser _summary;

  List<DetailItemModel> _details;
  Map<String, GetFacebookPartnerResult> _partners;

  SaleOnlineFacebookPostSummaryUser get summary => _summary;
  List<DetailItemModel> get details => _details;
  Map<String, GetFacebookPartnerResult> get partners => _partners;

  void init({
    @required String postId,
    @required CRMTeam crmTeam,
  }) {
    assert(postId != null);
    this._postId = postId;
    this._crmTeam = crmTeam;
  }

  GetFacebookPartnerResult getPartner(String uid) {
    if (_partners != null) {
      return _partners[uid];
    }
    return null;
  }

  Future<void> initCommand() async {
    assert(_postId != null);
    onStateAdd(true, message: "Đang tải...");
    try {
      await _loadSummary();
      notifyListeners();
    } catch (e, s) {
      _log.severe("", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", "", error: e));
    }
    onStateAdd(false, message: "Đang tải...");
    notifyListeners();
  }

  Future<void> _loadSummary() async {
    _summary = await _tposApi.getSaleOnlineFacebookPostSummaryUser(_postId);
    _partners = await _tposApi.getFacebookPartners(_crmTeam.id); //Chú ý
  }

  void refreshCommand() async {
    await initCommand();
  }
}

class DetailItemModel {
  Users user;
  GetFacebookPartnerResult partner;

  DetailItemModel({this.user, this.partner});
}
