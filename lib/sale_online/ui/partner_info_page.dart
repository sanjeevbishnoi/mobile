import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/sale_online/ui/partner_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_list_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/partner_info_viewmodel.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_partner_status_dialog_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_status.dart';
import 'package:tpos_mobile/widgets/custom_bottom_sheet.dart';
import 'package:tpos_mobile/widgets/info_row.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../fast_sale_order/ui/fast_sale_order_list_page.dart';

class PartnerInfoPage extends StatefulWidget {
  final int partnerId;
  final Function onEditPartner;

  PartnerInfoPage({this.partnerId, this.onEditPartner});

  @override
  _PartnerInfoPageState createState() => _PartnerInfoPageState();
}

class _PartnerInfoPageState extends State<PartnerInfoPage> {
  PartnerInfoViewModel viewModel = PartnerInfoViewModel();
  Key refreshIndicatorKey = new Key("refreshIndicator");

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: viewModel,
      child: ScopedModelDescendant<PartnerInfoViewModel>(
        builder: (context, index, vm) {
          return Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              title:
                  Text("${viewModel.partner.name ?? "Thông tin khách hàng"}"),
              actions: <Widget>[
                FlatButton.icon(
                  textColor: Colors.white,
                  icon: Icon(Icons.edit),
                  label: Text("Sửa"),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        PartnerAddEditPage partnerAddEditPage =
                            new PartnerAddEditPage(
                          partnerId: viewModel.partner.id,
                          onEditPartner: (value) {
                            viewModel.partner = value;
                          },
                        );
                        return partnerAddEditPage;
                      }),
                    );
                    if (widget.onEditPartner != null)
                      widget.onEditPartner(viewModel.partner);
                  },
                ),
              ],
            ),
            body: UIViewModelBase(
              viewModel: viewModel,
              child: ScopedModel(
                model: viewModel,
                child: ScopedModelDescendant<PartnerInfoViewModel>(
                  builder: (context, index, vm) {
                    return DefaultTabController(
                      length: 4,
                      child: Column(
                        children: <Widget>[
                          new Container(
                            color: Colors.white,
                            constraints: BoxConstraints(maxHeight: 40.0),
                            child: new TabBar(
                              indicatorColor: Colors.green,
                              labelColor: Colors.green,
                              tabs: [
                                new Tab(
                                  text: "Thông tin",
                                ),
                                new Tab(
                                  text: "Đơn hàng",
                                ),
                                new Tab(
                                  text: "Hóa đơn",
                                ),
                                new Tab(
                                  text: "Công nợ",
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(children: <Widget>[
                              _buildInfo(),
                              SaleOnlineOrderListPage(
                                partner: viewModel.partner,
                              ),
                              FastSaleOrderListPage(
                                partnerId: viewModel.partner.id,
                              ),
                              _buildCredit(),
                            ]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo() {
    Uint8List _bytesImage;
    if (viewModel.partner.image != null &&
        viewModel.partner.image != "" &&
        viewModel.partner.image.contains("https://") == false) {
      _bytesImage = Base64Decoder().convert(viewModel.partner.image);
    }

    Divider dividerMin = new Divider(
      height: 2,
    );
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  child: viewModel.partner.imageUrl != null &&
                          viewModel.partner.imageUrl != ""
                      ? Image.network(
                          viewModel.partner.imageUrl,
                          height: 120,
                          width: 120,
                        )
                      : _bytesImage != null
                          ? Image.memory(_bytesImage)
                          : Image.asset("images/no_image.png"),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                                side: BorderSide(
                                    color: Colors.green,
                                    width: 1,
                                    style: BorderStyle.solid)),
                            color: getTextColorFromParterStatus(
                                viewModel.partner.status)[0],
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "${viewModel.partner?.statusText ?? "Chưa có trạng thái"} ",
                                    style: TextStyle(
                                        color: getTextColorFromParterStatus(
                                            viewModel.partner.status)[1]),
                                    textAlign: TextAlign.center,
                                  ),
                                  Icon(
                                    Icons.edit,
                                    color: getTextColorFromParterStatus(
                                        viewModel.partner.status)[1],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (widget.partnerId != null) {
                              PartnerStatus selectStatus = await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      content:
                                          SaleOnlineSelectPartnerStatusDialogPage(),
                                    );
                                  });

                              if (selectStatus != null) {
                                viewModel.updatePartnerStatus(
                                    selectStatus.value, selectStatus.text);
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Doanh số đầu kỳ: "),
                            Text(
                              "${vietnameseCurrencyFormat(viewModel.partnerRevenue.revenueBegan) ?? 0}",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Doanh số: "),
                            Text(
                              "${vietnameseCurrencyFormat(viewModel.partnerRevenue.revenue) ?? 0}",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Tổng doanh số: "),
                            Text(
                              "${vietnameseCurrencyFormat(viewModel.partnerRevenue.revenueTotal) ?? 0}",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Nợ hiện tại: "),
                            Text(
                              "${vietnameseCurrencyFormat(viewModel.partner.credit ?? 0)}",
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.only(top: 10),
              child: ExpansionTile(
                title: Text("Thông tin khách hàng"),
                initiallyExpanded: true,
                children: <Widget>[
                  InfoRow(
                    titleString: "Mã khách hàng: ",
                    content: Text(
                      "${viewModel.partner.ref ?? ""}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Tên khách hàng: ",
                    content: Text(
                      "${viewModel.partner.name ?? ""}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Điện thoại: ",
                    content: GestureDetector(
                      onTap: () {
                        showModalBottomSheetFullPage(
                          context: context,
                          builder: (context) {
                            return Container(
                              color: Color(0xFF737373),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.phone,
                                          color: Colors.green),
                                      title: Text(
                                          "Gọi ${viewModel.partner.phone}"),
                                      onTap: () async {
                                        _launchURL(
                                            "tel:${viewModel.partner.phone}");
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.message,
                                          color: Colors.green),
                                      title: Text(
                                          "Nhắn tin ${viewModel.partner.phone}"),
                                      onTap: () async {
                                        _launchURL(
                                            "sms:${viewModel.partner.phone}");
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        "${viewModel.partner.phone ?? ""}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Facebook: ",
                    content: GestureDetector(
                      onTap: () {
                        _launchURL(viewModel.partner.facebook);
                      },
                      child: Text(
                        "${viewModel.partner.facebook ?? ""}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Địa chỉ: ",
                    content: GestureDetector(
                      onTap: () {
                        String url = "https://www.google.com/maps/dir//";
                        if (viewModel.partner.addressFull.contains("/")) {
                          url = url.substring(0, url.length - 1);
                        }
                        _launchURL("$url${viewModel.partner.addressFull}");
                      },
                      child: Text(
                        "${viewModel.partner.addressFull ?? ""}",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: ExpansionTile(
                title: Text("Thông tin khác (FB, zalo, mail...)"),
                initiallyExpanded: true,
                children: <Widget>[
                  InfoRow(
                    titleString: "Nhóm khách hàng: ",
                    content: _buildPartnerCategory(context),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Email: ",
                    content: Text(
                      "${viewModel.partner.email ?? ""}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Sinh nhật: ",
                    content: Text(
                      "${viewModel.partner.birthDay != null ? DateFormat("dd/MM/yyyy").format(viewModel.partner.birthDay) : ""}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: null,
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Zalo",
                    content: Text(
                      "${viewModel.partner?.zalo ?? ""}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  dividerMin,
                  InfoRow(
                    titleString: "Mã số thuế",
                    content: Text(
                      "${viewModel.partner?.taxCode ?? ""}",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCategory(BuildContext context) {
    if (viewModel.partner.partnerCategories != null)
      return Wrap(
        spacing: 8.0,
        runSpacing: 0.0,
        children: List<Widget>.generate(
            viewModel.partner?.partnerCategories?.length, (index) {
          return Chip(
            backgroundColor: Colors.greenAccent.shade100,
            label: Text("${viewModel.partner?.partnerCategories[index]?.name}"),
          );
        }),
      );
    else
      return SizedBox();
  }

  Widget _buildCredit() {
    return Container(
      color: Colors.grey.shade200,
      child: RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: () async {
          return await viewModel.loadCreditDebitCustomerDetail();
        },
        child: Scrollbar(
          child: viewModel.creditDebitCustomerDetails?.length == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "Không có dữ liệu",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                )
              : new ListView.separated(
                  padding:
                      EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                  itemCount: viewModel.creditDebitCustomerDetails?.length ?? 0,
                  separatorBuilder: (ctx, index) {
                    return SizedBox(
                      height: 7,
                    );
                  },
                  itemBuilder: (context, position) {
                    return _buildItemCredit(
                        viewModel.creditDebitCustomerDetails[position]);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildItemCredit(CreditDebitCustomerDetail item) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade200,
        ),
      ),
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 10),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text(
                        "${DateFormat("dd/MM/yyyy").format(item.date ?? "")}",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  new Expanded(
                    child: new Text(
                        "${vietnameseCurrencyFormat(item.amountResidual ?? 0) ?? ""}",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
            subtitle: new Text(
              "${item.displayedName}",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
//      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    viewModel.partner.id = widget.partnerId;
    viewModel.initCommand();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
