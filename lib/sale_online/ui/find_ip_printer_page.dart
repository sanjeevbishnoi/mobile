import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/models/app_model.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

class FindIpPrinterPage extends StatefulWidget {
  final isTposPrinterType;
  FindIpPrinterPage({this.isTposPrinterType = true});
  @override
  _FindIpPrinterPageState createState() => _FindIpPrinterPageState();
}

class _FindIpPrinterPageState extends State<FindIpPrinterPage> {
  var _vm = new FindIpPrinterViewModel();
  var _app = locator<IAppService>();

  @override
  void initState() {
    if (widget.isTposPrinterType) {
      _vm.selectedPrinterType =
          _app.avaiablePrinterTypes.firstWhere((f) => f.code == "tpos_printer");
    } else {
      _vm.selectedPrinterType =
          _app.avaiablePrinterTypes.firstWhere((f) => f.code == "esc_pos");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FindIpPrinterViewModel>(
      model: _vm,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    var _textStyle = new TextStyle(fontWeight: FontWeight.bold);
    return SingleChildScrollView(
      child: ScopedModelDescendant<FindIpPrinterViewModel>(
        builder: (context, child, model) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "LOẠI MÁY IN",
                        style: _textStyle.copyWith(
                            fontSize: 12, color: Colors.grey),
                      ),
                      Divider(),
                      DropdownButton<PrinterType>(
                        isExpanded: true,
                        value: _vm.selectedPrinterType,
                        onChanged: (selectedType) {
                          setState(() {
                            _vm.selectedPrinterType = selectedType;
                          });
                        },
                        hint: Text("Chọn loại máy in"),
                        items: _app.avaiablePrinterTypes
                            .map((f) => DropdownMenuItem<PrinterType>(
                                  child: Text(f.name),
                                  value: f,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              if (_vm.selectedPrinterType != null &&
                  (_vm.selectedPrinterType.code == "esc_pos" ||
                      _vm.selectedPrinterType.code == "tpos_printer")) ...[
                SizedBox(
                  height: 10,
                ),
                _buildSelectListLanprinterLayout(),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Chọn máy in lan được tìm tự động
  Widget _buildSelectListLanprinterLayout() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: Row(children: <Widget>[
              Expanded(
                  child: Text(
                "MÁY IN ESC/POS ĐÃ TÌM THẤY:",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )),
              if (_vm.isDiscovering)
                SizedBox(
                  child: CircularProgressIndicator(),
                  height: 20,
                  width: 20,
                ),
              if (!_vm.isDiscovering)
                FlatButton.icon(
                  onPressed: () {
                    _vm.discoveryPrinterCommand();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text("Làm mới"),
                )
            ]),
          ),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: (_vm.printers?.length ?? 0),
            itemBuilder: (context, index) {
              return ListTile(
                selected: _vm.selectedPrinterDevice == _vm.printers[index],
                leading: Checkbox(
                    value: _vm.selectedPrinterDevice == _vm.printers[index],
                    onChanged: (value) {
                      _vm.setSelectedPrinterDeviceCommand(_vm.printers[index]);
                      Navigator.pop(context, _vm.selectedPrinterDevice);
                    }),
                title: Text("${_vm.printers[index].ip}"),
                onTap: () {
                  _vm.setSelectedPrinterDeviceCommand(_vm.printers[index]);
                  Navigator.pop(context, _vm.selectedPrinterDevice);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class FindIpPrinterViewModel extends ViewModel {
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
