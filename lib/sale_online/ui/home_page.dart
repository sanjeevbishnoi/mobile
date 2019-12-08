/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/4/19 6:25 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/4/19 10:26 AM
 *
 */

import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:tpos_mobile/app_service_locator.dart';

import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/sale_online/services/remote_config_service.dart';

import 'package:flutter/cupertino.dart';
import 'package:tpos_mobile/sale_online/ui/menu_search.dart';
import 'package:tpos_mobile/sale_online/viewmodels/HomeViewModel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/string_resources.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  HomeViewModel homeViewModel = locator<HomeViewModel>();
  var _remoteConfig = locator<RemoteConfigService>();
  var _appService = locator<IAppService>();
  int _bottomNavigatinBarIndex = 0;

  @override
  void initState() {
    homeViewModel.initCommand().then((value) async {
      await Future.delayed(Duration(seconds: 2));
      var updateInfo = await homeViewModel.checkForUpdateNewCommand();
      if (updateInfo != null) {
        _notifyUpdate(updateInfo);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    locator<ISettingService>().lastAppVersion = locator<IAppService>().version;
    homeViewModel.dispose();
    super.dispose();
  }

  void _notifyUpdate(UpdateNotify updateInfo) {
    if (context != null)
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: Duration(milliseconds: 500),
        barrierColor: Colors.grey.withOpacity(0.5),
        pageBuilder: (ctx, _, __) => AlertDialog(
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 0, color: Colors.white70),
          ),
          title: Text(updateInfo.notifyTitle
              .replaceAll("_version", updateInfo.version)),
          content: Text(
              "${updateInfo.notifyContent.replaceAll("_version", updateInfo.version)}"),
          actions: <Widget>[
            FlatButton(
              child: Text("ĐỂ SAU"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            FlatButton(
              child: Text(
                "CẬP NHẬT NGAY",
              ),
              onPressed: () async {
                StoreRedirect.redirect(
                    androidAppId: ANDROID_APP_ID, iOSAppId: APPLE_APP_ID);
              },
            )
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ScopedModel<HomeViewModel>(
        model: homeViewModel,
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          resizeToAvoidBottomInset: false,
          body: ScopedModelDescendant<IAppService>(
            builder: (context, child, model) => HomeBody(
              menus: homeViewModel.isShowAllMenu
                  ? _appService.getAllMenu()
                  : _appService.getHomeMenu(),
              parentContext: this.context,
              vm: homeViewModel,
              onUpdate: () {
                setState(
                  () {},
                );
              },
            ),
          ),
        ),
      ),
      onWillPop: () async {
        _showExitConfirm(context);
        return true;
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class HomeBody extends StatelessWidget {
  final parentContext;
  final buttonColor = Colors.green;
  final buttonTextStyle = TextStyle(color: Colors.white);
  HomeBody(
      {this.onUpdate, this.context, this.menus, this.parentContext, this.vm});
  final _setting = locator<ISettingService>();
  final _app = locator<IAppService>();
  final Function onUpdate;
  final BuildContext context;
  final List<MenuItem> menus;
  final HomeViewModel vm;

  static void _exitApp(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    int quickMenuColumn = 4;

    if (mediaQuery.orientation == Orientation.portrait) {
      if (width < 700) {
        quickMenuColumn = 4;
      } else {
        quickMenuColumn = 6;
      }
    } else {
      if (width < 900) {
        quickMenuColumn = 6;
      } else {
        quickMenuColumn = 9;
      }
    }

    final itemWidth = width / quickMenuColumn;

    final Color searchBackgroundColor = Color.fromRGBO(78, 130, 73, 1);
    final Color searchTextColor = Colors.white70;
    final Color searchBorderColor = Color.fromRGBO(78, 140, 73, 1);

    return OrientationBuilder(
      builder: (context, Orientation orient) {
        return RefreshIndicator(
          onRefresh: () async {
            onUpdate();
            return true;
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(parentContext).openDrawer();
                  },
                ),
                backgroundColor: Theme.of(context).primaryColor,
                title: Padding(
                  padding: const EdgeInsets.only(
                      left: 0, right: 0, top: 12, bottom: 10),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: searchBackgroundColor,
                        borderRadius: BorderRadius.circular(25),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                            color: searchBorderColor,
                            width: 1,
                            style: BorderStyle.solid),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Tìm kiếm chức năng",
                          style: TextStyle(fontSize: 13, color: Colors.white54),
                        ),
                      ),
                    ),
                    onTap: () async {
                      await showSearch(
                        context: context,
                        delegate: MenuSearchDelegate(),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      _showExitConfirm(context);
                    },
                  )
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // Appbar custome
                    SizedBox(
                      height: 20,
                    ),
// Thông báo update
                    if (_setting.lastAppVersion != "" &&
                        _setting.lastAppVersion != _app.version) ...[
                      HomeNotify(
                        icon: Icon(Icons.info),
                        title: Text(
                          "Ứng dụng đã được cập nhật",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onClosed: () {
                          _setting.lastAppVersion = _app.version;
                          if (onUpdate != null) onUpdate();
                        },
                        content: Wrap(
                          children: <Widget>[
                            Text(
                                "Hiện tại, bạn đã được cập nhật lên phiên bản mới nhất ${_app.version} . Nếu có bất kì góp ý nào xin vui lòng thêm trong Cá nhân-> Góp ý. Xin cảm ơn"),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],

                    // Thông báo ứng dụng hết hạn
                    if (_app.companyCurrentInfo != null &&
                        _app.companyCurrentInfo.expiredIn != null &&
                        _app.companyCurrentInfo.expiredIn > 0 &&
                        _app.companyCurrentInfo.expiredIn < 345600000)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(color: Colors.orange, width: 0.5),
                            color: Colors.white),
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.warning,
                                color: Colors.yellow,
                                size: 50,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Chỉ còn ${_app.companyCurrentInfo.expiredInShort} ngày sử dụng!",
                                      style: const TextStyle(
                                          fontSize: 19, color: Colors.red),
                                    ),
                                  ),
                                  Text(
                                    "Tên miền ${_setting.shopUrl} của bạn sẽ sớm hết hạn trong ${_app.companyCurrentInfo.expiredInShort} ngày nữa. Vui lòng gia hạn thanh toán sớm để công việc kinh doanh không bị gián đoạn",
                                    style:
                                        TextStyle(color: Colors.orangeAccent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    ..._buildHomeMenu(itemWidth: itemWidth),

                    if (_app.lastError != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Đã có lỗi xảy ra!",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "${_app.lastError}",
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            RaisedButton(
                              child: Text("Tải lại"),
                              textColor: Colors.white,
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                _app.initCommand();
                              },
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Notify
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    (_setting.isHideHomePageSuggess || 1 == 1)
                        ? SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.orangeAccent),
                              child: Column(
                                children: <Widget>[
                                  Wrap(
                                    children: <Widget>[
                                      Text(
                                          "Bạn hiện có thể tùy chỉnh các chức năng hiển thị tại trang chủ để truy cập nhanh các  tính năng cần thiết. Nhấn nút"),
                                      Icon(Icons.edit),
                                      Text(
                                          " ở góc trên bên phải để tới trang cài đặt"),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: SizedBox(),
                                      ),
                                      FlatButton(
                                        textColor: Colors.blue,
                                        onPressed: () {
                                          _setting.isHideHomePageSuggess = true;
                                          if (onUpdate != null) onUpdate();
                                        },
                                        child: Text(
                                          "Đã hiểu không hiện lại lần sau",
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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

  List<Widget> _buildHomeMenu({double itemWidth}) {
    var items = List<Widget>();

    //Add header
    items.add(
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 0, bottom: 10),
        child: new Row(
          children: <Widget>[
            Expanded(
                child: Text(!_setting.isShowAllMenuInHomePage
                    ? "THƯỜNG DÙNG"
                    : "TẤT CẢ")),
            Divider(),
            FlatButton.icon(
              textColor: Colors.blue,
              icon: Icon(!_setting.isShowAllMenuInHomePage
                  ? Icons.expand_more
                  : Icons.expand_less),
              label: Text(
                !_setting.isShowAllMenuInHomePage ? "Tất cả..." : "Ít hơn",
              ),
              onPressed: () {
                vm.isShowAllMenu = !_setting.isShowAllMenuInHomePage;
                onUpdate();
              },
            ),
          ],
        ),
      ),
    );

    //if is group is not true
    if (!_setting.isShowGroupHeaderOnHome) {
      items.add(
        _buildGridMenu(menus, itemWidth),
      );
      return items;
    }

    var groupIds = menus.map((f) => f.groupId).toList().toSet().toList();

    groupIds.forEach(
      (groupId) {
        var menuFromGroups = menus
            .where(
              (f) => f.groupId == groupId,
            )
            .toList();

        var group = _app.menuGroups.firstWhere((f) => f.id == groupId);

        items.add(
          new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Header
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  "${group.name.toUpperCase()}",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              _buildGridMenu(menuFromGroups, itemWidth),
            ],
          ),
        );
      },
    );
    //
    return items;
  }

  Widget _buildGridMenu(List<MenuItem> items, double itemWidth) {
    return GridView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 115),
      itemCount: items.length,
      itemBuilder: (context, index) {
        var menu = items[index];
        return MenuItemCircle(
          icon: menu.icon,
          label: menu.label,
          routeName: menu.routeName,
          visible: menu.visible,
          categoryId: menu.groupId,
          onPressed: () {
            Navigator.pushNamed(context, menu.routeName);
            _app.addMenuSuggest(menu.id);
          },
          onLongPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      ListTile(
                        title: Text("Xóa khỏi danh sách thường dùng"),
                        leading: Icon(Icons.delete_forever),
                        onTap: () {},
                      )
                    ],
                  );
                });
          },
          width: itemWidth,
        );
      },
    );
  }
}

class HomeNotify extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget content;
  final Function onClosed;

  HomeNotify({this.icon, this.title, this.content, this.onClosed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.green,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                icon ?? Icon(Icons.info),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: title ??
                      Text(
                        "Ứng dụng đã được cập nhật!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 15,
                    ),
                  ),
                  onTap: onClosed ?? null,
                ),
              ],
            ),
            content ?? SizedBox(),
          ],
        ),
      ),
    );
  }
}

