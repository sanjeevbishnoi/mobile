import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/home_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class MenuSearchDelegate extends SearchDelegate {
  IAppService _app;
  ISettingService _setting;
  MenuSearchDelegate({IAppService appService, ISettingService settingService}) {
    _app = appService ?? locator<IAppService>();
    _setting = settingService ?? locator<ISettingService>();
  }

  bool isSuggesAll = false;
  var _resultChangedSubject = BehaviorSubject<String>();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            query = "";
          },
          child: Icon(
            Icons.cancel,
            color: Colors.black54,
            size: 16,
          ),
        ),
      ),
      FlatButton(
        textColor: Colors.blue,
        child: Text("ĐÓNG"),
        onPressed: () {
          close(context, null);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return Icon(Icons.search);
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == "") {
      return _buildDefault(context);
    } else {
      return _buildResult();
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.white,
      primaryTextTheme: TextTheme(
        title: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Buid default search result. it is recent that user go to link
  Widget _buildDefault(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    int quickMenuColumn = 3;

    if (mediaQuery.orientation == Orientation.portrait) {
      if (width < 700) {
        quickMenuColumn = 3;
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

    if (_setting.menuRecents == null) {
      return Container();
    }

//    var recentMenus = _app.menus
//        .where((f) => _setting.menuRecents.any((s) => s == f.id))
//        .toList();

    var recentMenus = _setting.menuRecents
        .map((f) => _app.menus.firstWhere((s) => s.id == f, orElse: () => null))
        .toList();

    return SingleChildScrollView(
      child: Container(
        child: StreamBuilder<String>(
            stream: _resultChangedSubject.stream,
            initialData: "",
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, bottom: 10, top: 12),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("ĐÃ VÀO GẦN ĐÂY")),
                        Divider(),
                        FlatButton.icon(
                          onPressed: () {
                            // Xem tất cả menu
                            isSuggesAll = !isSuggesAll;
                            if (_resultChangedSubject.isClosed == false) {
                              _resultChangedSubject.add("isSuggesAll");
                            }
                          },
                          icon: Icon(
                            isSuggesAll ? Icons.expand_less : Icons.expand_more,
                            color: Colors.blue,
                          ),
                          label: Text(
                            isSuggesAll ? "Thu gọn" : "Xem tất cả...",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (recentMenus != null && recentMenus.length > 0)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150),
                      itemBuilder: (context, index) {
                        var menu = recentMenus[index];
                        return MenuItemCircle(
                          icon: menu.icon,
                          visible: true,
                          label: menu.label,
                          width: itemWidth,
                          routeName: menu.routeName,
                          onPressed: () {
                            Navigator.pushNamed(context, menu.routeName);
                          },
                        );
                      },
                      itemCount: recentMenus.length,
                    ),
                  if (recentMenus == null || recentMenus.length == 0)
                    Container(
                      height: 100,
                      child: Center(
                        child: Text("Danh sách rỗng!"),
                      ),
                    ),
                  if (isSuggesAll) ..._buildHomeMenu(itemWidth: itemWidth),
                ],
              );
            }),
      ),
    );
  }

  List<Widget> _buildHomeMenu({double itemWidth}) {
    //
    var groupIds = _app.menus.map((f) => f.groupId).toList().toSet().toList();

    var items = List<Widget>();
    items.add(SizedBox(
      height: 20,
    ));
    groupIds.forEach(
      (groupId) {
        var menuFromGroups = _app.menus
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
                ),
              ),
              GridView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150),
                itemCount: menuFromGroups.length,
                itemBuilder: (context, index) {
                  var menu = menuFromGroups[index];
                  return MenuItemCircle(
                    icon: menu.icon,
                    label: menu.label,
                    routeName: menu.routeName,
                    visible: menu.visible,
                    onPressed: () {
                      Navigator.pushNamed(context, menu.routeName);
                    },
                    width: itemWidth,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    //
    return items;
  }

  Widget _buildResult() {
    var queryNoSign = removeVietnameseMark(query)?.toLowerCase();
    var results = _app.menus
        .where((f) =>
            removeVietnameseMark(f.label.toLowerCase()).contains(queryNoSign))
        .toList();
    return Container(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          indent: 26,
        ),
        itemBuilder: (context, index) {
          var menu = results[index];
          return ListTile(
            leading: CircleAvatar(
              child: menu.icon,
              backgroundColor: Colors.blue,
            ),
            title: Text(menu.label),
            onTap: menu.visible
                ? () {
                    Navigator.pushNamed(context, menu.routeName);
                  }
                : null,
          );
        },
        itemCount: results.length,
      ),
    );
  }

  @override
  void close(BuildContext context, result) {
    super.close(context, result);
    _resultChangedSubject.close();
  }
}
