import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/sale_facebook_create_order_setting_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/setting_viewmodel.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';

class SettingPage extends StatefulWidget {
  static final routeName = AppRoute.setting;
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var _vm = locator<SettingViewModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt"),
      ),
      body: ModalWaitingWidget(
        isBusyStream: _vm.isBusyController,
        initBusy: false,
        statusStream: _vm.viewModelStatusController,
        child: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    var divider = new Divider(
      height: 1,
    );
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("Trang chủ"),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, AppRoute.setting_home_page);
          },
        ),
        divider,
        ListTile(
          title: Text("Cấu hình bán hàng online"),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(
                context, SaleFacebookCreateOrderSettingPage.routeName);
          },
        ),
        divider,
        ListTile(
          title: Text("Cấu hình bán hàng nhanh"),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, AppRoute.setting_fast_sale_order);
          },
        ),
        divider,
        ListTile(
          title: Text("Danh sách máy in"),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, AppRoute.setting_printer_list);
          },
        ),
        divider,
        ListTile(
          title: Text("Cấu hình in ấn"),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, AppRoute.setting_printer);
          },
        ),
        divider,
      ],
    );
  }
}
