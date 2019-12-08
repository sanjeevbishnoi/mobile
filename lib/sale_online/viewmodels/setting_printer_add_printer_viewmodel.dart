import 'package:tpos_mobile/sale_online/models/app_model.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

class SettingPrinterAddPrinterViewModel extends ViewModel {
  PrinterType _selectedPrinterType;
  bool isDiscovering = false;
  final List<PrinterDevice> _printers = new List<PrinterDevice>();
  PrinterDevice _selectedPrinterDevice;
  PrinterDevice _newDevice;
  bool _isManual = false;

  List<PrinterDevice> get printers => _printers;
  PrinterType get selectedPrinterType => _selectedPrinterType;
  PrinterDevice get selectedPrinterDevice => _selectedPrinterDevice;
  PrinterDevice get newDevice => _selectedPrinterDevice;

  bool get isManual => _isManual;

  set selectedPrinterType(PrinterType value) {
    var oldValue = _selectedPrinterType;
    _selectedPrinterType = value;
    if (value?.code != oldValue?.code) {
      _selectedPrinterDevice = null;
      _newDevice = null;
      _printers.clear();
      discoveryPrinterCommand();
      notifyListeners();
    }
  }

  void discoveryPrinterCommand() {
    if (_selectedPrinterType == null) return;
    if (_selectedPrinterType.code == "esc_pos") {
      _findPrinter(9100);
    }

    if (_selectedPrinterType.code == "tpos_printer") {
      _findPrinter(8123);
    }
  }

  void setSelectedPrinterDeviceCommand(PrinterDevice value) {
    var oldValue = _selectedPrinterDevice;
    _selectedPrinterDevice = value;
    if (value != oldValue) {
      if (_newDevice == null) {
        _newDevice = new PrinterDevice();
      }

      _newDevice.ip = value.ip;
      _newDevice.port = selectedPrinterType.port;
      _isManual = false;
      notifyListeners();
    }
  }

  void setIsManual(bool value) {
    if (value == true) {
      _isManual = value;
      _selectedPrinterDevice = null;
      notifyListeners();
    }
  }

  void _findPrinter(int port) {
    isDiscovering = true;
    _printers.clear();
    final stream = NetworkAnalyzer.discover("192.168.1", port);
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        _printers.add(new PrinterDevice(ip: addr.ip, port: port));
        notifyListeners();
      }
    })
      ..onDone(() {
        // Add Default param
        isDiscovering = false;
        notifyListeners();
      })
      ..onError((dynamic e) {
//        final snackBar = SnackBar(
//            content: Text('Unexpected exception', textAlign: TextAlign.center));
      });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
