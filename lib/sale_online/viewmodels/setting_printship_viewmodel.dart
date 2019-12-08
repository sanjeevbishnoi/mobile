import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

class SettingPrintShipViewModel extends ViewModel {
  ISettingService _setting;
  ITposApiService _tposApi;
  DialogService _dialog;
  Logger _log = new Logger("SettingPrintShipViewModel");
  SettingPrintShipViewModel(
      {ISettingService setting,
      ITposApiService tposApi,
      DialogService dialog}) {
    _setting = setting ?? locator<ISettingService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
    _dialog = dialog ?? locator<DialogService>();
  }

  String _selectedPrintName;
  PrinterDevice _selectedPrintDevice;
  String _customTemplate;
  CompanyConfig _compnayConfig;
  List<PrintTemplate> _supportTemplates;

  ISettingService get setting => _setting;

  PrinterConfig get webPrinterConfig => _compnayConfig?.printerConfigs
      ?.firstWhere((f) => f.code == "08", orElse: () => null);

  String get selectedPrintName => _selectedPrintName;
  PrinterDevice get selectedPrintDevice => _selectedPrintDevice;
  String get printerType => _selectedPrintDevice?.type;
  String get customTemplate => _customTemplate;
  List<PrintTemplate> get supportTemplates => _supportTemplates;

  Future<void> initCommand() async {
    onStateAdd(true, message: "Đang tải...");
    // Refresh print info
    _selectedPrintName = _setting.shipPrinterName;
    _selectedPrintDevice = _setting.printers
        .firstWhere((f) => f.name == _selectedPrintName, orElse: () => null);
    _customTemplate = _setting.shipSize;
    _supportTemplates = _setting.getSuportPrintTemplateByPrinterType(
        "ship", _selectedPrintDevice.type);
    if (_supportTemplates.any((f) => f.code == _setting.shipSize)) {
      _customTemplate = _setting.shipSize;
    } else {
      _customTemplate = _supportTemplates.first?.code;
    }

    try {
      await _loadPrinterConfig();
    } catch (e) {}
    onStateAdd(false);
    notifyListeners();
  }

  Future<void> _loadPrinterConfig() async {
    _compnayConfig = await _tposApi.getCompanyConfig();
  }

  /// Chọn máy in
  Future<void> setPrinterCommand(PrinterDevice printDevice) async {
    this._selectedPrintDevice = printDevice;
    this._selectedPrintName = printDevice.name;
    // Tìm mẫu in hỗ trợ
    _supportTemplates = _setting.getSuportPrintTemplateByPrinterType(
        "ship", _selectedPrintDevice.type);
    if (_supportTemplates.any((f) => f.code == _setting.shipSize)) {
      _customTemplate = _setting.shipSize;
    } else {
      _customTemplate = _supportTemplates.first?.code;
    }
    notifyListeners();
  }

  // Chọn mẫu in A4, A5, BILL80
  Future<void> setPrinterTemplateCommand(String template) async {
    _customTemplate = template;
    notifyListeners();
  }

  Future<bool> saveCommand() async {
    onStateAdd(true, message: "Đang lưu...");
    try {
      _setting.shipPrinterName = this._selectedPrintName;
      _setting.shipSize = this._customTemplate;

      await _tposApi.saveCompanyConfig(_compnayConfig);

      return true;
    } catch (e, s) {
      _log.severe("save ship config", e, s);
      _dialog.showError(error: e);
    }
    onStateAdd(false, message: "Đang lưu...");
    return false;
  }
}
