import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order_detail.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_edit_order_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_order_info_viewmodel.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

// ignore: must_be_immutable
class SaleOnlineOrderInfoPage extends StatefulWidget {
  SaleOnlineOrder order;
  String orderId;

  SaleOnlineOrderInfoPage({this.order, this.orderId});

  @override
  _SaleOnlineOrderInfoPageState createState() =>
      _SaleOnlineOrderInfoPageState(order: this.order);
}

class _SaleOnlineOrderInfoPageState extends State<SaleOnlineOrderInfoPage> {
  SaleOnlineOrder order;
  _SaleOnlineOrderInfoPageState({this.order});
  SaleOnlineOrderInfoViewModel viewModel = new SaleOnlineOrderInfoViewModel();

  final GlobalKey<ScaffoldState> _scafffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    viewModel.init(editOrder: order, orderId: widget.orderId);
    viewModel.notifyPropertyChangedController.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          FlatButton.icon(
            textColor: Colors.white,
            icon: Icon(Icons.edit),
            label: Text("Sửa"),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => SaleOnlineEditOrderPage(
                    order: widget.order,
                    orderId: widget.orderId,
                  ),
                ),
              );

              viewModel.reloadCommand();
            },
          ),
        ],
        title: Text("Thông tin đơn hàng"),
      ),
      body: ViewBaseWidget(
        isBusyStream: viewModel.isBusyController,
        propertyChangedStream: viewModel.notifyPropertyChangedController,
        child: Container(
          color: Colors.grey.shade200,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _showPaymentInfo(),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: Text(
                          "Chi tiết đơn hàng (${viewModel.orderLines?.length ?? 0})"),
                      initiallyExpanded: true,
                      children: <Widget>[
                        Builder(
                          builder: (ctx) {
                            if (viewModel.orderLines != null) {
                              return _showOrderLines(viewModel.orderLines);
                            } else {
                              return SizedBox();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _showSummary(),
                  //_showButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showPaymentInfo() {
    return StreamBuilder<SaleOnlineOrder>(
      stream: viewModel.orderStream,
      initialData: viewModel.order,
      builder: (ctx, snapshot) {
        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Mã: "),
                        Text(
                          "${snapshot.data?.code ?? ""}",
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
                        Text("Ngày tạo: "),
                        Text(
                          "${snapshot.data?.dateCreated != null ? DateFormat("dd/MM/yyyy HH:mm", "en_US").format(snapshot.data?.dateCreated) : ""}",
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
                        Text("Tên: "),
                        Text(
                          "${snapshot.data?.name ?? ""}",
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
                        Text("Facebook: "),
                        Text(
                          "${snapshot.data?.facebookUserId ?? ""}",
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
                        Text("Điện thoại: "),
                        Text(
                          "${snapshot.data?.telephone ?? ""}",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Trạng thái: "),
                        Text(
                          "${snapshot.data?.statusText ?? ""}",
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
                          "${snapshot.data?.note ?? ""}",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _showOrderLines(List<SaleOnlineOrderDetail> items) {
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
        itemCount: items.length,
      ),
    );
  }

  Widget _showSummary() {
    return Container(
      color: Colors.white,
      child: InfoRow(
        titleString: "Tổng tiền: ",
        contentColor: Colors.red,
        contentString:
            vietnameseCurrencyFormat(viewModel.order?.totalAmount ?? 0),
      ),
    );
  }

  Widget _showOrderLineItem(SaleOnlineOrderDetail item) {
    return SizedBox(
      width: double.infinity,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
        dense: true,
        title: Text(
          item.productName ?? "",
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Row(
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                    text: "${item.quantity} (${item.uomName})",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: "  x   "),
                      TextSpan(
                          text: vietnameseCurrencyFormat(item.price ?? 0),
                          style: TextStyle(color: Colors.blue)),
                    ]),
              ),
            ),
            Text(
              vietnameseCurrencyFormat(
                  (item.quantity ?? 0) * (item.price ?? 0)),
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
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
