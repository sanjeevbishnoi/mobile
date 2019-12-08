/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 3:49 PM
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nam_esc_pos_printer/nam_esc_pos_printer.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/settings/setting_printer_add_printer_page.dart';

class SettingPrinterListPage extends StatefulWidget {
  final String selectedPrinterName;
  final bool isSelectPage;
  SettingPrinterListPage({this.selectedPrinterName, this.isSelectPage = false});
  @override
  _SettingPrinterListPageState createState() => _SettingPrinterListPageState();
}

class _SettingPrinterListPageState extends State<SettingPrinterListPage> {
  final _setting = locator<ISettingService>();

  List<PrinterDevice> _printers;
  @override
  void initState() {
    _printers = _setting.printers;

    super.initState();
  }

  Future _addPrinter() async {
    var printer = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SettingPrinterAddPrinter()));

    if (printer != null) {
      _printers.add(printer);
      _setting.printers = _printers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách máy in"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              _addPrinter();
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_printers.length == 0) {
      return Container(
        padding: EdgeInsets.only(left: 10, top: 30, right: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                "Chưa có máy in nào trong danh sách",
                textAlign: TextAlign.center,
              ),
              FlatButton(
                textColor: Colors.blue,
                child: Text("Nhấp để thêm"),
                onPressed: () {
                  _addPrinter();
                },
              )
            ]),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.isSelectPage)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Text(
              "Vui lòng chọn một trong các máy in sau:",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 17,
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                height: 2,
              );
            },
            itemBuilder: (context, index) {
              return _buildItem(_printers[index]);
            },
            itemCount: _printers.length,
          ),
        ),
      ],
    );
  }

  Widget _buildItem(PrinterDevice item) {
    return ListTile(
      leading: Icon(
        Icons.local_printshop,
        color: Colors.blue,
      ),
      title: Text(item.name),
      subtitle: Text("${item.ip} (port: ${item.port})"),
      trailing: PopupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Text("Sửa"),
              value: "edit",
            ),
            PopupMenuItem(
              enabled: !item.isDefault,
              child: Text("Xóa"),
              value: "delete",
            ),
          ];
        },
        onSelected: (value) async {
          switch (value) {
            case "edit":
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPrinterEditPrinter(device: item),
                ),
              );

              _setting.printers = this._printers;
              break;
            case "delete":
              setState(() {
                _printers.remove(item);
                _setting.printers = this._printers;
              });

              break;
          }
        },
      ),
      selected: item.name == widget.selectedPrinterName ?? "",
      onTap: () {
        if (widget.isSelectPage) {
          Navigator.pop(context, item);
        }
      },
    );
  }
}

class SettingPrinterEditPrinter extends StatefulWidget {
  final PrinterDevice device;
  SettingPrinterEditPrinter({this.device});

  @override
  _SettingPrinterEditPrinterState createState() =>
      _SettingPrinterEditPrinterState();
}

class _SettingPrinterEditPrinterState extends State<SettingPrinterEditPrinter> {
  final _nameController = new TextEditingController();
  final _ipController = new TextEditingController();
  final _portController = new TextEditingController();
  final _noteController = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _nameController.text = widget.device.name;
    _ipController.text = widget.device.ip;
    _portController.text = widget.device.port.toString();
    _noteController.text = widget.device.note;
    super.initState();
  }

  void _save() {
    widget.device.ip = _ipController.text.trim();
    widget.device.port = int.parse(_portController.text.trim());
    widget.device.name = _nameController.text.trim();
    widget.device.note = _noteController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sửa thông tin máy in"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _save();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var _textStyle = new TextStyle(fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              style: _textStyle,
              decoration: InputDecoration(
                  labelText: "Đặt tên cho máy in", hintText: "VD: Máy in bill"),
              validator: (value) {
                if (value.isEmpty) {
                  return "Vui lòng đặt tên cho máy in";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ipController,
              style: _textStyle,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp("[\\d|\.]")),
              ],
              decoration: InputDecoration(
                  labelText: "IP:", hintText: "VD: 192.168.1.100"),
              validator: (value) {
                if (value.isEmpty) {
                  return "Vui lòng nhập địa chỉ IP";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _portController,
              style: _textStyle,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              decoration:
                  InputDecoration(labelText: "Port:", hintText: "VD: 9100"),
              validator: (value) {
                if (value.isEmpty) {
                  return "Vui lòng nhập PORT";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: "Ghi chú:", hintText: ""),
            ),
            DropdownButton(
              value: widget.device.profileName,
              isExpanded: true,
              hint: Text("Chọn cấu hình"),
              items: printerProfiles.keys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text("$key"),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  widget.device.profileName = value;
                });
              },
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: widget.device.isImageRasterPrint ?? false,
                  onChanged: (value) {
                    setState(() {
                      widget.device.isImageRasterPrint = value;
                    });
                  },
                ),
                Text("Chế độ in hình raster (Chọn nếu bill in ra bị trắng)")
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                textColor: Colors.white,
                child: Text("LƯU & ĐÓNG"),
                onPressed: () {
                  _save();
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
