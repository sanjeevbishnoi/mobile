import 'package:flutter_test/flutter_test.dart';
import 'package:tpos_mobile/sale_online/viewmodels/setting_company_printer_viewmodel.dart';

import '../service_test/service_test_base.dart';

void main() {
  _vm = new SettingCompanyPrinterViewModel(tposApi: tposApi);
  test("initTest", _initTest);
}

SettingCompanyPrinterViewModel _vm;

Future _initTest() async {
  _vm.init();
  expect(_vm.config, isNotNull);
}
