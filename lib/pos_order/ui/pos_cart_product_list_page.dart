import 'package:flutter/material.dart';

class PosCartProductListPage extends StatefulWidget {
  PosCartProductListPage(this.position);
  String position;
  @override
  _PosCartProductListPageState createState() => _PosCartProductListPageState();
}

class _PosCartProductListPageState extends State<PosCartProductListPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text("${widget.position}"),
      ),
    );
  }
}
