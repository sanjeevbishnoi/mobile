import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_facebook_post_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_facebook_channel_list_viewmodel.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models.dart';
import 'package:tpos_mobile/src/facebook_apis/src/services.dart';

const String FACEBOOK_NOT_IN_CRMTEAM_VALUE =
    "Tài khoản facebook chưa được thêm vào kênh bán hàng.";
const String NO_FACEBOOK_CHANNEL_VALUE =
    "Không có tài khoản facebook nào đã kết nối. Nhấn nút đăng nhập phía trên và lưu kênh để bắt đầu";

const String BUTTON_TEXT_ADD_FACEBOOK_CHANNEL = "Thêm";
const String DIALOG_TITLE_CONFIRM_ADD_CHANNEL = "Xác nhận thêm!";
const String DIALOG_CONTENT_CONFIRM_ADD_CHANNEL =
    "Lưu kênh này để tiện sử dụng lần sau?";

class SaleOnlineFacebookChannelListPage extends StatefulWidget {
  @override
  _SaleOnlineFacebookChannelListPageState createState() =>
      _SaleOnlineFacebookChannelListPageState();
}

class _SaleOnlineFacebookChannelListPageState
    extends State<SaleOnlineFacebookChannelListPage> {
  var _log = new Logger("SaleOnlineFacebookChannelListPage");
  var _fbApi = locator<IFacebookApiService>();
  var _vm = SaleOnlineFacebookChannelListViewModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final dividerMin = new Divider(
    indent: 20,
    height: 2,
  );
  void _showFacebookChannelMenu(CRMTeam crmTeam) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                if (crmTeam.facebookTypeId == "User") ...[
                  ListTile(
                    leading: Icon(
                      Icons.add_circle,
                      color: Colors.green,
                    ),
                    title: Text("Thêm page"),
                    onTap: () {
                      Navigator.pop(context);
                      _showFacebookSelectFacebookPages(crmTeam);
                    },
                  ),
                  dividerMin
                ],
                if (_vm.isFacebookLoggined &&
                    _vm.loginedFacebookUser != null &&
                    (crmTeam.facebookASUserId == _vm.loginedFacebookUser.id ||
                        crmTeam.parent?.facebookASUserId ==
                            _vm.loginedFacebookUser.id)) ...[
                  ListTile(
                    leading: Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                    title: Text("Làm mới"),
                    onTap: () {
                      // Làm mới
                      Navigator.pop(context);
                      _vm.refreshTokenCommand.execute(crmTeam);
                    },
                  ),
                  dividerMin
                ],
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  title: Text("Xóa"),
                  onTap: () {
                    Navigator.pop(context);
                    _vm.deleteFacebookChannelCommand.execute(crmTeam);
                  },
                ),
                dividerMin,
                ListTile(),
                dividerMin,
              ],
            ),
          );
        });
  }

  void _showAddFacebookChannelConfirm() {
    var controller = TextEditingController(text: _vm.loginedFacebookUser.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DIALOG_TITLE_CONFIRM_ADD_CHANNEL),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(DIALOG_CONTENT_CONFIRM_ADD_CHANNEL),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: "", labelText: "Lưu kênh dưới tên:"),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("HỦY BỎ"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("LƯU"),
            onPressed: () {
              Navigator.pop(context);
              _vm.insertFacebookChannelCommand.execute(controller.text.trim());
            },
          ),
        ],
      ),
    );
  }

  void _showAddFacebookPageChannelConfirm(
      FacebookAccount page, CRMTeam crmTeam) {
    var controller = TextEditingController(text: page.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DIALOG_TITLE_CONFIRM_ADD_CHANNEL),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(DIALOG_CONTENT_CONFIRM_ADD_CHANNEL),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: "", labelText: "Lưu kênh dưới tên:"),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("HỦY BỎ"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("LƯU"),
            onPressed: () {
              Navigator.pop(context);
              if (crmTeam.childs != null &&
                  crmTeam.childs.any((f) => f.facebookPageId == page.id)) {
                showWarning(
                    context: context,
                    title: "Đã  tồn tại",
                    message:
                        "Kênh có id: ${page.id} đã tồn tại. Nếu kênh hết hạn đăng nhập hãy làm mới token");
                return;
              }
              _vm.insertFacebookPageChannelCommand.execute([
                page,
                controller.text.trim(),
                crmTeam,
              ]);
            },
          ),
        ],
      ),
    );
  }

  void _showFacebookSelectFacebookPages(CRMTeam crmTeam,
      {BuildContext context}) async {
    try {
      var pages = await _fbApi.getFacebookAccount(
          accessToken: crmTeam.facebookUserToken);
      if (pages == null) return;
      showDialog(
        context: context ?? this.context,
        builder: (context) => AlertDialog(
          title: Text("Chọn page: "),
          content: Container(
            width: 700,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(pages[index].pictureString ?? ""),
                    ),
                    title: Text(pages[index].name),
                    onTap: () async {
                      Navigator.pop(context);
                      _showAddFacebookPageChannelConfirm(pages[index], crmTeam);
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      height: 2,
                    ),
                itemCount: pages?.length ?? 0),
          ),
        ),
      );
    } catch (e) {
      _vm.onDialogMessageAdd(OldDialogMessage.error("", "", error: e));
    }
  }

  void _showFacebookPostPage(CRMTeam crmTeam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleOnlineFacebookPostPage(
          crmTeam: crmTeam,
        ),
      ),
    );
  }

  @override
  void initState() {
    _vm.initCommand.execute(null);
    _vm.dialogMessageController.listen((message) {
      if (context != null) {
        registerDialogToView(context, message,
            scaffState: _scaffoldKey.currentState);
      }
    });

    _vm.eventController.listen((event) {
      if (event.eventName == "GO_BACK") {
        if (mounted) if (Navigator.canPop(context)) Navigator.pop(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SaleOnlineFacebookChannelListViewModel>(
      model: _vm,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text("Chọn kênh facebook"),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return UIViewModelBase(
      viewModel: _vm,
      child: RefreshIndicator(
        onRefresh: () async {
          await _vm.refreshCommand.execute(null);
          return true;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              ScopedModelDescendant<SaleOnlineFacebookChannelListViewModel>(
                builder: (context, child, model) {
                  return Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: new Offset(2, 2),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            if (_vm.loginedFacebookUser != null) ...[
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "${_vm.loginedFacebookUser?.pictureLink}"),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                            Expanded(
                              child: Text(
                                  "${_vm.loginedFacebookUser?.name ?? "Đăng nhập facebook"}"),
                            ),
                            GestureDetector(
                              child: RaisedButton.icon(
                                onPressed: () {
                                  _vm.loginFacebookCommand.execute(false);
                                },
                                color: Colors.indigo,
                                textColor: Colors.white,
                                icon: Icon(FontAwesomeIcons.facebook),
                                label: Text(_vm.isFacebookLoggined
                                    ? "Đăng xuất"
                                    : "Đăng nhập"),
                              ),
                              onLongPress: () {
                                _vm.loginFacebookCommand.execute(true);
                              },
                            )
                          ],
                        ),
                        if (_vm.isFacebookNotInCrmteams) ...[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    FACEBOOK_NOT_IN_CRMTEAM_VALUE,
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ),
                              RaisedButton(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28, right: 28),
                                  child: Text(
                                    BUTTON_TEXT_ADD_FACEBOOK_CHANNEL,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                onPressed: () {
                                  _showAddFacebookChannelConfirm();
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text("Tài khoản đã kết nối"),
                      ),
                    ),
                    Divider(
                      height: 2,
                    ),
                    ScopedModelDescendant<
                        SaleOnlineFacebookChannelListViewModel>(
                      builder: (context, child, model) {
                        if (_vm.crmTeams == null) {
                          return SizedBox();
                        }

                        if (_vm.crmTeams.length == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.boxOpen,
                                  size: 60,
                                  color: Colors.grey.shade200,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    "Chưa có kênh bán hàng",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    NO_FACEBOOK_CHANNEL_VALUE,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return _buildListFacebookChannel(_vm.crmTeams);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListFacebookChannel(List<CRMTeam> crmTeams) {
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            _buildListFacebookChannelItem(crmTeams[index]),
        separatorBuilder: (context, index) => Divider(
              height: 2,
              indent: 70,
            ),
        itemCount: crmTeams?.length ?? 0);
  }

  Widget _buildListFacebookChannelItem(CRMTeam crmTeam) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(crmTeam.facebookTypeId == "User"
                ? (crmTeam.facebookUserAvatar ?? "")
                : (crmTeam.facebookPageLogo ?? "")),
          ),
          title: Text(crmTeam.name),
          trailing: IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              _showFacebookChannelMenu(crmTeam);
            },
          ),
          contentPadding: EdgeInsets.only(left: 12, right: 0),
          onLongPress: () {
            _showFacebookChannelMenu(crmTeam);
          },
          onTap: () {
            // Mở bài đăng
            _showFacebookPostPage(crmTeam);
          },
        ),
        if (crmTeam.childs != null) ...[
          Divider(
            indent: 70,
          ),
          ListView.separated(
              padding: EdgeInsets.only(left: 60),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  _buildListFacebookChannelItem(crmTeam.childs[index]),
              separatorBuilder: (context, index) => Divider(
                    height: 2,
                    indent: 70,
                  ),
              itemCount: crmTeam.childs?.length ?? 0)
        ],
      ],
    );
  }
}
