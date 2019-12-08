import 'package:logging/logging.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import '../../app_service_locator.dart';

class PartnerInfoViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("PartnerInfoViewModel");

  PartnerInfoViewModel({ITposApiService tposApiService})
      : _tposApi = tposApiService ?? locator<ITposApiService>();

  Partner _partner = new Partner();

  Partner get partner => _partner;

  set partner(Partner value) {
    _partner = value;
    notifyListeners();
  }

  List<CreditDebitCustomerDetail> creditDebitCustomerDetails;
  PartnerRevenue partnerRevenue = new PartnerRevenue();

  // Lọc
  int take = 100;
  int skip = 0;
  var page = 1;
  var pageSize = 100;

  Future<bool> loadPartner() async {
    try {
      partner = await _tposApi.loadPartner(partner.id);
      return true;
    } catch (ex, stack) {
      _log.severe("loadPartner fail", ex, stack);
      onDialogMessageAdd(
        (OldDialogMessage.error(
          "Load dữ liệu thất bại",
          ex.toString(),
        )),
      );
    }
    return false;
  }

  Future<bool> loadPartnerRevenue() async {
    try {
      partnerRevenue = await _tposApi.getPartnerRevenue(partner.id);
      notifyListeners();
      return true;
    } catch (ex, stack) {
      _log.severe("load fail", ex, stack);
      onDialogMessageAdd(
        (OldDialogMessage.error(
          "Load dữ liệu thất bại",
          ex.toString(),
        )),
      );
      return false;
    }
  }

  Future<bool> loadCreditDebitCustomerDetail() async {
    try {
      creditDebitCustomerDetails =
          await _tposApi.getCreditDebitCustomerDetail(partner.id, take, skip);
      notifyListeners();
      return true;
    } catch (ex, stack) {
      _log.severe("loadCreditDebitCustomerDetail fail", ex, stack);
      onDialogMessageAdd(
        (OldDialogMessage.error(
          "Load dữ liệu thất bại",
          ex.toString(),
        )),
      );
    }
    return false;
  }

  // update partner status
  Future updatePartnerStatus(String status, String statusText) async {
    partner.status = status;
    partner.statusText = statusText;
    try {
      onStateAdd(true, message: "Đang tải..");
      _tposApi.updatePartnerStatus(
          partner.id, "${partner.status}_${partner.statusText}");
      notifyListeners();
      onStateAdd(false);
    } catch (ex, stack) {
      _log.severe("updateParterStatus fail", ex, stack);
      onDialogMessageAdd(
        (OldDialogMessage.error(
          "Đã xảy ra lỗi",
          ex.toString(),
        )),
      );
    }
  }

  Future<void> initCommand() async {
    onStateAdd(true, message: "Đang tải..");
    await loadPartner();
    await loadPartnerRevenue();
    await loadCreditDebitCustomerDetail();
    onStateAdd(false);
  }
}
