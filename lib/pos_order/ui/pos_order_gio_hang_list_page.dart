import 'package:flutter/material.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_order_gio_hang_list_viewmodel.dart';

import '../../app_service_locator.dart';

class PosOrderGioHangListPage extends StatefulWidget {
  @override
  _PosOrderGioHangListPageState createState() =>
      _PosOrderGioHangListPageState();
}

class _PosOrderGioHangListPageState extends State<PosOrderGioHangListPage> {
  var _vm = locator<PosOrderGioHangListViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Giỏ hàng"),
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: 5,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 6.0, mainAxisSpacing: 6.0),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {},
              child: Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 4,
                                color: Colors.grey[300])
                          ]),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: Icon(
                                Icons.shopping_cart,
                                size: 56,
                                color: Colors.grey[300],
                              ),
                            ),
                            Visibility(
                              visible: true,
                              child: Text(
                                "Giỏ hàng đang trống",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            )
                          ],
                        ),
                      )),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      child: Text("246"),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.getSession();
  }
}
