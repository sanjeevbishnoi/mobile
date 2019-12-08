/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/10/19 6:01 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/10/19 6:00 PM
 *
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/ui/check_address_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_info_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_address.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_facebook_post_comment_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/Address.dart';

import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_partner_add_edit_viewmodel.dart';

import '../../app_service_locator.dart';

class SaleOnlinePartnerAddEditPage extends StatefulWidget {
  final Partner partner;
  final CommentItemModel comment;
  final String facebookPostId;
  final CRMTeam crmTeam;
  final Function(Partner, CommentItemModel) onSaved;

  SaleOnlinePartnerAddEditPage({
    this.partner,
    @required this.comment,
    this.facebookPostId,
    @required this.crmTeam,
    this.onSaved,
  });
  @override
  _SaleOnlinePartnerAddEditPageState createState() =>
      _SaleOnlinePartnerAddEditPageState();
}

class _SaleOnlinePartnerAddEditPageState
    extends State<SaleOnlinePartnerAddEditPage> {
  _SaleOnlinePartnerAddEditPageState();
  SaleOnlinePartnerAddEditViewModel _vm =
      new SaleOnlinePartnerAddEditViewModel();

  final _tposApi = locator<ITposApiService>();

  TextEditingController partnerNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController noteController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController checkAddressController = new TextEditingController();
  TextEditingController currentTextEditController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // Pasrse param to viewmodel
    _vm.init(
      partner: widget.partner,
      comment: widget.comment,
      facebookPostId: widget.facebookPostId,
      crmTeam: widget.crmTeam,
      onSaved: widget.onSaved,
    );

    _vm.addListener(() {
      if (_vm.name != partnerNameController.text)
        partnerNameController.text = _vm.name;
      if (_vm.phone != phoneController.text) phoneController.text = _vm.phone;
      if (_vm.email != emailController.text) emailController.text = _vm.email;
      if (_vm.note != noteController.text) noteController.text = _vm.note;
      if (_vm.street != addressController.text)
        addressController.text = _vm.street;
    });

    _vm.initData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _vm.dispose();
  }

  Future _checkAddress(String keyword) async {
    CheckAddress value = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckAddressPage(
                  keyword: keyword,
                )));

    if (value != null) _vm.setCheckAddress(value);
  }

  Future _showSelectPartnerStatus() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chọn trạng thái"),
        content: Container(
          width: 500,
          child: FutureBuilder(
            future: _tposApi.getPartnerStatus(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.separated(
                itemBuilder: (context, index) => ListTile(
                  title: Text(snapshot.data[index].text),
                  onTap: () {
                    Navigator.pop(context);
                    _vm.setPartnerStatus(snapshot.data[index]);
                  },
                ),
                separatorBuilder: (context, index) => Divider(
                  height: 2,
                ),
                itemCount: snapshot.data?.length,
              );
            },
          ),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.red,
            child: Text("Đóng"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SaleOnlinePartnerAddEditViewModel>(
      model: _vm,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppbar(),
        body: UIViewModelBase(
          viewModel: _vm,
          child: _buildBody(),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildAppbar() {
    return PreferredSize(
      preferredSize: Size(100, 50),
      child: ScopedModelDescendant<SaleOnlinePartnerAddEditViewModel>(
        builder: (context, child, model) => AppBar(
          backgroundColor: Colors.indigo.shade200,
          title: Text(_vm.id != null ? "Sửa khách hàng" : "Khách hàng mới"),
          actions: <Widget>[
            if (model.id != null)
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartnerInfoPage(
                        partnerId: _vm.id,
                      ),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                _vm.save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressLayout() {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: checkAddressController,
              decoration: InputDecoration(
                  hintText: "tìm nhanh: vd: 54/35 dmc, tns, tp, hcm"),
              maxLines: null,
            ),
          ),
          FlatButton(
            child: Text(
              "Tìm",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () async {
              _checkAddress(checkAddressController.text.trim());
            },
          ),
        ],
      ),
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        TextField(
          controller: addressController,
          decoration:
              InputDecoration(hintText: "Địa chỉ khách", labelText: "Địa chỉ"),
          maxLines: null,
          onChanged: (text) {
            _vm.street = text.trim();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: <Widget>[
              Text("Tỉnh thành"),
              Expanded(
                child: InkWell(
                  child: Text(
                    _vm.city?.name ?? "Chọn tỉnh /thành phố",
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () async {
                    // Chọn tỉnh thành
                    Address result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectAddressPage(),
                      ),
                    );

                    if (result != null) {
                      _vm.setCity(new CityAddress(
                          code: result.code, name: result.name));
                    }
                  },
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: <Widget>[
              Text("Quận huyện"),
              Expanded(
                child: InkWell(
                  child: Text(
                    _vm.district?.name ?? "Chọn quận/ huyện",
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () async {
                    if (_vm.city == null) return;
                    Address result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectAddressPage(
                          cityCode: _vm.city.code,
                        ),
                      ),
                    );

                    if (result != null) {
                      _vm.setDistrict(new DistrictAddress(
                          code: result.code, name: result.name));
                    }
                  },
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: <Widget>[
              Text("Phường xã"),
              Expanded(
                child: InkWell(
                  child: Text(
                    _vm.ward?.name ?? "Chọn phường xã",
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () async {
                    if (_vm.district == null) return;
                    Address result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectAddressPage(
                          districtCode: _vm.district.code,
                          cityCode: _vm.city.code,
                        ),
                      ),
                    );

                    if (result != null) {
                      _vm.setWard(new WardAddress(
                          code: result.code, name: result.name));
                    }
                  },
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(SaleOnlineFacebookComment comment) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.comment),
            ),
            Expanded(
              child: Text(comment.message),
            ),
            Text(DateFormat("dd/MM/yyyy HH:mm")
                .format(comment.createdTime.toLocal())),
          ],
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text("Chọn thao tác"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.radio_button_checked),
                  title: Text("Tìm địa chỉ nhanh từ comment này"),
                  onTap: () {
                    Navigator.pop(context);
                    _checkAddress(comment.message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: ScopedModelDescendant<SaleOnlinePartnerAddEditViewModel>(
        builder: (context, child, model) => Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: partnerNameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.people),
                            hintText: "Tên khách hàng",
                            labelText: "Tên khách hàng",
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                          onChanged: (text) {
                            _vm.name = text.trim();
                          },
                        ),
                      ),
                      if (_vm.id != null)
                        FlatButton(
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textColor: Colors.white,
                          color: getPartnerStatusColor(
                              _vm.statusStyle ?? _vm.status),
                          child: Text("${_vm.statusText}"),
                          onPressed: () {
                            _showSelectPartnerStatus();
                          },
                        )
                    ],
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Số điện thoại",
                        labelText: "Số điện thoại"),
                    onChanged: (text) {
                      _vm.phone = text.trim();
                    },
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: "Email",
                        labelText: "Email"),
                    onChanged: (text) => _vm.email = text,
                  ),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.note),
                        hintText: "Ghi chú",
                        labelText: "Ghi chú"),
                    onChanged: (text) => _vm.note = text,
                  ),
                  _buildAddressLayout(),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlineButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text("ĐÓNG"),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RaisedButton(
                          child: Text("LƯU & ĐÓNG"),
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          padding: EdgeInsets.only(left: 0, right: 0),
                          onPressed: () async {
                            if (await _vm.save()) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RaisedButton(
                          padding: EdgeInsets.only(left: 0, right: 0),
                          child: Text("LƯU"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            _vm.save();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Bình luận gần đây (${_vm.commentCount})",
                      style: TextStyle(fontSize: 17, color: Colors.green),
                    ),
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          _buildCommentItem(_vm.comments[index]),
                      separatorBuilder: (context, index) => Divider(
                            height: 2,
                          ),
                      itemCount: _vm.commentCount)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
