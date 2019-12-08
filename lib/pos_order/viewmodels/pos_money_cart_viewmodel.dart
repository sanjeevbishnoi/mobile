import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosMoneyCartViewModel extends ViewModelBase {
  DialogService _dialog;

  PosMoneyCartViewModel({DialogService dialogService}) {
    _dialog = dialogService ?? locator<DialogService>();
  }

  Partners _partner = Partners();
  double tongTien = 0;
  int chietKhau = 0;
  double tienGiam = 0;
  int cachThucGiam = 0;
  double tongTienChietKhau = 0;
  double tongTienGiamTien = 0;

  Partners get partner => _partner;
  set partner(Partners value) {
    _partner = value;
    notifyListeners();
  }

  void changeDiscountPrice(int value) {
    cachThucGiam = value;
    notifyListeners();
  }

  void handleGiamChietKhau(String value) {
    chietKhau = value == "" ? 0 : int.parse(value.replaceAll(".", ""));
    if (chietKhau < 0) {
      chietKhau = 0;
    } else if (chietKhau > 100) {
      chietKhau = 100;
    }
    tongTienChietKhau = tongTien * (1 - chietKhau / 100);
    notifyListeners();
  }

  void handleGiamTien(String value) {
    tienGiam = value == "" ? 0 : double.parse(value.replaceAll(".", ""));
    if (tienGiam > tongTien) {
      tongTienGiamTien = 0;
    } else {
      tongTienGiamTien = tongTien - tienGiam;
    }
    notifyListeners();
  }

  void updateTongTien(double tong) {
    tongTien = tong;
    tongTienChietKhau = tong;
    tongTienGiamTien = tong;
    notifyListeners();
  }

  void notifyErrorPayment() {
    _dialog.showNotify(title: "Thông báo", message: "Bạn chưa chọn khách hàng");
  }
}
