/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_core/ui_base/app_bar_button.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_add_edit_live_campaign_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_live_campaign_management_viewmodel.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';

class SaleOnlineLiveCampaignManagementPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SaleOnlineLiveCampaignManagementPage> {
  SaleOnlineLiveCampaignManagementViewModel viewModel =
      new SaleOnlineLiveCampaignManagementViewModel();

  Key refreshIndicatorKey = new Key("refreshIndicator");

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  @override
  void initState() {
    viewModel.refreshLiveCampaign();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SaleOnlineLiveCampaignManagementViewModel>(
      model: viewModel,
      child: new Scaffold(
        appBar: new AppBar(
          title: Text("Danh sách chiến dịch"),
          actions: <Widget>[
            AppbarIconButton(
              onPressed: () async {
                await Navigator.push(context,
                    new MaterialPageRoute(builder: (ctx) {
                  return new SaleOnlineAddEditLiveCampaignPage();
                }));

                viewModel.refreshLiveCampaign();
              },
              icon: Icon(Icons.add),
              isEnable: viewModel.permissionAdd,
            ),
          ],
        ),
        body: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: <Widget>[
              Text("Chiến dịch còn hoạt động"),
              StreamBuilder<bool>(
                  stream: viewModel.isOnlyShowAvaiableCampaignStream,
                  initialData: viewModel.isOnlyShowAvaiableCampaign,
                  builder: (context, snapshot) {
                    return new Checkbox(
                      onChanged: (value) {
                        viewModel.isOnlyShowAvaiableCampaign = value;
                        viewModel.refreshLiveCampaign();
                      },
                      value: viewModel.isOnlyShowAvaiableCampaign,
                    );
                  }),
            ],
          ),
        ),
        Divider(),
        new Expanded(
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () {
              return viewModel.refreshLiveCampaign();
            },
            child: new StreamBuilder<List<LiveCampaign>>(
              stream: viewModel.liveCampaignsStream,
              builder: (ctx, data) {
                if (data.hasError) {
                  return ListViewDataErrorInfoWidget(
                    errorMessage: "Đã xảy ra lỗi!\n" + data.error.toString(),
                  );
                }

                if (data.connectionState == ConnectionState.waiting) {
                  return new Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (data.data == null) {
                    return new Column(
                      children: <Widget>[Text("Không có chiến dịch nào")],
                    );
                  }

                  return new ListView.separated(
                      separatorBuilder: (_, __) {
                        return Divider();
                      },
                      itemCount: data.data.length,
                      itemBuilder: (ctx, index) {
                        return new ListTile(
                          onTap: !viewModel.permissionEdit
                              ? null
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      SaleOnlineAddEditLiveCampaignPage
                                          saleOnlineAddEditLiveCampaignPage =
                                          new SaleOnlineAddEditLiveCampaignPage(
                                        liveCampaign: data.data[index],
                                        onEditCompleted: (value) {
                                          data.data[index] = value;
                                        },
                                      );
                                      return saleOnlineAddEditLiveCampaignPage;
                                    }),
                                  );
                                  viewModel.refreshLiveCampaign();
                                },
                          title: Text(
                            "${data.data[index].name}",
                            style: TextStyle(color: Colors.blue),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                  "${data.data[index].note ?? "Không có ghi chú.."}"),
                              data.data[index].facebookUserName != null
                                  ? Text(
                                      "Đã live bởi ${data.data[index].facebookUserName}")
                                  : Text(""),
                            ],
                          ),
                          trailing: Text(
                              "${DateFormat("dd/MM/yyyy  HH:mm").format(data.data[index].dateCreated)}"),
                          isThreeLine: false,
                        );
                      });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
