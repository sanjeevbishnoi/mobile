/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 9:47 AM
 *
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/ui.dart';
import 'package:tpos_mobile/src/tpos_apis/models/applicaton_config_current.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/find_ip_printer_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_setting_viewmodel.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/string_resources.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

class SaleFacebookCreateOrderSettingPage extends StatefulWidget {
  static final routeName = AppRoute.setting_sale_online;
  @override
  _SaleFacebookCreateOrderSettingPageState createState() =>
      _SaleFacebookCreateOrderSettingPageState();
}

class _SaleFacebookCreateOrderSettingPageState
    extends State<SaleFacebookCreateOrderSettingPage>
    with SingleTickerProviderStateMixin {
  //PROPERTY, CONTROLLER

  BuildContext scalfoldContext;
  Key _printSaleOnlineSwitchKey = new Key("printSaleOnlineSwitch");
  GlobalKey _scaffoldKey = new GlobalKey(debugLabel: "scaffold");
  TabController _tabController;
  ISettingService _setting = locator<ISettingService>();
  PrintService _printService = locator<PrintService>();
  ITposApiService _tposApi = locator<ITposApiService>();

  TextEditingController _computerPortTextEditController;
  TextEditingController _computerIpTextEditController;
  TextEditingController _lanPrinterIpTextEditController;
  TextEditingController _lanPrinterPortTextEditController;
  var viewModel = locator<ApplicationSettingViewModel>();
  var notifyProprtyChangeSubcribtion;
  ApplicationConfigCurrent _saleOnlinConfig;

  @override
  BuildContext get context => super.context;
  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this, initialIndex: 0);

    // Tải dữ liệu setting
    viewModel.loadSetting().then((data) {});

    // Lắng nghe tab thay đổi
    this._tabController.addListener(() {
      viewModel.saleOnlinePrintMethod = _tabController.index == 0
          ? PrintSaleOnlineMethod.LanPrinter
          : PrintSaleOnlineMethod.ComputerPrinter;
    });

    try {
      _tposApi.getCheckSaleOnlineSessionEnable().then((value) {
        setState(() {
          _saleOnlinConfig = value;
        });
      }).catchError((error) {});
    } catch (e) {}
    super.initState();

    viewModel.onStateAdd(false);
  }

  @override
  void didChangeDependencies() {
    // PropertyChange
    notifyProprtyChangeSubcribtion = viewModel.notifyPropertyChangedController
        .where((f) => f.isEmpty)
        .listen((name) {
      if (mounted) setState(() {});
    });

    // Dialog
    viewModel.dialogMessageController.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scaffoldKey.currentState);
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text("Cài đặt bán hàng online"),
        actions: <Widget>[],
      ),
      body: UIViewModelBase(
        child: _showBody(context),
        viewModel: viewModel,
      ),
      backgroundColor: Colors.grey.shade300,
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _showBody(BuildContext context) {
    _computerIpTextEditController =
        new TextEditingController(text: viewModel.computerIp);

    _computerPortTextEditController =
        new TextEditingController(text: viewModel.computerPort);

    _lanPrinterIpTextEditController =
        new TextEditingController(text: viewModel.lanPrinterIp);

    _lanPrinterPortTextEditController =
        new TextEditingController(text: viewModel.lanPrinterPort);

    if (viewModel.saleOnlinePrintMethod == PrintSaleOnlineMethod.LanPrinter) {
      _tabController.index = 0;
    } else if (viewModel.saleOnlinePrintMethod ==
        PrintSaleOnlineMethod.ComputerPrinter) {
      _tabController.index = 1;
    }

    var dividerMin = new Divider(
      height: 2,
    );

    var layoutDecorate = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    );

    var layoutHeaderStyle = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: layoutDecorate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.print),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "CẤU HÌNH IN",
                        textAlign: TextAlign.left,
                        style: layoutHeaderStyle,
                      ),
                    ],
                  ),
                ),
                dividerMin,
                new ListTile(
                  title: Text("In phiếu"),
                  trailing: GestureDetector(
                    onTap: () {},
                    child: Switch.adaptive(
                      dragStartBehavior: DragStartBehavior.down,
                      key: _printSaleOnlineSwitchKey,
                      value: viewModel.isEnablePrintSaleOnline,
                      onChanged: (value) {
                        setState(() {
                          viewModel.isEnablePrintSaleOnline = value;
                        });
                      },
                    ),
                  ),
                ),
                new ListTile(
                  title: Text("Cho phép in nhiều lần"),
                  subtitle: Text("In nhiều lần trên 1 comment"),
                  trailing: Switch.adaptive(
                      value: viewModel.isAllowPrintSaleOnlineManyTime,
                      onChanged: (value) {
                        setState(() {
                          viewModel.isAllowPrintSaleOnlineManyTime = value;
                        });
                      }),
                ),
                dividerMin,
                new Container(
                  height: 370,
                  child: new DefaultTabController(
                    length: 2,
                    child: Container(
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.green,
                            labelColor: Colors.red,
                            tabs: <Widget>[
                              new Tab(
                                child: Text("In máy in qua mạng"),
                              ),
//                        new Tab(
//                          child: Text("In máy in bluetooth"),
//                        ),
                              new Tab(
                                child: Text("In qua máy tính"),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                _showLanPrinterSetting(context),
                                _showComputerSetting(context),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                new ListTile(
                  title: Text("Mẫu in phiếu qua Lan"),
                  subtitle: Row(
                    children: <Widget>[
                      Expanded(
                        child: RadioListTile<String>(
                          value: "BILL80-NHANH",
                          title: Text("BILL80-NHANH"),
                          groupValue: _setting.saleOnlineSize,
                          onChanged: (value) {
                            setState(() {
                              _setting.saleOnlineSize = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: "BILL80-IMAGE",
                          title: Text("BILL80-ĐẸP"),
                          groupValue: _setting.saleOnlineSize,
                          onChanged: (value) {
                            setState(() {
                              _setting.saleOnlineSize = value;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                dividerMin,
                new ListTile(
                  title: Text("In địa chỉ"),
                  trailing: Switch.adaptive(
                      value: viewModel.isSaleOnlinePrintAddress,
                      onChanged: (value) {
                        setState(() {
                          viewModel.isSaleOnlinePrintAddress = value;
                        });
                      }),
                ),
                dividerMin,
                new ListTile(
                  title: Text("In thêm bình luận vào ghi chú & in"),
                  subtitle: Text(
                      "Tự thêm bình luận vào ghi chú đơn hàng và in bình luận đó"),
                  trailing: Switch.adaptive(
                      value: viewModel.isSaleOnlinePrintComment,
                      onChanged: (value) {
                        setState(() {
                          viewModel.isSaleOnlinePrintComment = value;
                        });
                      }),
                ),
                dividerMin,
                // In toàn bộ ghi chú
                new ListTile(
                  title: Text("In toàn bộ ghi chú"),
                  subtitle: Text(
                      "In toàn bộ ghi chú của đơn hàng (Khả dụng khi in qua  Tpos Printer)"),
                  trailing: Switch.adaptive(
                    value: viewModel.isSaleOnlinePrintAllOrderNote,
                    onChanged: (value) {
                      setState(() {
                        viewModel.isSaleOnlinePrintAllOrderNote = value;
                      });
                    },
                  ),
                ),
                dividerMin,

                ListTile(
                  title: Text("Nội dung in"),
                  isThreeLine: true,
                  subtitle: Text(
                      "Tùy chỉnh nội dung sẽ in ra (Tạm thời chỉ khả dụng với máy in qua mạng LAN): Nhấn để cấu hinh"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppRoute.setting_sale_online_print_via_lan);
                  },
                ),
                dividerMin,
                new SwitchListTile.adaptive(
                  title: Text("In header tùy chỉnh"),
                  subtitle:
                      Text("In header tùy chỉnh thay cho header mặc định"),
                  value: _setting.isSaleOnlinePrintCustomHeader,
                  onChanged: (value) {
                    setState(() {
                      _setting.isSaleOnlinePrintCustomHeader = value;
                    });
                  },
                ),

                dividerMin,
                new ListTile(
                  title: Text("Header tùy chỉnh"),
                  subtitle: Text(_setting.saleOnlinePrintCustomHeaderContent),
                  trailing: FlatButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            final headerTextController =
                                new TextEditingController(
                                    text: _setting
                                        .saleOnlinePrintCustomHeaderContent);
                            return AlertDialog(
                              title: Text("Nhập nội dung header"),
                              content: TextField(
                                controller: headerTextController,
                                maxLines: null,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Xong"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _setting.saleOnlinePrintCustomHeaderContent =
                                          headerTextController.text.trim();
                                    });
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: Text("Sửa"),
                    textColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: layoutDecorate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.print),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "FACEBOOK + ĐƠN HÀNG",
                        textAlign: TextAlign.left,
                        style: layoutHeaderStyle,
                      ),
                    ],
                  ),
                ),
                dividerMin,
                new ListTile(
                  title: Text("Tự động cập nhật bình luận ẩn"),
                  subtitle: Text("Tự động tải các bình luận có thể bị ẩn"),
                  trailing: Switch.adaptive(
                    value: _setting.saleOnlineFetchDurationEnableOnLive,
                    onChanged: (value) {
                      setState(() {
                        viewModel.isSaleOnlineEnableConnectFailAction = value;
                      });
                    },
                  ),
                ),
                dividerMin,
                new ListTile(
                  title: Text("Thời gian tự động tải (giây)"),
                  subtitle: Text(
                      "Tự lấy bình luận mỗi ${_setting.secondRefreshComment} giây nếu không kết nối được live"),
                  trailing: SizedBox(
                    width: 130,
                    child: NumberFieldWidget(
                      initNumber: viewModel.secondRefreshComment,
                      onChanged: (value) {
                        viewModel.secondRefreshComment = value;
                      },
                    ),
                  ),
                ),
                dividerMin,
                new ListTile(
                  title: Text("Số thứ tự phiếu."),
                  trailing: FlatButton(
                      textColor: ColorResource.hyperlinkColor,
                      onPressed: () async {
                        var result = await showQuestion(
                            context: context,
                            message: "Số thứ tự đơn hàng sẽ được reset về 0",
                            title: "Vui lòng xác nhận");

                        if (result == OldDialogResult.Yes) {
                          await viewModel.resetSaleOnlineSessionNumber();
                        }
                      },
                      child: Text(
                        "Reset",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )),
                  subtitle:
                      Text("Nhấn reset để cập lại số thứ tự đơn hàng về 0"),
                ),
                dividerMin,
                if (_saleOnlinConfig != null)
                  new SwitchListTile.adaptive(
                    title: Text("Bật số thứ tự phiếu"),
                    value: _saleOnlinConfig?.saleOnlineFacebookSessionEnable ??
                        false,
                    subtitle: Text(""),
                    onChanged: (value) async {
                      // Bật tắt số thứ tự phiếu

                      var confirmResult = await showQuestion(
                          context: context,
                          title: "Xác nhận",
                          message:
                              "Bạn có muốn ${_saleOnlinConfig.saleOnlineFacebookSessionEnable ? "Tắt" : "Bật"} số thứ tự phiếu");

                      if (confirmResult != OldDialogResult.Yes) return;
                      try {
                        _tposApi.updateSaleOnlineSessionEnable().then((value) {
                          setState(() {
                            _saleOnlinConfig = value;
                          });
                        });
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                dividerMin,

                // Cấu hình thời gian comment

                new SwitchListTile.adaptive(
                  title: Text("Kiểu hiển thị thời gian bình luận"),
                  subtitle: Text(
                      "Ví dụ: Bật (5 phút trước), Tắt (21/05/2019  12:00)"),
                  value: _setting.isSaleOnlineViewTimeAgoOnLiveComment,
                  onChanged: (value) {
                    setState(() {
                      _setting.isSaleOnlineViewTimeAgoOnLiveComment = value;
                    });
                  },
                ),
//          new Divider(),
//          new SwitchListTile.adaptive(
//              title:
//                  Text("Hiện thời gian bình luận cũ ở dạng thời gian trước đó"),
//              subtitle: Text(
//                  "Ví dụ Now, 5 Min, 1 hr. Nếu để mặc định thời gian sẽ hiện thị ở dạng '21/05/2019 11:00'"),
//              value: _setting.isSaleOnlineViewTimeAgoOnPostComment,
//              onChanged: (value) {
//                setState(() {
//                  _setting.isSaleOnlineViewTimeAgoOnPostComment = value;
//                });
//              }),
                dividerMin,
                new SwitchListTile.adaptive(
                    title: Text("Tải toàn bộ bình luận"),
                    subtitle: Text("Tải toàn bộ bình luận khi vào bài live"),
                    value: _setting.isSaleOnlineAutoLoadAllCommentOnLive,
                    onChanged: (value) {
                      setState(() {
                        _setting.isSaleOnlineAutoLoadAllCommentOnLive = value;
                      });
                    }),
//          new Divider(),
//          new SwitchListTile.adaptive(
//              title: Text("Tải toàn bộ bình luận khi vào bài live cũ"),
//              subtitle: Text(""),
//              value: _setting.isSaleOnlineAutoLoadAllCommentOnPost,
//              onChanged: (value) {
//                setState(() {
//                  _setting.isSaleOnlineAutoLoadAllCommentOnPost = value;
//                });
//              }),

                dividerMin,

                ListTile(
                  title: Text("Sắp xếp bình luận khi vào bài live"),
                  trailing: DropdownButton(
                      value: _setting.saleOnlineCommentDefaultOrderByOnLive,
                      items: [
                        DropdownMenuItem<SaleOnlineCommentOrderBy>(
                          child: Text("Mới nhất ở đầu"),
                          value: SaleOnlineCommentOrderBy.DATE_CREATE_DESC,
                        ),
                        DropdownMenuItem<SaleOnlineCommentOrderBy>(
                          child: Text("Mới nhất ở cuối"),
                          value: SaleOnlineCommentOrderBy.DATE_CREATED_ASC,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _setting.saleOnlineCommentDefaultOrderByOnLive =
                              value;
                        });
                      }),
                ),

                dividerMin,

                ListTile(
                  title: Text("Lọc bình luận theo facebook"),
                  subtitle: Text(
                      "Chỉ có các bình luận chất lượng hiển thị theo tỉ lệ bạn chọn"),
                  trailing: DropdownButton(
                      value: _setting.saleOnlineFetchCommentOnRealtimeRate,
                      items: [
                        DropdownMenuItem<CommentRate>(
                          child: Text("1 bình luận/ 2 giây"),
                          value: CommentRate.one_per_two_seconds,
                        ),
                        DropdownMenuItem<CommentRate>(
                          child: Text("10 bình luận/ giây"),
                          value: CommentRate.ten_per_second,
                        ),
                        DropdownMenuItem<CommentRate>(
                          child: Text("Nhiều nhất có thể"),
                          value: CommentRate.one_hundred_per_second,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _setting.saleOnlineFetchCommentOnRealtimeRate = value;
                        });
                      }),
                ),
                dividerMin,
                ListTile(
                  title: Text("Tự động lưu bình luận sau: (phút) "),
                  trailing: SizedBox(
                    width: 130,
                    child: NumberFieldWidget(
                      initNumber:
                          _setting.settingSaleOnlineAutoSaveCommentMinute,
                      onChanged: (value) {
                        setState(() {
                          _setting.settingSaleOnlineAutoSaveCommentMinute =
                              value;
                        });
                      },
                    ),
                  ),
                ),

                dividerMin,
                SwitchListTile.adaptive(
                  title: Text("Ẩn bình luận ít hơn 3 kí tự"),
                  subtitle: Text(
                      "Ví đụ để ẩn các bình luận '[.], [..]' không có giá trị chốt đơn"),
                  value: _setting.isSaleOnlineHideShortComment,
                  onChanged: (value) {
                    setState(() {
                      _setting.isSaleOnlineHideShortComment = value;
                    });
                  },
                ),

                dividerMin,
              ],
            ),
          ),
          new Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  color: Colors.deepPurple,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "XONG",
                    style: TextStyle(color: ColorResource.closeButtonTextColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showComputerSetting(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(10),
      child: new Column(
        children: <Widget>[
          new TextField(
            decoration: InputDecoration(
              hintText: "Địa chỉ IP",
              labelText: "Địa chỉ IP",
              suffixIcon: FlatButton(
                onPressed: () async {
                  PrinterDevice priner = await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return FindIpPrinterPage();
                      });

                  if (priner != null) {
                    _computerIpTextEditController.text = priner.ip;
                    _computerPortTextEditController.text =
                        priner.port.toString();

                    viewModel.computerIp = priner.ip;
                    viewModel.computerPort = priner.port.toString();
                  }
                },
                child: Text("Tìm"),
                textColor: Colors.blue,
              ),
            ),
            keyboardType:
                TextInputType.numberWithOptions(decimal: true, signed: true),
            controller: _computerIpTextEditController,
            onChanged: (text) {
              viewModel.computerIp = text;
            },
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp("[\\d|\.]")),
            ],
            maxLength: 15,
          ),
          new TextField(
            decoration: InputDecoration(
              hintText: "Port",
              labelText: "Port",
            ),
            keyboardType: TextInputType.number,
            controller: _computerPortTextEditController,
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            maxLength: 5,
            onChanged: (text) {
              viewModel.computerPort = text;
            },
          ),
          new Container(
            child: new RaisedButton(
              textColor: Colors.white,
              child: Text(
                "In thử",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                viewModel.printSaleOnlineTest();
              },
            ),
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  Widget _showLanPrinterSetting(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(10),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new TextField(
            decoration: InputDecoration(
              hintText: "Địa chỉ IP",
              labelText: "Địa chỉ IP",
              suffixIcon: FlatButton(
                onPressed: () async {
                  PrinterDevice printer = await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return FindIpPrinterPage(
                          isTposPrinterType: false,
                        );
                      });

                  if (printer != null) {
//                    _lanPrinterIpTextEditController.text = printer.ip;
//                    _lanPrinterPortTextEditController.text =
//                        printer.port.toString();

                    viewModel.lanPrinterIp = printer.ip;
                    viewModel.lanPrinterPort = printer.port.toString();
                  }
                },
                child: Text("Tìm"),
                textColor: Colors.blue,
              ),
            ),
            keyboardType:
                TextInputType.numberWithOptions(decimal: true, signed: true),
            controller: _lanPrinterIpTextEditController,
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp("[\\d|\.]")),
            ],
            maxLength: 15,
            onChanged: (value) {
              viewModel.lanPrinterIp = value;
            },
          ),
          new TextField(
            decoration: InputDecoration(
              hintText: "Port",
              labelText: "Port",
            ),
            keyboardType: TextInputType.number,
            controller: _lanPrinterPortTextEditController,
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            maxLength: 5,
            onChanged: (value) {
              viewModel.lanPrinterPort = value;
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("In không dấu"),
              Expanded(
                child: Checkbox(
                  value: _setting.settingPrintSaleOnlineNoSign,
                  onChanged: (value) {
                    setState(() {
                      _setting.settingPrintSaleOnlineNoSign = value;
                    });
                  },
                ),
              ),
              OutlineButton(
                child: Text(
                  "In thử",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  try {
                    viewModel.onStateAdd(true);
                    await _printService.printSaleOnlineLanTest();
                    viewModel.onStateAdd(false);
                  } catch (e) {
                    showError(
                        exception: e, title: "In đã lỗi", context: context);
                    viewModel.onStateAdd(false);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _showFindPrinter(bool isTposPrinter) {
    return FindIpPrinterPage();
  }
}
