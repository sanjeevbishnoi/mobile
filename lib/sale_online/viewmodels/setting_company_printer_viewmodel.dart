import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company_config.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class SettingCompanyPrinterViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("SettingCompanyViewModel");
  SettingCompanyPrinterViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  CompanyConfig _config;
  CompanyConfig get config => _config;

  List<PrinterConfig> get printerConfigs => _config?.printerConfigs;
  List<PrinterConfig> get supportPrinterConfig {
    var supportId = ["08"];

    return printerConfigs?.where((f) => supportId.contains(f.code))?.toList();
  }

  void init() async {
    onStateAdd(true);
    _config = await _tposApi.getCompanyConfig();
    onStateAdd(false);
    notifyListeners();
  }

  Future save() async {
    onStateAdd(true);
    try {
      _config = await _tposApi.saveCompanyConfig(_config);
    } catch (e, s) {
      _log.severe("save company config", e, s);
    }
    onStateAdd(false);
  }
}
