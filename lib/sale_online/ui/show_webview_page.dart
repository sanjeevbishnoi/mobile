import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/src/tpos_apis/models/notification.dart' as prefix0;
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/notification_api.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NotificationViewPage extends StatefulWidget {
  final prefix0.Notification notification;
  final String htmlString;
  final String title;
  NotificationViewPage(
      {this.htmlString, this.title = "Nội dung", this.notification});
  @override
  _NotificationViewPageState createState() => _NotificationViewPageState();
}

class _NotificationViewPageState extends State<NotificationViewPage> {
  @override
  initState() {
    //Đánh dấu đã đọc

    if (widget.notification?.dateRead != null)
      locator<INotificationApi>()
          .markRead(widget.notification.id)
          .catchError((e) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var content = Uri.dataFromString(
        "<!DOCTYPE html><html><head><title>Page Title</title></head><body>${widget.htmlString}</body></html>",
        mimeType: 'text/html',
        encoding: Utf8Codec());
    return WebView(
      initialUrl: content.toString(),
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (value) {},
    );
  }
}
