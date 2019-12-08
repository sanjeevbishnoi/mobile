import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';

import '../service_test_base.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen(
    (record) {
      print(
          '${record.level.name}: ${record.time}| ${record.loggerName} | message:  ${record.message} ${record.error != null ? "|error: " + record.error.toString() : ""} ${record.stackTrace != null ? "\n|||||stackTrace>>>>>>>>>: " + record.stackTrace.toString() : ""}');
    },
  );

  test("getProductSearchByIdTest", _getProductSearchById);
  test("getFastSaleOrderDefaultTest", _getFastSaleOrderDefault);
  test("getFastSaleOrderPrintDataAsHtml", _getFastSaleOrderPrintDataAsHtml);
  test("getCompanyPrinterConfig", _getCompanyConfigTest);
  test("saveCompanyConfigTest", _saveCompanyConfigTest);
  test("getMailTemplatesTest", _getMailTemplatesTest);
}

Future _getProductSearchById() async {
  // Có giữ liệu
  int testProductId = 11949;
  OdataResult<Product> t = await tposApi.getProductSearchById(testProductId);
  expect(t.value.id, equals(testProductId));

  // Không có kết quả
  OdataResult<Product> t1 = await tposApi.getProductSearchById(119494);
  expect(t1.value == null, true);
}

Future _getFastSaleOrderDefault() async {}

Future _getFastSaleOrderPrintDataAsHtml() async {
  var content = await tposApi.getFastSaleOrderPrintDataAsHtml(
      fastSaleOrderId: 4026, carrierId: 2, type: "ship");
  print(content);
}

Future _getCompanyConfigTest() async {
  var config = await tposApi.getCompanyConfig();
  expect(config, isNotNull);
  expect(config.printerConfigs, isNotNull);
  expect(config.printerConfigs.length, equals(11));
}

Future _saveCompanyConfigTest() async {
  var config = await tposApi.getCompanyConfig();
  var saveConfig = await tposApi.saveCompanyConfig(config);

  expect(config, isNotNull);
  expect(saveConfig, isNotNull);
  expect(saveConfig.printerConfigs.length, saveConfig.printerConfigs.length);
}

Future _getMailTemplatesTest() async {
  var templates = await tposApi.getMailTemplates();
  expect(templates, isNotNull);
}
