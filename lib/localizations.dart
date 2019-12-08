import 'helpers/tmt.dart';

class Localization {
  static Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'title': "TPOS Quản lý bán hàng",
      'globalDialogInfoTitle': "Thông báo",
      'globalDialogWarningTitle': "Cảnh báo",
      'globalDialogErrorTitle': "Sự cố",
      'globalDialogConfirmTitle': "Xác nhận"
    },
  };

  String get title => _localizedValues[Tmt.locate]["title"];
  String get locate => Tmt.locate;
}
