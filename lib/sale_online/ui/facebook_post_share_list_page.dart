import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/facebook_post_share_list_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tpos_mobile/helpers/helpers.dart';

import 'facebook_post_share_detail_page.dart';

class FacebookPostShareListPage extends StatefulWidget {
  final String pageId;
  final String postId;
  final bool autoClose;
  FacebookPostShareListPage(
      {@required this.pageId, @required this.postId, this.autoClose = false});
  @override
  _FacebookPostShareListPageState createState() =>
      _FacebookPostShareListPageState();
}

class _FacebookPostShareListPageState extends State<FacebookPostShareListPage> {
  var _vm = new FacebookPostShareListViewModel();
  final GlobalKey<ScaffoldState> _scafffoldKey = new GlobalKey<ScaffoldState>();

  double _tranform = 0;

  @override
  void initState() {
    _vm.init(
        postId: widget.postId,
        pageId: widget.pageId,
        isAutoClose: widget.autoClose);
    _vm.initCommand.execute(null);
    _vm.dialogMessageController.listen((mesage) {
      registerDialogToView(context, mesage,
          scaffState: _scafffoldKey.currentState);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UIViewModelBase(
      viewModel: _vm,
      child: ScopedModel<FacebookPostShareListViewModel>(
        model: _vm,
        child: Scaffold(
          key: _scafffoldKey,
          appBar: AppBar(
            title: Text("Số lượt share"),
            actions: <Widget>[
              FlatButton.icon(
                textColor: Colors.white,
                label: Text("Đảo ngược"),
                icon: Icon(Icons.rotate_right),
                onPressed: () {
                  if (_tranform == pi) {
                    setState(() {
                      _tranform = 0;
                    });
                  } else {
                    setState(() {
                      _tranform = pi;
                    });
                  }
                },
              )
            ],
          ),
          body: Column(children: <Widget>[
            Expanded(
              child: _buildBody(),
            ),
            if (widget.autoClose)
              Container(
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  textColor: Colors.white,
                  child: Text("ĐÓNG & TIẾP TỤC"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
          ]),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (App.isTablet) {
      return _buildBodyPhone();
    } else {
      return _buildBodyPhone();
    }
  }

  Widget _buildBodyPhone() {
    return Transform(
      transform: Matrix4.rotationY(_tranform),
      alignment: Alignment.center,
      child: ScopedModelDescendant<FacebookPostShareListViewModel>(
        builder: (context, child, model) {
          return Column(
            children: <Widget>[
              if (_vm.shareCount != 0)
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${_vm.userCount} người đã chia sẻ ${_vm.shareCount} lần",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Align(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 135),
                        child: Text(
                          "TPOS.VN",
                          style: TextStyle(
                              fontSize: 35,
                              color: Colors.green.shade100,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      alignment: Alignment.topCenter,
                    ),
                    RefreshIndicator(
                        onRefresh: () async {
                          model.refreshCommand.execute(null);
                          return true;
                        },
                        child: _vm.shareCount == 0 && _vm.isBusy == false
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.solidShareSquare,
                                        color: Colors.grey.shade200,
                                        size: 62,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Không tìm thấy lượt share. Hãy thử lại lại xem",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.orangeAccent),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      RaisedButton(
                                        textColor: Colors.white,
                                        child: Text("Tải lại"),
                                        onPressed: () {
                                          _vm.refreshCommand.execute(null);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.all(10),
                                physics: AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) => Divider(
                                  height: 2,
                                ),
                                itemCount:
                                    model.facebookShareCounts?.length ?? 0,
                                itemBuilder: (context, index) =>
                                    _buildPhoneListItem(
                                        model.facebookShareCounts[index],
                                        index),
                              )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoneListItem(FacebookShareCount item, int index) {
    return ListTile(
      leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 16),
          child: Text("# ${index + 1}"),
        ),
        InkWell(
          child: Image.network(item.avatarLink),
          onTap: () async {
            String url = "fb://profile/${item.facebookUid}";
            if (await canLaunch(url)) {
              await launch(url);
            } else {}
          },
        ),
      ]),
      title: Text(item.name ?? ""),
      trailing: Text(
        item.count.toString(),
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(item.facebookUid ?? ""),
      contentPadding: EdgeInsets.only(
        left: 0,
        right: 16,
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (ctx) => new FacebookPostShareDetailPage(item),
          ),
        );
      },
    );
  }
}
