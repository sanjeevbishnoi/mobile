/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_add_edit_live_campaign_page.dart';

import 'package:tpos_mobile/sale_online/viewmodels/sale_online_live_campaign_select_viewmodel.dart';

class SaleOnlineLiveCampaignSelectPage extends StatefulWidget {
  @override
  _SaleOnlineLiveCampaignSelectPageState createState() =>
      _SaleOnlineLiveCampaignSelectPageState();
}

class _SaleOnlineLiveCampaignSelectPageState
    extends State<SaleOnlineLiveCampaignSelectPage> {
  var _viewModel = new SaleOnlineLiveCampaignSelectViewModel();

  @override
  void initState() {
    _viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn chiến dịch"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (ctx) => new SaleOnlineAddEditLiveCampaignPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        new Expanded(
          child: StreamBuilder<List<LiveCampaign>>(
              stream: _viewModel.liveCampaignsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.separated(
                    itemCount: snapshot.data.length,
                    separatorBuilder: (ctx, index) {
                      return Divider(
                        height: 2,
                        indent: 60,
                      );
                    },
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                              "${snapshot.data[index].name?.substring(0, 1)}"),
                        ),
                        title: Text(snapshot.data[index].name),
                        onTap: () {
                          Navigator.pop(context, snapshot.data[index]);
                        },
                      );
                    });
              }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }
}
