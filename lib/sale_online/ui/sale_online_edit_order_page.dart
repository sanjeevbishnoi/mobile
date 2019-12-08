/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 5:35 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 5:32 PM
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_edit_products_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_address.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_partner_status_dialog_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_facebook_post_comment_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_order_edit_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/Address.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_status.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_facebook_comment.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order_detail.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';

class SaleOnlineEditOrderPage extends StatefulWidget {
  final SaleOnlineOrder order;
  final String orderId;
  final CommentItemModel comment;
  final String facebookPostId;
  final CRMTeam crmTeam;
  final Product product;
  final double productQuantity;
  final LiveCampaign liveCampaign;

  SaleOnlineEditOrderPage(
      {this.order,
      this.orderId,
      this.comment,
      this.facebookPostId,
      this.crmTeam,
      this.product,
      this.productQuantity,
      this.liveCampaign});

  @override
  _SaleOnlineEditOrderPageState createState() =>
      _SaleOnlineEditOrderPageState(order: this.order);
}

class _SaleOnlineEditOrderPageState extends State<SaleOnlineEditOrderPage> {
  SaleOnlineEditOrderViewModel viewModel = new SaleOnlineEditOrderViewModel();

  final GlobalKey<ScaffoldState> _scafffoldKey = new GlobalKey<ScaffoldState>();
  //  _formKey and _autoValidate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _validate = false;

  var customerNameTextController = new TextEditingController();
  var phoneNumberTextController = new TextEditingController();
  var emailTextController = new TextEditingController();
  TextEditingController noteTextController = new TextEditingController();

  var checkAddressTextController = new TextEditingController();
  var addressTextController = new TextEditingController();
  var cityAddressTextController = new TextEditingController();
  var districtAddressTextController = new TextEditingController();
  var wardAddressTextController = new TextEditingController();

  TextEditingController quantityTextController = new TextEditingController();

  SaleOnlineOrder order;
  _SaleOnlineEditOrderPageState({this.order});

  Divider dv = new Divider(
    indent: 10,
    color: Colors.red,
  );

