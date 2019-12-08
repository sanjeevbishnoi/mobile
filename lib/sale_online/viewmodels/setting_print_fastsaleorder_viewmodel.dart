import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

class SettingPrintFastSaleOrderViewModel extends ViewModel {
  ISettingService _setting;
  ITposApiService _tposApi;
  Logger _log = new Logger("SettingPrintFastSaleOrderViewModel");
  SettingPrintFastSaleOrderViewModel(
      {ISettingService setting, ITposApiService tposApi}) {
    _setting = setting ?? locator<ISettingService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  String _selectedPrintName;
  PrinterDevice _selectedPrintDevice;
  String _customTemplate;
  CompanyConfig _compnayConfig;
  List<PrintTemplate> _supportTemplates;

  PrinterConfig get webPrinterConfig => _compnayConfig?.printerConfigs
      ?.firstWhere((f) => f.code == "01", orElse: () => null);

  String get selectedPrintName => _selectedPrintName;
  PrinterDevice get selectedPrintDevice => _selectedPrintDevice;
  String get printerType => _selectedPrintDevice?.type;
  String get customTemplate => _customTemplate;
  List<PrintTemplate> get supportTemplates => _supportTemplates;

  Future<void> initCommand() async {
    onStateAdd(true, message: "Đang tải...");
    // Refresh print info
    _selectedPrintName = _setting.fastSaleOrderInvoicePrinterName;
    _selectedPrintDevice = _setting.printers
        .firstWhere((f) => f.name == _selectedPrintName, orElse: () => null);
    _customTemplate = _setting.fastSaleOrderInvoicePrintSize;
    _supportTemplates = _setting.getSuportPrintTemplateByPrinterType(
        "fast_sale_order", _selectedPrintDevice.type);
    if (_supportTemplates
            ?.any((f) => f.code == _setting.fastSaleOrderInvoicePrintSize) ==
        true) {
      _customTemplate = _setting.fastSaleOrderInvoicePrintSize;
    } else {
      _customTemplate = _supportTemplates?.first?.code;
    }

    try {
      await _loadPrinterConfig();
    } catch (e, s) {
      _log.severe("", e, s);
    }
    onStateAdd(false);
    notifyListeners();
  }

  Future<void> _loadPrinterConfig() async {
    _compnayConfig = await _tposApi.getCompanyConfig();
  }

  /// Chọn máy in
  void setPrinterCommand(PrinterDevice printDevice) {
    this._selectedPrintDevice = printDevice;
    this._selectedPrintName = printDevice.name;
    // Tìm mẫu in hỗ trợ
    _supportTemplates = _setting.getSuportPrintTemplateByPrinterType(
        "fast_sale_order", _selectedPrintDevice.type);
    if (_supportTemplates?.any((f) => f.code == _setting.shipSize) == true) {
      _customTemplate = _setting.shipSize;
    } else {
      _customTemplate = _supportTemplates?.first?.code;
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
      _setting.fastSaleOrderInvoicePrinterName = this._selectedPrintName;
      _setting.fastSaleOrderInvoicePrintSize = this._customTemplate;

      await _tposApi.saveCompanyConfig(_compnayConfig);
      return true;
    } catch (e, s) {
      _log.severe("save ship config", e, s);
      onDialogMessageAdd(
        OldDialogMessage.error("", "", error: e),
      );
    }
    onStateAdd(false, message: "Đang lưu...");
    return false;
  }
}
