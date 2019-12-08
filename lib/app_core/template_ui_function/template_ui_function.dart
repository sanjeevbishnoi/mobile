import 'package:flutter/material.dart';

void showEditDialog({
  BuildContext context,
  Widget title,
  Widget content,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title ?? SizedBox(),
      actions: <Widget>[
        RaisedButton(
          child: Text("Thay đổi"),
        ),
        OutlineButton(
          textColor: Colors.red,
          child: Text("Bỏ chọn"),
        )
      ],
    ),
  );
}
