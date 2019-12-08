/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/4/19 6:25 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/4/19 10:18 AM
 *
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/new_login_page.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_change_password.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/home_personal_viewmodel.dart';
import 'package:tpos_mobile/string_resources.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_service_locator.dart';

class HomePersonalPage extends StatefulWidget {
  @override
  _HomePersonalPageState createState() => _HomePersonalPageState();
}

class _HomePersonalPageState extends State<HomePersonalPage> {
  var _vm = locator<HomePersonalViewModel>();
  var _appVm = locator<IAppService>();

  @override
  void initState() {
    _vm.initCommand();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<HomePersonalViewModel>(
      model: _vm,
      child: SafeArea(
        child: Scaffold(
          body: _buildBody(),
          backgroundColor: Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _vm.initCommand();
        return true;
      },
      child: ListView(
        children: <Widget>[
          ScopedModelDescendant<IAppService>(
            builder: (context, child, model) {
              return Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: 70,
                      width: 70,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            _appVm.loginUser?.avatar ?? "images/no_image.png"),
                        radius: 50,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: InkWell(
                                    child: Text(
                                      "${_appVm.selectedCompany?.name}",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 17),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, AppRoute.company_edit,
                                          arguments: [_appVm.selectedCompany]);
                                    },
                                  ),
                                ),
                                InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "Đổi",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                  onTap: () async {
                                    await _appVm.getCurrentCompanyCommand();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: Container(
                                          width: 500,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _appVm.companyCurrentInfo
                                                    ?.companies?.length ??
                                                0,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                selected: _appVm
                                                        .companyCurrentInfo
                                                        .companies[index]
                                                        .text ==
                                                    _appVm.selectedCompany.id
                                                        .toString(),
                                                leading: _appVm
                                                            .companyCurrentInfo
                                                            .companies[index]
                                                            .value ==
                                                        _appVm
                                                            .selectedCompany.id
                                                            .toString()
                                                    ? Icon(Icons.check)
                                                    : SizedBox(),
                                                title: Text(_appVm
                                                    .companyCurrentInfo
                                                    .companies[index]
                                                    .text),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  // Change company
                                                  _appVm.switchCompany(
                                                    int.parse(_appVm
                                                        .companyCurrentInfo
                                                        .companies[index]
                                                        .value),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                "Còn ${_appVm.companyCurrentInfo?.expiredInShort} sử dụng"),
                            SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              child: Text(
                                "Đăng nhập bởi: ${_appVm.loginUser?.fullName}",
                                style: TextStyle(color: Colors.blue),
                              ),
                              onTap: () {},
                            ),
                            Row(
                              children: <Widget>[
                                OutlineButton(
                                  child: Text(
                                    "Lịch sử",
                                    textAlign: TextAlign.left,
                                  ),
                                  textColor: Colors.green,
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        AppRoute.home_personal_user_history);
                                  },
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                OutlineButton(
                                  child: Text("Đổi mật khẩu"),
                                  textColor: Colors.blue,
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ChangePassWordDialog(null));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          Material(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: SettingIcon(
                    Icon(
                      Icons.new_releases,
                      size: 17,
                    ),
                  ),
                  title: Text("Kiểm tra phiên bản mới"),
                  trailing: Icon(
                    (Icons.chevron_right),
                  ),
                  onTap: () async {
                    StoreRedirect.redirect(
                        androidAppId: ANDROID_APP_ID, iOSAppId: APPLE_APP_ID);
                  },
                ),
                if (!Platform.isIOS) ...[
                  const Divider(
                    height: 1,
                    indent: 12,
                  ),
                  ListTile(
                    leading: SettingIcon(
                      Icon(
                        Icons.rate_review,
                        size: 17,
                      ),
                    ),
                    title: Text("Bình chọn cho ứng dụng này"),
                    trailing: Icon((Icons.chevron_right)),
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            color: Color(0xFF737373),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  color: Colors.white),
                              child: ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "Chúng tôi luôn cố gắng xây dựng ứng dụng trở nên tốt nhất, Bỏ chút thời gian đánh giá ứng dụng nhé.",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black87),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: OutlineButton(
                                            child: Text(
                                              "Không, cảm ơn",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            color: Colors.white,
                                            textColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                            child: Text(
                                              "Đồng ý",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            onPressed: () async {
                                              StoreRedirect.redirect(
                                                  androidAppId: ANDROID_APP_ID,
                                                  iOSAppId: APPLE_APP_ID);
                                            },
                                            color:
                                                Theme.of(context).primaryColor,
                                            textColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

//
                    },
                  ),
                ],
                const Divider(
                  height: 1,
                  indent: 12,
                ),
                ListTile(
                  leading: SettingIcon(
                    Icon(
                      Icons.email,
                      size: 17,
                    ),
                  ),
                  title: Text("Gửi email góp ý về sản phẩm"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    var url =
                        'mailto:$CONTACT_EMAIL?subject=${Uri.encodeFull(CONTACT_EMAIL_SUBJECT)}&body=';

                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {}
                  },
                ),
                const Divider(
                  height: 1,
                  indent: 12,
                ),
                ListTile(
                  leading: SettingIcon(Icon(
                    Icons.settings,
                    size: 17,
                  )),
                  title: Text("Cài đặt"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.setting);
                  },
                ),
                const Divider(
                  height: 1,
                  indent: 12,
                ),
                ListTile(
                  leading: SettingIcon(
                    Icon(
                      Icons.info,
                      size: 17,
                    ),
                  ),
                  title: Text("Thông tin phần mềm"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.about);
                  },
                ),
                const Divider(
                  height: 1,
                  indent: 12,
                ),
                ListTile(
                  leading: SettingIcon(Icon(
                    FontAwesomeIcons.doorClosed,
                    size: 15,
                  )),
                  title: Text("Đăng xuất"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    // Đăng xuất
                    await locator<IAppService>().logout();
                    Navigator.of(context).pushReplacement(
                        new MaterialPageRoute(builder: (context) {
                      return new NewLoginPage();
                    }));
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SettingIcon extends StatelessWidget {
  final Widget icon;
  SettingIcon(this.icon);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.green.shade100.withOpacity(0.5),
        ),
      ),
      padding: EdgeInsets.all(3),
      child: icon,
    );
  }
}

class SwitchCompanyPage extends StatefulWidget {
  @override
  _SwitchCompanyPageState createState() => _SwitchCompanyPageState();
}

class _SwitchCompanyPageState extends State<SwitchCompanyPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile();
          }),
    );
  }
}
