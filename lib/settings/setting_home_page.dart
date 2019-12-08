import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';

class SettingHomePage extends StatefulWidget {
  @override
  _SettingHomePageState createState() => _SettingHomePageState();
}

class _SettingHomePageState extends State<SettingHomePage> {
  var _setting = locator<ISettingService>();

  get homeSelectGroupValue =>
      _setting.isShowAllMenuInHomePage ? "all" : "general";
  set homeSelectGroupValue(String value) {
    if (value == "all") {
      _setting.isShowAllMenuInHomePage = true;
    } else if (value == "general") {
      _setting.isShowAllMenuInHomePage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt trang chủ"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        ListTile(
          title: Text("Trên trang chủ"),
          subtitle: Column(
            children: <Widget>[
              RadioListTile<String>(
                title: Text("Hiện danh sách chức năng tùy chọn"),
                value: "general",
                groupValue: homeSelectGroupValue,
                onChanged: (value) {
                  setState(
                    () {
                      homeSelectGroupValue = value;
                    },
                  );
                },
              ),
              RadioListTile<String>(
                title: Text("Hiện toàn bộ chức năng"),
                value: "all",
                groupValue: homeSelectGroupValue,
                onChanged: (value) {
                  setState(() {
                    homeSelectGroupValue = value;
                  });
                },
              ),
            ],
          ),
        ),
//        Divider(),
//        ListTile(
//          title: Text("Sắp xếp chức năng tùy chọn ở trang chủ"),
//          trailing: Icon(Icons.chevron_right),
//        ),
        Divider(),
        SwitchListTile.adaptive(
          title: Text("Nhóm chức năng theo danh mục"),
          subtitle: Text(
              "Nhóm chức năng có chung thư mục (Bán hàng facebook, Bán hàng, Danh mục)"),
          value: _setting.isShowGroupHeaderOnHome,
          onChanged: (value) {
            setState(() {
              _setting.isShowGroupHeaderOnHome = value;
            });
          },
        ),
        Divider(),
      ],
    );
  }
}