  @override
  void initState() {
    viewModel.init(
        editOrder: order,
        orderId: widget.orderId,
        comment: widget.comment,
        facebookPostId: widget.facebookPostId,
        crmTeam: widget.crmTeam,
        product: widget.product,
        productQuantity: widget.productQuantity,
        liveCampaign: widget.liveCampaign);

    viewModel.initData();
    viewModel.dialogMessageController.stream.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scafffoldKey?.currentState);
    });

    viewModel.editOrderStream.listen((newOrder) {
      customerNameTextController.text = newOrder.name;
      phoneNumberTextController.text = newOrder.telephone;
      emailTextController.text = newOrder.email;
      noteTextController.text = newOrder.note;
      addressTextController.text = newOrder.address;
      cityAddressTextController.text = newOrder.cityName;
      districtAddressTextController.text = newOrder.districtName;
      wardAddressTextController.text = newOrder.wardName;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      key: _scafffoldKey,
      appBar: AppBar(
        leading: CloseButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.print,
            ),
            onPressed: () {
              viewModel.printSaleOnlineTag();
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              viewModel.editOrder.name = customerNameTextController.text;
              viewModel.editOrder.email = emailTextController.text;
              viewModel.editOrder.telephone = phoneNumberTextController.text;
              viewModel.editOrder.note = noteTextController.text;
              viewModel.editOrder.address = addressTextController.text;

              await viewModel.save();

              Navigator.pop(context, viewModel.editOrder);
            },
          ),
        ],
        title: Text(
            "${viewModel.editOrderId != null ? "Sửa đơn hàng" : "Đơn hàng mới"}"),
      ),
      body: ViewBaseWidget(
        isBusyStream: viewModel.isBusyController,
        child: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return Form(
      key: _formKey,
      autovalidate: _validate,
      child: SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            // Thông tin đơn hàng
            Container(
              child: new StreamBuilder<SaleOnlineOrder>(
                  stream: viewModel.editOrderStream,
                  initialData: viewModel.editOrder,
                  builder: (context, snapshot) {
                    return new ExpansionTile(
                      initiallyExpanded: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              "#${viewModel.editOrder?.sessionIndex ?? ""}. ${viewModel.editOrder?.code}"),
                          Text(
                            "Lần tạo: ${viewModel.editOrder?.printCount ?? "N/A"}",
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(
                            height: 30,
                            child: StreamBuilder<Partner>(
                              stream: viewModel.parterStream,
                              initialData: viewModel.partner,
                              builder:
                                  (context, AsyncSnapshot<Partner> snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    height: 25,
                                    color: getTextColorFromParterStatus(
                                        snapshot.data.status)[0],
                                    child: new OutlineButton(
                                      textColor: getTextColorFromParterStatus(
                                          snapshot.data.status)[1],
                                      child: Text(
                                          "${viewModel.partner?.statusText ?? ""}"),
                                      onPressed: () async {
//                                    var dialogResult = showQuestion(
//                                        context: context,
//                                        title: "Xác nhận thay đổi",
//                                        message:
//                                            "Vui lòng xác nhận để thay đổi trạng thái");
//                                    if (dialogResult == DialogResult.Yes) {
                                        PartnerStatus selectStatus =
                                            await showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return AlertDialog(
                                                    content:
                                                        SaleOnlineSelectPartnerStatusDialogPage(),
                                                  );
                                                });

                                        if (selectStatus != null) {
                                          viewModel.updateParterStatus(
                                              selectStatus.value,
                                              selectStatus.text);
                                        }

                                        //}
                                      },
                                    ),
                                  );
                                } else
                                  return SizedBox();
                              },
                            ),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Column(
                            children: <Widget>[
                              //Tên
                              TextField(
                                controller: customerNameTextController,
                                maxLines: null,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: "",
                                  labelText: 'Tên',
                                  prefixIcon: Icon(Icons.account_circle),
                                ),
                              ),
                              // Số điện thoại
                              TextField(
                                controller: phoneNumberTextController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.phone_android,
                                  ),
                                  hintText: '',
                                  labelText: 'Điện thoại',
                                  suffixIcon: FlatButton(
                                    onPressed: () {
                                      urlLauch(
                                          "tel:${phoneNumberTextController.text.trim()}");
                                    },
                                    child: Text(
                                      "Gọi",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                              // Email
                              TextFormField(
                                onSaved: (text) {
                                  viewModel.editOrder.email =
                                      emailTextController.text;
                                },
                                controller: emailTextController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                  hintText: 'abcdef@gmail.com',
                                  labelText: 'Email',
                                ),
                                //validator: viewModel.validateFormEmail,
                              ),
                              // Địa chỉ
                              TextField(
                                controller: addressTextController,
                                maxLines: null,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                  ),
                                  hintText: '',
                                  labelText: 'Nhập địa chỉ đầy đủ',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, top: 10),
                          child: Column(
                            children: <Widget>[
                              // Tỉnh thành
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    Address selectCity = await Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (ctx) =>
                                                new SelectAddressPage(
                                                  cityCode: null,
                                                  districtCode: null,
                                                )));

                                    viewModel.editOrder.cityCode =
                                        selectCity?.code;
                                    viewModel.editOrder.cityName =
                                        selectCity?.name;

                                    viewModel.editOrder.districtCode = null;
                                    viewModel.editOrder.districtName = null;
                                    viewModel.editOrder.wardCode = null;
                                    viewModel.editOrder.wardName = null;
                                    viewModel.editOrderSink
                                        .add(viewModel.editOrder);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${viewModel.editOrder?.cityName ?? "Chọn Tỉnh/Thành phố"}",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_right),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              //Quận huyện
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (viewModel.editOrder?.cityCode == null)
                                      return;
                                    Address selectCity = await Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (ctx) =>
                                                new SelectAddressPage(
                                                  cityCode: viewModel
                                                      .editOrder?.cityCode,
                                                  districtCode: null,
                                                )));

                                    viewModel.editOrder?.districtCode =
                                        selectCity?.code;
                                    viewModel.editOrder?.districtName =
                                        selectCity?.name;
                                    viewModel.editOrder?.wardCode = null;
                                    viewModel.editOrder?.wardName = null;
                                    viewModel.editOrderSink
                                        .add(viewModel?.editOrder);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${viewModel.editOrder?.districtName ?? "Chọn Quận/Huyện"}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: viewModel.editOrder
                                                          ?.districtName ==
                                                      null
                                                  ? Colors.red
                                                  : Colors.black),
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_right),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              // Phường
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (viewModel.editOrder.districtCode ==
                                        null) return;
                                    Address selectCity = await Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                        builder: (ctx) => new SelectAddressPage(
                                          cityCode:
                                              viewModel.editOrder?.cityCode,
                                          districtCode:
                                              viewModel.editOrder?.districtCode,
                                        ),
                                      ),
                                    );

                                    viewModel.editOrder.wardCode =
                                        selectCity?.code;
                                    viewModel.editOrder.wardName =
                                        selectCity?.name;
                                    viewModel.editOrderSink
                                        .add(viewModel.editOrder);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${viewModel.editOrder?.wardName ?? "Chọn Phường/Xã"}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: viewModel.editOrder
                                                          ?.wardName ==
                                                      null
                                                  ? Colors.red
                                                  : Colors.black),
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_right),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),

                        // Số nhà
                        new Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(
                                Icons.streetview,
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: TextField(
                                  controller: checkAddressTextController,
                                  autofocus: false,
                                  decoration: const InputDecoration(
                                    hintText: 'ví dụ: 54/35 tsn, tp, tp hcm',
                                  ),
                                  onTap: () {},
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 35,
                                  child: FlatButton(
                                    textColor: Colors.blue,
                                    padding: EdgeInsets.all(0),
                                    child: Text("Kiểm tra"),
                                    onPressed: () async {
                                      var result = await Navigator.pushNamed(
                                        context,
                                        AppRoute.check_address,
                                        arguments: {
                                          "keyword": checkAddressTextController
                                              .text
                                              .trim(),
                                        },
                                      );
//
                                      if (result != null) {
                                        viewModel.selectedCheckAddress = result;
                                        viewModel.fillCheckAddress(
                                            viewModel.selectedCheckAddress);
                                      }

                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    },
                                  )),
                            ),
                          ],
                        ),
                        //Ghi chú
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(
                                Icons.event_note,
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: TextField(
                                  onChanged: (text) {},
                                  maxLines: null,
                                  controller: noteTextController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: '',
                                    labelText: 'Ghi chú',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            // Chi tiết đơn hàng
            Container(
              color: Colors.white,
              child: StreamBuilder<SaleOnlineOrder>(
                  stream: viewModel.editOrderStream,
                  initialData: viewModel.editOrder,
                  builder: (context, snapshot) {
                    return new ListTile(
                      contentPadding: EdgeInsets.all(6),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        "Chi tiết đơn hàng (${viewModel.editOrder?.details?.length ?? 0})",
                        style: TextStyle(color: Colors.orange),
                      ),
                      trailing: Icon(Icons.chevron_right),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "${(snapshot.data?.details?.length ?? 0)} sản phẩm",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Tổng tiền: ${vietnameseCurrencyFormat(viewModel.totalAmount)}",
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "Chạm để chỉnh sửa chi tiết đơn hàng",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (viewModel.editOrder.details == null) {
                          viewModel.editOrder.details =
                              new List<SaleOnlineOrderDetail>();
                        }
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (ctx) {
                          return new SaleOnlineOrderEditProductsPage(
                              viewModel.editOrder.details);
                        }));
                      },
                    );
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            // Nút
            Container(color: Colors.white, child: _showButton()),
            SizedBox(
              height: 10,
            ),
            Container(color: Colors.white, child: _showRecentComments()),
          ],
        ),
      ),
    );
  }

  Widget _showRecentComments() {
    return StreamBuilder<List<SaleOnlineFacebookComment>>(
      stream: viewModel.recentCommentsObservable,
      initialData: viewModel.recentComments,
      builder: (ctx, recentCommentsSnapshot) {
        if (recentCommentsSnapshot.hasError) {
          return ListViewDataErrorInfoWidget();
        }

        if (recentCommentsSnapshot.data == null) {
          return SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text("Bình luận gần đây"),
            initiallyExpanded: true,
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: recentCommentsSnapshot.data.length,
                itemBuilder: (ctx, index) {
                  return FlatButton(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Icon(
                            Icons.message,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text:
                                          "${recentCommentsSnapshot.data[index].message} ",
                                      style: TextStyle(color: Colors.black)),
                                  TextSpan(
                                      text:
                                          "(${DateFormat("dd/MM/yyyy HH:mm").format(
                                        recentCommentsSnapshot
                                            .data[index].createdTime
                                            .toLocal(),
                                      )})",
                                      style: TextStyle(color: Colors.blue)),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) {
                            return ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  title: Text("Kiểm tra địa chỉ"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() async {
                                      checkAddressTextController.text =
                                          recentCommentsSnapshot
                                              .data[index].message;
                                      var result = await Navigator.pushNamed(
                                        context,
                                        AppRoute.check_address,
                                        arguments: {
                                          "keyword": checkAddressTextController
                                              .text
                                              .trim(),
                                        },
                                      );
//
                                      if (result != null) {
                                        viewModel.selectedCheckAddress = result;
                                        viewModel.fillCheckAddress(
                                            viewModel.selectedCheckAddress);
                                      }

                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    });
                                  },
                                ),
                                Divider(),
                                ListTile(
                                  title: Text("Thêm vào ghi chú"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    noteTextController.text = noteTextController
                                            .text +=
                                        "\n${recentCommentsSnapshot.data[index].message}";
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _showButton() {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: OutlineButton(
                padding: EdgeInsets.all(10),
                color: theme.primaryColor,
                child: Text(
                  "IN PHIẾU",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () async {
                  viewModel.printSaleOnlineTag();
                },
              ),
            ),
            new SizedBox(
              width: 10,
            ),
            new Expanded(
              flex: 1,
              child: RaisedButton(
                padding: EdgeInsets.all(10),
                color: theme.primaryColor,
                child: Text(
                  "LƯU",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  viewModel.editOrder.name = customerNameTextController.text;
                  viewModel.editOrder.email = emailTextController.text;
                  viewModel.editOrder.telephone =
                      phoneNumberTextController.text;
                  viewModel.editOrder.note = noteTextController.text;
                  viewModel.editOrder.address = addressTextController.text;

                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    await viewModel.save();
                    Navigator.pop(context, viewModel.editOrder);
                  } else {
                    setState(
                      () {
                        _validate = true;
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneNumberTextController.dispose();
    emailTextController.dispose();
    noteTextController.dispose();

    checkAddressTextController.dispose();
    addressTextController.dispose();
    cityAddressTextController.dispose();
    districtAddressTextController.dispose();
    wardAddressTextController.dispose();
    viewModel.dispose();
    super.dispose();
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
