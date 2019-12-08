import 'package:flutter/material.dart';

class AppAppBarSearchTitle extends StatefulWidget {
  final Widget title;
  final Key key;
  final ValueChanged<String> onSearch;
  final String initKeyword;
  AppAppBarSearchTitle({this.key, this.title, this.onSearch, this.initKeyword})
      : super(key: key);
  @override
  _AppAppBarSearchTitleState createState() => _AppAppBarSearchTitleState();
}

class _AppAppBarSearchTitleState extends State<AppAppBarSearchTitle> {
  TextEditingController _controller = new TextEditingController();
  bool get isCancelVisible =>
      _controller.text != null && _controller.text != "";
  @override
  void initState() {
    _controller.text = widget.initKeyword ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      height: double.infinity,
      padding: EdgeInsets.only(left: 10, right: 10),
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  hintText: "Tìm kiếm",
                  border: InputBorder.none),
              onChanged: (text) {
                setState(() {
                  if (widget.onSearch != null) widget.onSearch(text);
                });
              },
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isCancelVisible
                  ? Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 16,
                    )
                  : SizedBox(),
            ),
            onTap: () {
              _controller.clear();
              if (widget.onSearch != null) widget.onSearch("");
            },
          ),
        ],
      ),
    );
  }
}
