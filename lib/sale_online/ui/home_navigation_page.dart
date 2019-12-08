import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app.dart';
import 'package:tpos_mobile/sale_online/ui/home_page.dart';
import 'package:tpos_mobile/sale_online/ui/menu_drawer.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page.dart';
import 'package:tpos_mobile/sale_online/ui/ui.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/notification_list_viewmodel.dart';

import '../../app_service_locator.dart';
import 'home_personal_page.dart';
import 'notification_list_page.dart';

class HomeNavigationPage extends StatefulWidget {
  @override
  _HomeNavigationPageState createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _bottomNavigatinBarIndex = 0;
  final _appVm = locator<IAppService>();
  final _notificationVm = locator<NotificationListViewModel>();

  @override
  void initState() {
    _appVm.initCommand();

    super.initState();
  }

  void _showExitConfirm(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.green.shade200, width: 0.5)),
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    App.width = media.size.width;
    App.height = media.size.height;
    return ScopedModel<IAppService>(
      model: _appVm,
      child: WillPopScope(
        onWillPop: () async {
          await _showExitConfirm(context);
          return null;
        },
        child: UIViewModelBase(
          viewModel: _appVm,
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            resizeToAvoidBottomInset: false,
            body: _buildBody(),
            drawer: MainMenuDrawer(),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _bottomNavigatinBarIndex,
                onTap: (index) {
                  setState(() {
                    _bottomNavigatinBarIndex = index;
                  });
                },
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.buromobelexperte),
                      backgroundColor: Colors.green,
                      title: Text("Chức năng")),
                  BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.chartBar),
                    backgroundColor: Colors.green,
                    title: Text("Báo cáo"),
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      child: Icon(FontAwesomeIcons.bell),
                      showBadge: _notificationVm.notReadCount != 0,
                      badgeContent: Text(
                        "${_notificationVm.notReadCount}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      badgeColor: Colors.red,
                    ),
                    backgroundColor: Colors.green,
                    title: Text("Thông báo"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(FontAwesomeIcons.userCircle),
                    backgroundColor: Colors.green,
                    title: Text("Cá nhân"),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_bottomNavigatinBarIndex) {
      case 0:
        return PageTransition(
          child: HomePage(),
          key: Key("0"),
        );
        break;
      case 1:
        return PageTransition(
          child: ReportDashboardPage(),
          key: Key("1"),
        );
        break;
      case 2:
        return PageTransition(
          child: NotificationListPage(
            drawer: MainMenuDrawer(),
          ),
          key: Key("2"),
        );
        break;
      case 3:
        return PageTransition(
          child: HomePersonalPage(),
          key: Key("3"),
        );
        break;
      default:
        return null;
        break;
    }
  }
}

class PageTransition extends StatefulWidget {
  final Widget child;
  final Key key;
  PageTransition({this.child, this.key}) : super(key: key);
  @override
  _PageTransitionState createState() => _PageTransitionState();
}

class _PageTransitionState extends State<PageTransition>
    with TickerProviderStateMixin {
  AnimationController _pageAnimController;
  Animation<double> animation;

  @override
  void initState() {
    _pageAnimController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    animation =
        CurvedAnimation(parent: _pageAnimController, curve: Curves.easeIn);
    _pageAnimController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: animation, child: widget.child);
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    super.dispose();
  }
}
