import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';

class AppPermissionUi extends StatelessWidget {
  final String permissionName;
  final Widget child;
  AppPermissionUi({this.permissionName, this.child});
  @override
  Widget build(BuildContext context) {
    //Check permission
    bool permisson = locator<IAppService>().getWebPermission(permissionName);
    if (permisson)
      return child;
    else
      return Stack(
        children: <Widget>[
          AbsorbPointer(
            absorbing: !permisson,
            child: Center(child: child),
          ),
        ],
      );
  }
}
