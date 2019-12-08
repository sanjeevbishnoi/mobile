import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_price_list_viewmodel.dart';

class PosPriceListPage extends StatefulWidget {
  @override
  _PosPriceListPageState createState() => _PosPriceListPageState();
}

class _PosPriceListPageState extends State<PosPriceListPage> {
  var _vm = locator<PosPriceListViewModel>();

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosPriceListViewModel>(
        model: _vm,
        builder: (context, model, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Bảng giá mặc định"),
            ),
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 3),
                        blurRadius: 3,
                        color: Colors.grey[400])
                  ]),
                  child: ListView.builder(
                      itemCount: _vm.priceLists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context, _vm.priceLists[index]);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 2,
                                      color: Colors.grey[400])
                                ],
                                borderRadius: BorderRadius.circular(2)),
                            child: Text(
                              "${_vm.priceLists[index].name}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }),
                )),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.getPriceLists();
  }
}