void _showExitConfirm(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade500, width: 0.5)),
          title: Text("Thoát ứng dụng"),
          content: Text("Bạn có muốn thoát khỏi app TPOS không?"),
          actions: <Widget>[
            FlatButton(
              child: Text("ĐỂ TÔI Ở LẠI"),
              color: Colors.white,
              textColor: Colors.green,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.green,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              color: Colors.green,
              textColor: Colors.white,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.green,
                ),
              ),
              child: Text("ĐỒNG Ý"),
              onPressed: () {
                Navigator.pop(context);
                exit(0);
              },
            ),
          ],
        );
      });
}

class MenuItemCircle extends StatelessWidget {
  final Widget icon;
  final String label;
  final Function onPressed;
  final Function onLongPressed;
  final String routeName;
  final bool visible;
  final double width;
  final String categoryId;
  MenuItemCircle(
      {this.icon,
      this.label,
      this.onPressed,
      this.onLongPressed,
      this.routeName,
      this.visible = true,
      this.width,
      this.categoryId});
  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade100;
    List<Color> getGradient() {
      switch (categoryId) {
        case "1":
          borderColor = Colors.indigo.shade100;
          return [
            Colors.indigo.shade100,
            Colors.grey.shade50,
          ];

          break;
        case "2":
          borderColor = Colors.blue.shade100;
          return [
            Colors.blue.shade100,
            Colors.grey.shade100,
          ];
          break;
        case "3":
          borderColor = Colors.deepOrange.shade200;
          return [
            Colors.deepOrange.shade100,
            Colors.grey.shade100,
          ];
          break;
        case "4":
          borderColor = Colors.green.shade200;
          return [
            Colors.green.shade100,
            Colors.grey.shade100,
          ];
          break;
        default:
          borderColor = Colors.green.shade200;
          return [
            Colors.green.shade100,
            Colors.grey.shade100,
          ];
      }
    }

    return InkWell(
      onTap: onPressed ?? null,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100, width: 0.1)),
        padding: EdgeInsets.only(left: 3, top: 10, bottom: 5, right: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 0.1, color: borderColor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.1, 1],
                  colors: getGradient(),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: icon,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: AutoSizeText(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87),
                  overflow: TextOverflow.fade,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
