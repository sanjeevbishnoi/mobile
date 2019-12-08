import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';

abstract class DialogService {
  void registerDialogListener(Function showDialogListener);
  void dialogComplete(DialogResult result);

  Future<DialogResult> showInfo(
      {String title = "INFO", String content, String buttonTitle = "ĐỒNG Ý"});
  Future<DialogResult> showError(
      {String title = "ERROR!",
      String content,
      String buttonTitle = "OK",
      Object error,
      bool isRetry = false});
  Future<DialogResult> showConfirm(
      {String title = "CONFIRM",
      String content,
      String yesButtonTitle = "YES",
      String noButtonTitle = "NO"});

  Future<DialogResult> showNotify(
      {String title, String message, bool showOnTop, DialogType type});

  Future<Notification> showWebNotification({Notification notification});
}

class MainDialogService extends DialogService {
  Completer<DialogResult> _dialogCompleter;
  Function(DialogMessageInfo) _showDialogListener;
  void registerDialogListener(Function showDialogListener) {
    _showDialogListener = showDialogListener;
  }

  Future<DialogResult> showInfo(
      {String title = "INFO", String content, String buttonTitle = "ĐỒNG Ý"}) {
    return showDialog(
        type: DialogType.INFO,
        title: title,
        content: content,
        okButtonTitle: buttonTitle);
  }

  Future<DialogResult> showError(
      {String title = "ERROR!",
      String content,
      String buttonTitle = "OK",
      Object error,
      bool isRetry = false}) {
    String errorMessage = content?.replaceAll("Exception: ", "");
    if (error != null) {
      //Catch exception
      if (error is SocketException) {
        SocketException e = error;
        errorMessage =
            "Không thể kết nối tới địa chỉ mạng${error.address ?? ""}. Không có kết nối mạng hoặc địa chỉ máy chủ không hoạt động\n${error.message}";
      } else if (error is TimeoutException) {
        errorMessage = "Đã hết thời gian kết nối, vui lòng thử lại";
      } else
        errorMessage = error.toString().replaceAll("Exception: ", "");
    }
    return showDialog(
      type: DialogType.ERROR,
      title: title,
      content: errorMessage,
      okButtonTitle: buttonTitle,
      isRetry: isRetry,
    );
  }

  Future<DialogResult> showConfirm(
      {String title = "CONFIRM",
      String content,
      String yesButtonTitle = "YES",
      String noButtonTitle = "NO"}) {
    return showDialog(
        type: DialogType.CONFIRM,
        title: title,
        content: content,
        noButtonTitle: noButtonTitle,
        yesButtonTitle: yesButtonTitle);
  }

  Future<DialogResult> showNotify({
    String title,
    String message,
    bool showOnTop = false,
    DialogType type = DialogType.NOTIFY_INFO,
  }) {
    return showDialog(
        type: type, title: title, content: message, showOnTop: showOnTop);
  }

  Future<DialogResult> showDialog(
      {String title,
      String content,
      String yesButtonTitle,
      String noButtonTitle,
      String cancelButtonTitle,
      String okButtonTitle,
      DialogType type,
      bool isRetry = false,
      bool showOnTop = false}) {
    _dialogCompleter = Completer<DialogResult>();

    _showDialogListener(DialogMessageInfo(
        title: title,
        content: content,
        type: type,
        yesButtonTitle: yesButtonTitle,
        noButtonTitle: noButtonTitle,
        cancelButtonTitle: cancelButtonTitle,
        isRetry: isRetry,
        okButtonTitle: okButtonTitle,
        showOnTop: showOnTop));
    return _dialogCompleter.future;
  }

  void dialogComplete(DialogResult result) {
    _dialogCompleter?.complete(result);
    _dialogCompleter = null;
  }

  @override
  Future<Notification> showWebNotification({Notification notification}) {
    // TODO: implement showWebNotification
    return null;
  }
}

class DialogResult {
  String responseMessage;
  Object value;
  bool isRetry;
  DialogResultType type;
  DialogResult(
      {this.responseMessage,
      this.value,
      this.isRetry = false,
      this.type = DialogResultType.OK});
}

class DialogMessageInfo {
  String title;
  String content;
  DialogType type;

  String yesButtonTitle;
  String noButtonTitle;
  String cancelButtonTitle;
  String okButtonTitle;
  Function retryCallback;
  bool isRetry;
  bool showOnTop;

  DialogMessageInfo({
    this.title,
    this.content,
    this.type,
    this.yesButtonTitle,
    this.noButtonTitle,
    this.cancelButtonTitle,
    this.okButtonTitle,
    this.retryCallback,
    this.isRetry = false,
    this.showOnTop = false,
  });
}

enum DialogType {
  INFO,
  WARNING,
  ERROR,
  CONFIRM,
  NOTIFY,
  NOTIFY_INFO,
  NOTIFY_ERROR,
}

enum DialogResultType {
  OK,
  YES,
  NO,
  CANCEL,
  RETRY,
  GOBACK,
}

Future<DialogResultType> showQuestion(
    {BuildContext context, String title, String message}) async {
  var result = await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0,
          ),
        ),
        title: new Text(
          title.isNotEmpty ? title : "Xác nhận",
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text("HỦY BỎ"),
            onPressed: () {
              Navigator.of(context).pop(DialogResultType.CANCEL);
            },
          ),
          FlatButton(
            child: Text("XÁC NHẬN"),
            onPressed: () {
              Navigator.of(context).pop(DialogResultType.YES);
            },
          ),
        ],
      );
    },
  );
  if (result != null) {
    return result;
  } else {
    return DialogResultType.CANCEL;
  }
}
