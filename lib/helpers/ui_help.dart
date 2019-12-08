import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<dynamic> showTextInputDialog(BuildContext context, String text,
    [bool autoFocus = false]) async {
  final TextEditingController _controller =
      new TextEditingController(text: text);

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      title: Text("Nhập nội dung:"),
      content: TextField(
        controller: _controller,
        autofocus: autoFocus,
        maxLines: null,
      ),
      actions: <Widget>[
        RaisedButton.icon(
          onPressed: () {
            Navigator.pop(context, _controller.text.trim());
          },
          icon: Icon(Icons.check),
          label: Text("XONG"),
          textColor: Colors.white,
        )
      ],
    ),
  );
}

Future urlLauch(String link) async {
  const url = 'https://flutter.dev';
  if (await canLaunch(link)) {
    await launch(link);
    print("lauch $link");
  } else {
    //throw 'Could not launch $url';
    print("can't send");
  }
}

class BottomBackButton extends StatelessWidget {
  final String content;
  BottomBackButton({this.content = "QUAY LẠI"});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: RaisedButton.icon(
        icon: Icon(Icons.keyboard_return),
        label: Text(content),
        onPressed: () {
          Navigator.pop(context);
        },
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
      ),
    );
  }
}
