import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';

class FastSaleOrderAddEditFullOtherInfoPage extends StatefulWidget {
  final FastSaleOrderAddEditFullViewModel editVm;
  FastSaleOrderAddEditFullOtherInfoPage({this.editVm});
  @override
  _FastSaleOrderAddEditFullOtherInfoPageState createState() =>
      _FastSaleOrderAddEditFullOtherInfoPageState();
}

class _FastSaleOrderAddEditFullOtherInfoPageState
    extends State<FastSaleOrderAddEditFullOtherInfoPage> {
  var _vm = new FastSaleOrderAddEditFullOtherInfoViewModel();
  var _noteTextController = new TextEditingController();

  @override
  void initState() {
    _vm.init(editVm: widget.editVm);
    _noteTextController.text = widget.editVm.note;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FastSaleOrderAddEditFullOtherInfoViewModel>(
      model: _vm,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Thông tin khác"),
        ),
        body: _buildBody(),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: RaisedButton.icon(
            icon: Icon(Icons.keyboard_return),
            label: Text("QUAY LẠI ĐƠN HÀNG"),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ScopedModelDescendant<FastSaleOrderAddEditFullOtherInfoViewModel>(
      builder: (context, child, model) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context)?.requestFocus(new FocusNode());
          },
          child: Container(
            color: Colors.grey.shade300,
            child: ListView(
              children: <Widget>[
                // Người bán
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.people,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Người bán",
                        )
                      ],
                    ),
                    title: ScopedModelDescendant<
                        FastSaleOrderAddEditFullOtherInfoViewModel>(
                      builder: (ctx, child, model) {
                        return Text(
                          "${widget.editVm.user?.name ?? "Chọn người bán"}",
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.subtitle,
                        );
                      },
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () async {},
                  ),
                ),

                // Ngày hóa đơn

                SizedBox(
                  height: 1,
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                      right: 0,
                      left: 16,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.date_range,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Ngày hóa đơn:",
                        )
                      ],
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          DateFormat("dd/MM/yyyy HH:mm")
                              .format(model.invoiceDate),
                          style: TextStyle(fontSize: 15),
                        ),
                        IconButton(
                          onPressed: () async {
                            var selectedDate = await showDatePicker(
                              context: context,
                              initialDate: widget.editVm.order.dateInvoice,
                              firstDate:
                                  DateTime.now().add(new Duration(days: -365)),
                              lastDate: DateTime.now().add(
                                new Duration(days: 1),
                              ),
                            );

                            if (selectedDate != null) {
                              _vm.setInvoiceDate(selectedDate, false);
                            }
                          },
                          icon: Icon(Icons.date_range),
                        ),
                        IconButton(
                          onPressed: () async {
                            var selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: DateTime.now().hour,
                                    minute: DateTime.now().minute));

                            if (selectedTime != null) {
                              model.setInvoiceTime(selectedTime);
                            }
                          },
                          icon: Icon(Icons.access_time),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 1,
                ),

                Container(
                  padding:
                      EdgeInsets.only(left: 17, right: 8, top: 5, bottom: 10),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.note),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Ghi chú đơn hàng"),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _noteTextController,
                        maxLines: null,
                        onChanged: (text) {
                          widget.editVm.note = text;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              gapPadding: 10,
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                  style: BorderStyle.solid),
                            ),
                            hintText: "Để lại ghi chú"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FastSaleOrderAddEditFullOtherInfoViewModel extends ViewModel {
  FastSaleOrderAddEditFullViewModel _editVm;
  FastSaleOrderAddEditFullOtherInfoViewModel(
      {FastSaleOrderAddEditFullViewModel editVm}) {
    _editVm = editVm;
  }

  void init({FastSaleOrderAddEditFullViewModel editVm}) {
    _editVm = editVm;
  }

  DateTime get invoiceDate => _editVm.order.dateInvoice;

  void setInvoiceDate(DateTime value, bool isHour) {
    var temp = _editVm.order.dateInvoice;

    _editVm.order.dateInvoice = new DateTime(
        value.year,
        value.month,
        value.day,
        temp.hour,
        temp.minute,
        temp.second,
        temp.millisecond,
        temp.microsecond);

    notifyListeners();
  }

  void setInvoiceTime(TimeOfDay value) {
    var temp = _editVm.order.dateInvoice;
    _editVm.order.dateInvoice =
        new DateTime(temp.year, temp.month, temp.day, value.hour, value.minute);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
