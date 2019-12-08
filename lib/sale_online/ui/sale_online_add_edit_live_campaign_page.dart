/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_live_campaign_select_product_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_add_edit_live_campaign_viewmodel.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';

class SaleOnlineAddEditLiveCampaignPage extends StatefulWidget {
  final LiveCampaign liveCampaign;
  final Function(LiveCampaign) onEditCompleted;
  SaleOnlineAddEditLiveCampaignPage({this.liveCampaign, this.onEditCompleted});

  @override
  _SaleOnlineAddEditLiveCampaignPageState createState() =>
      _SaleOnlineAddEditLiveCampaignPageState(liveCampaign: liveCampaign);
}

class _SaleOnlineAddEditLiveCampaignPageState
    extends State<SaleOnlineAddEditLiveCampaignPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  LiveCampaign _liveCampaign;
  _SaleOnlineAddEditLiveCampaignPageState({LiveCampaign liveCampaign}) {
    _liveCampaign = liveCampaign;
  }

  SaleOnlineAddEditLiveCampaignViewModel viewModel =
      new SaleOnlineAddEditLiveCampaignViewModel();

  final TextEditingController _nameTextController = new TextEditingController();
  final TextEditingController _noteTextController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return UIViewModelBase(
      viewModel: viewModel,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text(
              "${viewModel.liveCampaign.id == null ? "Chiến dịch mới" : "Sửa chiến dịch"}"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                viewModel.liveCampaign.name = _nameTextController.text;
                viewModel.liveCampaign.note = _noteTextController.text;
                if (await viewModel.save()) {
                  if (widget.onEditCompleted != null) {
                    widget.onEditCompleted(viewModel.liveCampaign);
                  }
//                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: _showLiveCampaignDetail(),
      ),
    );
  }

  Widget _showLiveCampaignDetail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          new TextField(
            controller: _nameTextController,
            decoration: InputDecoration(
              hintText: "Ngày 13/2 sang...",
              labelText: "Tên chiến dịch",
            ),
          ),
          new TextField(
            controller: _noteTextController,
            decoration:
                InputDecoration(hintText: "ghi chú...", labelText: "Ghi chú"),
          ),
          new ListTile(
            title: Text("Cho phép hoạt động: "),
            trailing: Switch(
                value: viewModel.liveCampaign.isActive ?? false,
                onChanged: (value) {
                  viewModel.liveCampaign.isActive = value;
                  viewModel.changeStatus(value);

                  setState(() {});

                  //TODO bỏ setState cho trạng thái
                }),
          ),
          new ListTile(
            title: Text(
                "Danh sách sản phẩm (${viewModel.liveCampaign.details?.length ?? 0})"),
            trailing: Icon(Icons.chevron_right),
            onTap: () async {
              if (viewModel.liveCampaign.details == null) {
                viewModel.liveCampaign.details = new List<LiveCampaignDetail>();
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  SaleOnlineLiveCampaignSelectProductPage
                      saleOnlineLiveCampaignSelectProductPage =
                      new SaleOnlineLiveCampaignSelectProductPage(
                    details: viewModel.liveCampaign.details,
                  );
                  return saleOnlineLiveCampaignSelectProductPage;
                }),
              );
            },
          ),
/*          if (!viewModel.isEditMode)
            Row(
              children: <Widget>[
                new Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new RaisedButton.icon(
                      shape: OutlineInputBorder(
                        borderSide:
                        BorderSide(width: 1, color: Colors.green),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      textColor: Theme.of(context).primaryColor,
                      icon: Icon(Icons.close),
                      label: Text(
                        "Hủy bỏ",
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                new Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new RaisedButton.icon(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      icon: Icon(Icons.check),
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(width: 1, color: Theme.of(context).primaryColor),
                      ),
                      label: Text(
                        "Lưu",
                      ),
                      onPressed: () async {
                        viewModel.liveCampaign.name =
                            _nameTextController.text;
                        viewModel.liveCampaign.note =
                            _noteTextController.text;
                        if (await viewModel.save()) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),*/
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  @override
  void initState() {
    viewModel.initViewModel(editLiveCampaign: _liveCampaign);
    viewModel.dialogMessageController.listen((f) {
      registerDialogToView(context, f, scaffState: _scaffoldKey.currentState);
    });

    _noteTextController.text = viewModel.liveCampaign.note;
    _nameTextController.text = viewModel.liveCampaign.name;
    super.initState();
  }
}
