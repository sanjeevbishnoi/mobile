import 'package:flutter/material.dart';

import 'package:tpos_mobile/app_service_locator.dart';

import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';

class GameLuckyWheelSettingPage extends StatefulWidget {
  @override
  _GameLuckyWheelSettingPageState createState() =>
      _GameLuckyWheelSettingPageState();
}

class _GameLuckyWheelSettingPageState extends State<GameLuckyWheelSettingPage> {
  var _setting = locator<ISettingService>();
  final quantityController = new TextEditingController();

  double fontSize;
  final TextStyle defaultStyle = TextStyle(
    fontFamily: 'UVNVan_B',
    color: Colors.white,
    shadows: <BoxShadow>[
      new BoxShadow(
        color: new Color(0xFF064BC2),
        blurRadius: 10.0,
        offset: new Offset(0.0, 10.0),
      ),
    ],
  );

  final TextStyle noteStyle = TextStyle(color: Colors.white);

  String get priorSelectGroupValue => _setting.isPriorGame;
  set priorSelectGroupValue(String value) {
    if (value == "share") {
      _setting.isPriorGame = "share";
    } else if (value == "comment") {
      _setting.isPriorGame = "comment";
    } else if (value == "share_comment") {
      _setting.isPriorGame = "share_comment";
    } else {
      _setting.isPriorGame = "all";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    fontSize = deviceWidth / 414.0;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Color(0xFF5600E8), Color(0xFF3ADDFF)],
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: Colors.white,
        toggleableActiveColor: Colors.green,
      ),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          ListTile(
            title: Row(
              children: <Widget>[
                Expanded(child: Text("Cài đặt Game", style: defaultStyle)),
                RaisedButton(
                  padding: EdgeInsets.all(5 * fontSize),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  child: Text(
                    "Đóng",
                    style:
                        TextStyle(color: Colors.white, fontSize: 16 * fontSize),
                  ),
                  color: Color(0xFFFE5250),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                    child: Text("Đối tượng được tham gia trò chơi",
                        style: defaultStyle)),
              ],
            ),
            subtitle: Column(
              children: <Widget>[
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: true,
                  title: new Text('Có Comment (Toàn bộ người chơi)',
                      style: defaultStyle),
                  onChanged: (bool value) {},
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _setting.isShareGame,
                  title: new Text('Và phải có share', style: defaultStyle),
                  onChanged: (bool value) {
                    setState(() {
                      _setting.isShareGame = value;
                    });
                  },
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _setting.isOrderGame,
                  title: new Text('Và phải có mua hàng', style: defaultStyle),
                  subtitle: Text(
                    "Không có đơn hàng sẽ không được phép chơi",
                    style: noteStyle,
                  ),
                  onChanged: (bool value) {
                    setState(() {
                      _setting.isOrderGame = value;
                    });
                  },
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _setting.isWinGame,
                  title: new Text('Người đã thắng cuộc', style: defaultStyle),
                  subtitle: Text(
                    "Bao gồm cả người đã thắng cuộc chơi trong quá khứ. ",
                    style: noteStyle,
                  ),
                  onChanged: (bool value) {
                    setState(() {
                      _setting.isWinGame = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(
            indent: 10,
            endIndent: 10,
            color: Colors.white,
          ),
          ListTile(
            title: Text("Ưu tiên trúng thưởng", style: defaultStyle),
            subtitle: Column(
              children: <Widget>[
                RadioListTile<String>(
                  title: Text("Share nhiều hơn", style: defaultStyle),
                  value: "share",
                  groupValue: priorSelectGroupValue,
                  onChanged: (value) {
                    setState(
                      () {
                        priorSelectGroupValue = value;
                      },
                    );
                  },
                ),
                RadioListTile<String>(
                  title: Text("Comment nhiều hơn", style: defaultStyle),
                  value: "comment",
                  groupValue: priorSelectGroupValue,
                  onChanged: (value) {
                    setState(() {
                      priorSelectGroupValue = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text("Share + Comment nhiều hơn", style: defaultStyle),
                  subtitle: Text(
                    "Mỗi 1 share hoặc comment sẽ được tính 1 vé tham dự",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: "share_comment",
                  groupValue: priorSelectGroupValue,
                  onChanged: (value) {
                    setState(() {
                      priorSelectGroupValue = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text("Không ưu tiên", style: defaultStyle),
                  subtitle: Text(
                    "Cơ hội chia đều cho tất cả người tham gia",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: "all",
                  groupValue: priorSelectGroupValue,
                  onChanged: (value) {
                    setState(() {
                      priorSelectGroupValue = value;
                    });
                  },
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    "Không ưu tiên người đã thắng gần đây",
                    style: defaultStyle,
                  ),
                  subtitle: Text(
                    "Nếu người đó đã thắng trong khoảng ${_setting.days} ngày gần đây sẽ chỉ được 1 vé tham dự nếu đủ điều kiện",
                    style: noteStyle,
                  ),
                  value: _setting.settingGameIsIgroneRecentWinner,
                  onChanged: (value) {
                    setState(() {
                      _setting.settingGameIsIgroneRecentWinner = value;
                    });
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Số ngày bỏ qua: ${_setting.days}    ",
                        style: defaultStyle.copyWith(fontSize: 16)),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          height: 30,
                          child: new RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0)),
                            padding: EdgeInsets.all(0),
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _setting.days += 1;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                        ),
                        SizedBox(
                          child: new RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0)),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              setState(() {
                                if (_setting.days > 0) _setting.days -= 1;
                              });
                            },
                          ),
                          width: 40,
                          height: 30,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  padding: EdgeInsets.all(5 * fontSize),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  child: Text(
                    "CÀI ĐẶT XONG",
                    style:
                        TextStyle(color: Colors.white, fontSize: 16 * fontSize),
                  ),
                  color: Color(0xFFFE5250),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
