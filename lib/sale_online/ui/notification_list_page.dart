import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/ui/show_webview_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/notification_list_viewmodel.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class NotificationListPage extends StatefulWidget {
  final drawer;
  NotificationListPage({this.drawer});
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  var _vm = locator<NotificationListViewModel>();
  final _notReadTilteStyle = TextStyle(fontWeight: FontWeight.bold);
  final _readTitleStyle = TextStyle(fontWeight: FontWeight.normal);

  @override
  void initState() {
    _vm.initCommand();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotificationListViewModel>(
      model: _vm,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Thông báo"),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        return _vm.refreshCommand();
      },
      child: ScopedModelDescendant<NotificationListViewModel>(
        builder: (context, child, model) {
          if (model.notifications == null || model.notifications.length == 0)
            return Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.notifications,
                    color: Colors.grey.shade300,
                    size: 70,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      "Chưa có thông báo",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "Các thông báo từ TPOS sẽ hiển thị ở đây",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            );
          return ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green.shade300,
                  child: Icon(
                    Icons.mail,
                    color: Colors.white,
                  ),
                ),
                title: Row(children: <Widget>[
                  Expanded(
                    child: Text(
                      "${model.notifications[index].title}",
                      style: model.notifications[index].dateRead == null
                          ? _notReadTilteStyle
                          : _readTitleStyle,
                    ),
                  ),
                ]),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${trimUnicodeString(model.notifications[index].description, 100)}",
                    ),
                    if (model.notifications[index].dateRead != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "${DateFormat("dd/MM/yyyy HH:mm").format(model.notifications[index].dateCreated)}",
                            style: TextStyle(color: Colors.blue),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              "${timeAgo.format(model.notifications[index].dateCreated, locale: "vi_VN")}"),
                        ],
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationViewPage(
                        notification: model.notifications[index],
                        title: model.notifications[index].title,
                        htmlString: model.notifications[index].content,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: _vm.notifications?.length ?? 0,
          );
        },
      ),
    );
  }
}
