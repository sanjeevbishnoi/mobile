import 'package:flutter/material.dart';

class NotFoundPage extends StatefulWidget {
  static const routeName = "/not_found";
  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  "Trang bạn vừa tới hiện không có hoặc đã bị xóa",
                  style: TextStyle(fontSize: 20, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  child: Text("Quay lại"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  child: Text("Về Menu chính"),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (Route<dynamic> r) => false);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
