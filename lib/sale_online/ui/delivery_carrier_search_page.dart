/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 4:07 PM
 *
 */

import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/sale_online/viewmodels/delivery_carrier_search_viewmodel.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';

class DeliveryCarrierSearchPage extends StatefulWidget {
  final DeliveryCarrier selectedDeliveryCarrier;
  final bool isSearch;
  final bool closeWhenDone;
  final Function(DeliveryCarrier) selectedCallback;
  DeliveryCarrierSearchPage(
      {this.selectedDeliveryCarrier,
      this.isSearch,
      this.closeWhenDone,
      this.selectedCallback});

  @override
  _DeliveryCarrierSearchPageState createState() =>
      _DeliveryCarrierSearchPageState(
          selectedDeliveryCarrier: this.selectedDeliveryCarrier,
          selectedCallback: this.selectedCallback,
          isSearch: this.isSearch,
          closeWhenDone: this.closeWhenDone);
}

class _DeliveryCarrierSearchPageState extends State<DeliveryCarrierSearchPage> {
  _DeliveryCarrierSearchPageState(
      {DeliveryCarrier selectedDeliveryCarrier,
      bool isSearch,
      bool closeWhenDone,
      Function(DeliveryCarrier) selectedCallback}) {
    _viewModel.init(
      selectedCarrier: selectedDeliveryCarrier,
      isCloseOnDone: closeWhenDone = closeWhenDone,
      isSearch: isSearch,
      selectedCallback: selectedCallback,
    );
  }

  var _viewModel = locator<DeliveryCarrierSearchViewModel>();

  @override
  void initState() {
    _viewModel.initCommand();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewBaseStateWidget(
      stateStream: _viewModel.stateController,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chọn đối tác giao hàng"),
        ),
        body: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return StreamBuilder<List<DeliveryCarrier>>(
        stream: _viewModel.deliveryCarriersStream,
        initialData: _viewModel.deliveryCarriers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ListViewDataErrorInfoWidget(
              errorMessage: "Đã xảy ra lỗi!. \n" + snapshot.error.toString(),
            );
          }
          return _showDeliveryCarrierList(_viewModel.deliveryCarriers);
        });
  }

  Widget _showDeliveryCarrierList(List<DeliveryCarrier> items) {
    if (items == null) {
      return Center(
        child: Text(""),
      );
    }
    if (items.length == 0) {
      return Center(
        child: Text("Không có dữ liệu!"),
      );
    }
    return ListView.separated(
        itemBuilder: (ctx, index) {
          return _showDeliveryCarrierItem(items[index]);
        },
        separatorBuilder: (ctx, index) {
          return Divider(
            height: 1,
            indent: 50,
          );
        },
        itemCount: (items?.length ?? 0));
  }

  Widget _showDeliveryCarrierItem(DeliveryCarrier item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text("${item.name.substring(0, 1)}"),
      ),
      title: Text("${item.name}"),
      onTap: () {
        if (_viewModel.selectedCallback != null)
          _viewModel.selectedCallback(item);
        if (_viewModel.isCloseOnDone) {
          Navigator.pop(context, item);
        } else {}
      },
    );
  }
}
