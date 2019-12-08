import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/ui/ui.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery_info_viewmodel.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

class ReportDeliveryInfoPage extends StatefulWidget {
  final ReportDeliveryInfo order;

  ReportDeliveryInfoPage({@required this.order});

  @override
  _ReportDeliveryInfoPageState createState() => _ReportDeliveryInfoPageState();
}

class _ReportDeliveryInfoPageState extends State<ReportDeliveryInfoPage> {
  ReportDeliveryInfoViewModel viewModel = new ReportDeliveryInfoViewModel();

  final GlobalKey<ScaffoldState> _scafffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    viewModel.reportDeliveryInfo = widget.order;
    viewModel.initCommand(viewModel.reportDeliveryInfo.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ReportDeliveryInfoViewModel>(
      model: viewModel,
      child: UIViewModelBase(
        viewModel: viewModel,
        child: RefreshIndicator(
            child: ScopedModelDescendant<ReportDeliveryInfoViewModel>(
                builder: (context, child, model) {
              return Scaffold(
                key: _scafffoldKey,
                backgroundColor: Colors.grey.shade300,
                appBar: AppBar(
                    title:
                        Text("${viewModel.reportDeliveryInfo?.number ?? ""}")),
                body: Column(
                  children: <Widget>[
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              _showPaymentInfo(),
                              Container(
                                color: Colors.white,
                                child: ExpansionTile(
                                  title: Text(
                                    "Danh sách sản phẩm",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  initiallyExpanded: true,
                                  children: <Widget>[
                                    _showOrderLines(
                                        viewModel.reportDeliveryOrderLines),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: Colors.white,
                                child: _showSummary(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            onRefresh: () async {}),
      ),
    );
  }

  Widget _showOrderLines(List<ReportDeliveryOrderLine> items) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (ctx, index) {
          return _showOrderLineItem(items[index]);
        },
        separatorBuilder: (ctx, index) {
          return Divider(
            height: 0,
          );
        },
        itemCount: items?.length ?? 0,
      ),
    );
  }

  Widget _showOrderLineItem(ReportDeliveryOrderLine item) {
    return SizedBox(
      width: double.infinity,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
        dense: true,
        title: Text(
          item.productName ?? item.productNameGet,
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Row(
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                    text: "${item.productUOMQty} (${item.productUOMName})",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: "  x   "),
                      TextSpan(
                          text: vietnameseCurrencyFormat(item.priceUnit ?? 0),
                          style: TextStyle(color: Colors.blue)),
                      item.discount > 0
                          ? TextSpan(text: " (giảm ${item.discount})%")
                          : item.discountFixed > 0
                              ? TextSpan(
                                  text:
                                      " (giảm ${vietnameseCurrencyFormat(item.discountFixed.toDouble())})")
                              : TextSpan(),
                    ]),
              ),
            ),
            Text(
              vietnameseCurrencyFormat(item.priceTotal ?? 0),
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showPaymentInfo() {
    TextStyle _contentTextStyle = new TextStyle(color: Colors.green);
    return Container(
      child: Column(
        children: [
          // Thông tin chung
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Số HĐ: "),
                      Text(
                        "${viewModel.reportDeliveryInfo?.number ?? ""}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Ngày đơn hàng: "),
                      Text(
                        "${viewModel.reportDeliveryInfo?.dateInvoice != null ? DateFormat("dd/MM/yyyy HH:mm", "en_US").format(viewModel.reportDeliveryInfo?.dateInvoice) : ""}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Khách hàng: "),
                      Expanded(
                        child: Text(
                          "${viewModel.reportDeliveryInfo?.partnerDisplayName ?? ""}",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Điện thoại: "),
                      Text(
                        "${viewModel.reportDeliveryInfo?.phone ?? ""}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Địa chỉ: "),
                      Expanded(
                        child: Text(
                          "${viewModel.reportDeliveryInfo?.address ?? ""}",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Người bán: "),
                      Text(
                        "${viewModel.reportDeliveryInfo?.userName ?? ""}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Ghi chú: "),
                      Text(
                        "${viewModel.reportDeliveryInfo?.comment ?? ""}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  InfoRow(
                    titleString: "Trạng thái: ",
                    contentString: viewModel.reportDeliveryInfo?.showState,
                    contentTextStyle: _contentTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: getFastSaleOrderStateOption(
                                state: viewModel.reportDeliveryInfo?.state)
                            .textColor),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _showSummary() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: ListTile.divideTiles(context: context, tiles: [
        InfoRow(
          titleString: "Cộng tiền:",
          content: Text(
            vietnameseCurrencyFormat(
              viewModel.reportDeliveryInfo.amountUntaxed ?? 0,
            ),
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        InfoRow(
          titleString:
              "Chiết khấu (${viewModel.reportDeliveryInfo.discount}%):",
          content: Text(
            vietnameseCurrencyFormat(
                viewModel.reportDeliveryInfo.discountAmount ?? 0),
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        InfoRow(
          titleString: "Giảm tiền :",
          content: Text(
            vietnameseCurrencyFormat(
                viewModel.reportDeliveryInfo.decreaseAmount ?? 0),
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        InfoRow(
          titleString: "Tổng tiền :",
          content: Text(
            vietnameseCurrencyFormat(
                viewModel.reportDeliveryInfo.amountTotal ?? 0),
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
        InfoRow(
          titleString: "Còn nợ:",
          content: Text(
            vietnameseCurrencyFormat(
                viewModel.reportDeliveryInfo.residual ?? 0),
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ]).toList(),
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
