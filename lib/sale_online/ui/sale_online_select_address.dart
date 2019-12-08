/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/sale_online/viewmodels/select_address_viewmodel.dart';

class SelectAddressPage extends StatefulWidget {
  final String cityCode;
  final String districtCode;
  SelectAddressPage({this.cityCode, this.districtCode});
  @override
  _SelectAddressPageState createState() => _SelectAddressPageState(
      cityCode: this.cityCode, districtCode: this.districtCode);
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  String cityCode;
  String districtCode;

  _SelectAddressPageState({this.cityCode, this.districtCode});
  SelectAddressViewModel viewModel = new SelectAddressViewModel();

  final TextEditingController _textController = new TextEditingController();

  @override
  void initState() {
    viewModel.cityCode = cityCode;
    viewModel.districtCode = districtCode;
    viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SelectAddressViewModel>(
      model: viewModel,
      child: Scaffold(
        appBar: buildAppBar(context),
        body: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return new StreamBuilder(
        stream: viewModel.addressStream,
        initialData: viewModel.address,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text("Đã xảy ra lỗi. Vui lòng tải lại"),
              );
            }

            return new ListView.builder(
//              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: viewModel.address?.length ?? 0,
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    new Divider(
                      height: 5.0,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context, viewModel.address[position]);
                        },
                        contentPadding: EdgeInsets.all(5),
                        title: Text(
                          "${viewModel.address[position].name}",
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        });
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: new TextField(
        autofocus: true,
        controller: _textController,
        style: new TextStyle(
          color: Colors.white,
        ),
        decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            hintText: "Chọn địa chỉ...",
            hintStyle: new TextStyle(color: Colors.white)),
        onChanged: (text) {
          viewModel.searchAddress(text);
        },
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.backspace),
          onPressed: () {
            _textController.clear();
            viewModel.searchAddress("");
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }
}
