import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/settings/setting_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';

import 'new_login_page.dart';

class MainMenuDrawer extends StatelessWidget {
  final _appVm = locator<IAppService>();
  @override
  Widget build(BuildContext context) {
    // Build listMenu
    var groupIds =
        _appVm.getAllMenu().map((f) => f.groupId).toList().toSet().toList();

    List<Widget> menuUi = groupIds.map((f) {
      var group =
          _appVm.menuGroups.firstWhere((gr) => f == gr.id, orElse: () => null);
      var groupChild = _appVm.getAllMenu().where((menu) => menu.groupId == f);
      return ExpansionTile(
        leading: group.icon,
        title: Text("${group.name}"),
        children: <Widget>[
          ...groupChild?.map((child) => ListTile(
                title: Text("${child.label}"),
                onTap: () {
                  Navigator.pushNamed(context, child.routeName);
                },
              )),
        ],
      );
    }).toList();

    return ScopedModelDescendant<IAppService>(
      builder: (ctx, child, vm) {
        return new Drawer(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text("${_appVm.loginUser?.fullName ?? ""}"),
                      accountEmail:
                          Text("${_appVm.loginUser?.companyName ?? ""}"),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(
                            _appVm.loginUser?.avatar ?? "images/no_image.png"),
                      ),
                      onDetailsPressed: () {},
                    ),
                    ...menuUi,
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text("Cài đặt"),
                      onTap: () {
                        Navigator.pushNamed(context, SettingPage.routeName);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text("Đăng xuất"),
                      onTap: () async {
                        // Đăng xuất
                        await locator<IAppService>().logout();
                        Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(builder: (context) {
                          return new NewLoginPage();
                        }));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
