import 'package:flutter/material.dart';

class FastSaleOrderCreatePaymentPage extends StatefulWidget {
  @override
  _FastSaleOrderCreatePaymentPageState createState() =>
      _FastSaleOrderCreatePaymentPageState();
}

class _FastSaleOrderCreatePaymentPageState
    extends State<FastSaleOrderCreatePaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thanh toán"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.grey.shade300,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Material(
                    color: Colors.white,
                    child: ListTile(
                      leading: Text("Phương thức: "),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Material(
                    color: Colors.white,
                    child: ListTile(
                      leading: Text("Tổng tiền hàng:"),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          enabled: false,
                          controller: TextEditingController(text: "100.000"),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                              hintText: "", border: InputBorder.none),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Material(
                    color: Colors.white,
                    child: ListTile(
                      leading: Text("Giảm giá:"),
                      title: Container(
                        height: 30,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              child: RaisedButton(
                                child: Text("VNĐ"),
                                color: Colors.green,
                                padding: EdgeInsets.all(0),
                                onPressed: () {},
                              ),
                              width: 50,
                            ),
                            SizedBox(
                              child: RaisedButton(
                                child: Text("%"),
                                onPressed: () {},
                                padding: EdgeInsets.all(0),
                              ),
                              width: 50,
                            ),
                          ],
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: TextEditingController(text: "0"),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Material(
                    color: Colors.white,
                    child: ListTile(
                      leading: Text("Thanh toán:"),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: TextEditingController(text: "100.000"),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: "",
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 45,
          width: double.infinity,
          padding: EdgeInsets.only(top: 0),
          child: RaisedButton(
            child: Text("THANH TOÁN"),
            color: Colors.deepPurple,
            textColor: Colors.white,
            onPressed: () {},
          ),
        )
      ],
    );
  }
}
