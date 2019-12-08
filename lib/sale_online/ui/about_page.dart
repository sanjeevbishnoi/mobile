/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/10/19 11:55 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/10/19 9:29 AM
 *
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpos_mobile/string_resources.dart';
import 'package:tpos_mobile/themes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version;

  Future<void> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    getPackageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dividerMin = new Divider(
      height: 2,
    );
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            shrinkWrap: false,
            slivers: <Widget>[
              SliverAppBar(
                primary: true,
                pinned: false,
                expandedHeight: 220,
                flexibleSpace: Container(
                  padding: EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary1Color,
                        AppTheme.primary2Color,
                      ],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          "images/tpos_logo.png",
                        ),
                      ),
                      SizedBox(),
                      Text(
                        "Phần mềm bán hàng TPos Mobile",
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Phiên bản ${version ?? "release"}",
                        style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(
                                Icons.open_in_new,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              title: Text("Website"),
                              subtitle: Text(WEBSITE_URL),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () async {
                                var url = WEBSITE_URL;
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {}
                              },
                            ),
                            dividerMin,
                            ListTile(
                              leading: Icon(
                                Icons.phonelink_lock,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              title: Text("Chính sách bảo mật"),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () async {
                                var url = PRIVACY_POLICY_URL;
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {}
                              },
                            ),
                            dividerMin,
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Copyright © 2019 TMT SOLUTION",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
