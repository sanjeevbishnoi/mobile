import 'package:flutter/material.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';

import '../app_service_locator.dart';

class SettingPrinterPage extends StatefulWidget {
  @override
  _SettingPrinterPageState createState() => _SettingPrinterPageState();
}

class _SettingPrinterPageState extends State<SettingPrinterPage> {
  var _setting = locator<ISettingService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cấu hình máy in"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var divider = new Divider(
      height: 1,
    );

    var icon = new Icon(Icons.chevron_right);

    return ListView(
      children: <Widget>[
        //TODO Cấu hình máy in saleonline
//        ListTile(
//          title: Text("Máy in sale online"),
//          subtitle: Text("TposPrinter (192.168.1.113: 8123"),
//          trailing: icon,
//        ),
//        divider,
        ListTile(
          title: Text("Máy in phiếu ship"),
          subtitle: Text("${_setting.shipPrinterName ?? "Chưa chọn máy in"}"),
          trailing: icon,
          onTap: () {
            Navigator.pushNamed(context, AppRoute.setting_printer_edit_option);
          },
        ),

        divider,
        ListTile(
          title: Text("Máy in hóa đơn"),
          subtitle: Text(
              "${_setting.fastSaleOrderInvoicePrinterName ?? "Chưa chọn máy in"}"),
          trailing: icon,
          onTap: () {
            Navigator.pushNamed(
                context, AppRoute.setting_printer_fast_sale_order_option);
          },
        ),
        divider,
      ],
    );
  }
}
