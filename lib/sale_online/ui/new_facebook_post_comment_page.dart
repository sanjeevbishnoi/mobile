import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:screen/screen.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:tpos_mobile/category/product_search_page.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/tmt.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/game_lucky_wheel_page.dart';
import 'package:tpos_mobile/sale_online/ui/new_facebook_post_comment_search_comment_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_info_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_live_campaign_select_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_list_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_reply_facebook_comment_modal.dart';
import 'package:tpos_mobile/sale_online/ui/saleonline_facebook_post_summary_page.dart';
import 'package:tpos_mobile/sale_online/ui/ui.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_facebook_post_comment_viewmodel.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/facebook_apis/src/enums.dart';
import 'package:tpos_mobile/src/tpos_apis/models/crm_team.dart';
import 'package:tpos_mobile/src/tpos_apis/models/live_campaign.dart';
import 'package:tpos_mobile/src/tpos_apis/models/mail_template.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/widgets/custom_bottom_sheet.dart';

import '../../app_service_locator.dart';
import 'facebook_post_share_list_page.dart';
import 'new_facebook_post_comment_info_page.dart';
import 'package:flutter/cupertino.dart' as cupotino;

class NewFacebookPostCommentPage extends StatefulWidget {
  final FacebookPost facebookPost;
  final CRMTeam crmTeam;
  NewFacebookPostCommentPage({this.crmTeam, this.facebookPost});
  @override
  _NewFacebookPostCommentPageState createState() =>
      _NewFacebookPostCommentPageState();
}

class _NewFacebookPostCommentPageState
    extends State<NewFacebookPostCommentPage> {
  final _vm = NewFacebookPostCommentViewModel();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ScrollController _realtimeScrollController =
      new ScrollController(keepScrollOffset: true);
  final _locate = locator<ISettingService>().locate;

  /// on livestream scroll controller
  final ScrollController _noLiveScrollController =
      new ScrollController(initialScrollOffset: 0, keepScrollOffset: false);

  bool _isShowScrollUpButton;
  CommentItemModel _selectedCommentItem;

  StreamSubscription _eventSubsciption;
  StreamSubscription _realtimeConmmentSubscription;

  bool get _isRealtimeView =>
      _vm.currentPage == 1 && _vm.currentLiveStatus == LiveStatus.LIVE;

  set isShowScrollUpButton(bool value) {
    if (_isShowScrollUpButton != value) {
      setState(() {
        _isShowScrollUpButton = value;
      });
    }
  }

//  /// Nhảy tới cuối list
//  Future _scrollToLast([int milisecond = 500]) async {
//    await Future.delayed(Duration(milliseconds: 100));
//
//    final double animationOffset = 50000;
//    final double currentOffset =
//        _scrollController.position.maxScrollExtent - _scrollController.offset;
//    if (currentOffset <= animationOffset) {
//      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//          duration: Duration(milliseconds: milisecond), curve: Curves.easeIn);
//    } else {
//      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//    }
//  }

  /// Nhảy lên đầu list
  Future _scrollToFirst([int milisecond = 1000]) async {
    await Future.delayed(Duration(milliseconds: 100));
    final int animationOffset = 30000;
    if (_noLiveScrollController.offset <= animationOffset) {
      await _noLiveScrollController.animateTo(0,
          duration: Duration(milliseconds: milisecond), curve: Curves.easeIn);
    } else {
      _noLiveScrollController.jumpTo(0);
    }
  }

  Future _realTimeScrollToLast([int milisecond = 500]) async {
    if (!_realtimeScrollController.hasClients) return;
    await Future.delayed(Duration(milliseconds: 100));

    final double animationOffset = 50000;
    final double currentOffset =
        _realtimeScrollController.position.maxScrollExtent -
            _realtimeScrollController.offset;
    if (currentOffset <= animationOffset) {
      await _realtimeScrollController.animateTo(
          _realtimeScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: milisecond),
          curve: Curves.easeIn);
    } else {
      _realtimeScrollController
          .jumpTo(_realtimeScrollController.position.maxScrollExtent);
    }
  }

  /// Nhảy lên đầu list
  Future _realTimeScrollToFirst([int milisecond = 1000]) async {
    await Future.delayed(Duration(milliseconds: 100));
    final int animationOffset = 30000;
    if (_realtimeScrollController.offset <= animationOffset) {
      await _realtimeScrollController.animateTo(0,
          duration: Duration(milliseconds: milisecond), curve: Curves.easeIn);
    } else {
      _realtimeScrollController.jumpTo(0);
    }
  }

  void _showEditProduct() {
    final quantityController = new TextEditingController(
      text: _vm.productQuantity.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: OutlineInputBorder(
            gapPadding: 12,
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 0.5, color: Colors.indigo)),
        title: Text("${_vm.productName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("Số lượng: "),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[0-9.,]")),
                      PercentInputFormat(
                          locate: _locate, format: "###,###,###0.##"),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    onTap: () {
                      quantityController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: quantityController.text.length);
                    },
                    onChanged: (text) {
                      var number = Tmt.convertToDouble(text.trim(), "vi_VN");
                      setState(() {
                        _vm.setProductQuantity(number);
                      });
                    },
                  ),
                ),
                MySizedButton(
                  child: Icon(Icons.remove),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.5)),
                  onTap: () {
                    if (_vm.productQuantity > 1) {
                      _vm.setProductQuantity(_vm.productQuantity - 1);
                      quantityController.text = _vm.productQuantity.toString();
                    }

                    setState(() {});
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                MySizedButton(
                  child: Icon(Icons.add),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.5)),
                  onTap: () {
                    _vm.setProductQuantity(_vm.productQuantity + 1);
                    quantityController.text = _vm.productQuantity.toString();
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.red,
            child: Text("Bỏ chọn"),
            onPressed: () {
              Navigator.pop(context);
              _vm.setProduct(null);
            },
          ),
          RaisedButton(
            textColor: Colors.white,
            child: Text(
              "Chọn SP khác",
              textAlign: TextAlign.center,
            ),
            onPressed: () async {
              Navigator.pop(context);
              _showSelectProduct();
            },
          ),
          RaisedButton(
            textColor: Colors.white,
            child: Text(
              "Đóng",
              textAlign: TextAlign.center,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future _showSelectProduct() async {
    var product = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchPage(),
      ),
    );

    if (product != null) {
      _vm.setProduct(product);
    }
  }

  void _showEditCampaign() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          "Chiến dịch live: \n${_vm.liveCampaignName}",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  textColor: Colors.red,
                  child: Text("Bỏ chọn"),
                  onPressed: () {
                    Navigator.pop(context);
                    _vm.setLiveCampaign(null);
                  },
                ),
                RaisedButton(
                  textColor: Colors.white,
                  child: Text("Thay đổi chiến dịch"),
                  onPressed: () {
                    Navigator.pop(context);
                    _showSelectCampaign();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _showSelectCampaign() async {
    LiveCampaign campaign = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SaleOnlineLiveCampaignSelectPage()));
    if (campaign != null) {
      _vm.setLiveCampaign(campaign);
    }
  }

  void _onCreateOrder(CommentItemModel item) async {
    if (item.partnerPhone != null &&
        item.partnerPhone != "" &&
        (item.saleOnlineOrder?.telephone == null ||
            item.saleOnlineOrder.telephone == "")) {
//      showDialog(
//        context: context,
//        builder: (context) => AlertDialog(
//          title: Text("Xác nhận"),
//          content: Text(
//              "Đơn hàng đã tạo trước đó của khách hàng này chưa có số điện thoại, Bạn có muốn cập nhật?\nSố của khách: ${item.partnerPhone}"),
//          actions: <Widget>[
//            FlatButton(
//              child: Text("Thêm"),
//            )
//          ],
//        ),
//      );

      item.saleOnlineOrder?.telephone = item.partnerPhone;
    }
    _vm.createdOrder(item);
  }

  void _showPartnerAndOrderInfo(CommentItemModel item,
      [bool isOrder = false]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (buildContext) {
          return NewFacebookPostCommentInfoPage(
            comment: item,
            vm: _vm,
            initIndex: isOrder ? 1 : 0,
            onPartnerSaved: (partner, comment) {
              _vm.addPartner(partner, comment);
            },
          );
        },
      ),
    );
  }

  void _showCommentMoreAction(CommentItemModel item) async {
    if (mounted)
      setState(() {
        _selectedCommentItem = item;
      });
  }

  Future _hideComment(CommentItemModel item) async {
    var dialogResult = await showQuestion(
        context: context,
        title: "Ẩn comment",
        message:
            "Bạn có muốn ${item.facebookComment.isHidden ? "HIỆN" : "ẨN"} comment này");

    if (dialogResult == OldDialogResult.Yes) {
      _vm.hideComment(item, !item.facebookComment.isHidden);
    }
  }

  List<MailTemplate> mailTemplates;
  Future<List<MailTemplate>> getMailTemplate() async {
    if (mailTemplates == null) {
      var tposApi = locator<ITposApiService>();
      mailTemplates = await tposApi.getMailTemplates();
    }
    return mailTemplates;
  }

  Future _showReplyComment(CommentItemModel comment,
      {bool sendMessage = false}) async {
    bool result = await showModalBottomSheetFullPage(
      context: context,
      builder: (context) {
        return BottomSheet(
          backgroundColor: Colors.red,
          onClosing: () {},
          builder: (context) => SaleOnlineReplyFacebookCommentModal(
            comment: comment,
            accessToken: _vm.crmTeam.userOrPageToken,
            pageId: _vm.crmTeam.userAsuidOrPageId,
            isSendMessage: sendMessage,
            crmTeam: widget.crmTeam,
            postId: widget.facebookPost.id,
          ),
        );
      },
    );

    if (result != null) {
      if (result && sendMessage == false) {
        _vm.fetchReplyComment(comment);
      }
    }
  }

  void _showMoreCommentActionModal(CommentItemModel comment) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => BottomSheet(
        shape: OutlineInputBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.search),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${comment.facebookName}",
                  style: cupotino.TextStyle(color: Colors.indigo),
                ),
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (comment.partnerInfo?.address != null)
                    Padding(
                      padding: cupotino.EdgeInsets.only(bottom: 5),
                      child: Text("${comment.partnerInfo?.address}"),
                    ),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: <Widget>[
                      if (comment.partnerCode != null)
                        MySizedButton(
                          child: Text(
                            "${comment.partnerCode}",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PartnerInfoPage(
                                  partnerId: comment.partnerInfo?.partnerId,
                                ),
                              ),
                            );
                          },
                        ),
                      MySizedButton(
                        child: Text(
                          "${_vm.getCommentCountByFacebookAsuid(comment.facebookComment.from.id)} bình luận",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewFacebookPostCommentSearchComment(
                                vm: _vm,
                                autoFocus: false,
                                keyword: comment.facebookComment.from.id,
                              ),
                            ),
                          );
                        },
                      ),
                      if (comment.partnerPhone != null)
                        MySizedButton(
                          child: Text(
                            "Gọi ${comment.partnerPhone}",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                          onTap: () {
                            urlLauch("tel:${comment.partnerPhone}");
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              leading: Icon(Icons.message),
              subtitle: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlineButton(
                      child: Text("Trả lời"),
                      onPressed: () {
                        Navigator.pop(context);
                        _showReplyComment(comment);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: OutlineButton(
                      child: Text("Gủi inbox"),
                      onPressed: () {
                        Navigator.pop(context);
                        if (_vm.crmTeam.facebookTypeId == "User") {
                          urlLauch(
                              "fb://messaging/${comment.partnerInfo?.facebookUid}");
                        } else {
                          _showReplyComment(comment, sendMessage: true);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: OutlineButton(
                      child: Text("${comment.isHidden ? "Hiện" : "Ẩn"}"),
                      onPressed: () {
                        Navigator.pop(context);
                        _hideComment(comment);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostSummaryInfoModal() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => BottomSheet(
        shape: OutlineInputBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "TỔNG QUAN (${_vm.currentLiveStatus})",
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "${_vm.orderCount}\nhóa đơn",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Container(
                    width: 2,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Text(
                      "${_vm.orderProductCount}\nsản phẩm",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  Container(
                    width: 2,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Text(
                      "${_vm.partnerOnPostCount}/${_vm.partnerCount}\nKhách hàng",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    timeAgo.setLocaleMessages("vi_short", timeAgo.ViShortMessages());
    assert(widget.crmTeam != null);
    assert(widget.facebookPost != null);
    _vm.init(crmTeam: widget.crmTeam, post: widget.facebookPost);
    _eventSubsciption = _vm.eventController.listen(
      (event) async {
        switch (event.eventName) {
          case NewFacebookPostCommentViewModel.SCROLL_TO_FIRST:
            if (_vm.initLiveStatus == LiveStatus.LIVE) {
              if (!_realtimeScrollController.hasClients) return;
              await _realTimeScrollToLast(500);
              await Future.delayed(Duration(seconds: 1));
              if (_realtimeScrollController.position.pixels !=
                  _realtimeScrollController.position.maxScrollExtent) {
                _realTimeScrollToLast(200);
              }
            }
            break;

          case NewFacebookPostCommentViewModel.PAGGING_CHANGE_EVENT:
            break;
          case NewFacebookPostCommentViewModel.REQUIRED_GO_BACK:
            Navigator.pop(context);
            break;
        }
      },
    );

    _vm.initCommand();
    // Khi có comment mới
    _realtimeConmmentSubscription = _vm.realtimeCommentNotifySubject
        .debounceTime(Duration(milliseconds: 50))
        .listen(
      (comment) async {
        if (mounted) {
          if (!_realtimeScrollController.hasClients) return;
          if (_vm.isAutoScrollToLastEnable && _vm.currentPage == 1) {
            await _realTimeScrollToLast(400);
            if (_realtimeScrollController.position.pixels !=
                _realtimeScrollController.position.maxScrollExtent) {
              await _realTimeScrollToLast(200);
            }
            if (_realtimeScrollController.position.pixels <
                _realtimeScrollController.position.maxScrollExtent - 20) {
              await _realTimeScrollToLast(100);
            }
          }
        }
      },
    );

    _realtimeScrollController.addListener(() {
      //
      if (_realtimeScrollController.position.pixels >=
          _realtimeScrollController.position.maxScrollExtent - 150) {
        _vm.isAutoScrollToLastEnable = true;
      } else {
        _vm.isAutoScrollToLastEnable = false;
      }

      if (_vm.initLiveStatus == LiveStatus.LIVE) {
        // Hiện phân trang khi không ở cuối live
        if (_realtimeScrollController.position.maxScrollExtent -
                _realtimeScrollController.offset >
            300) {
          _vm.pageVisible = true;
        } else {
          _vm.pageVisible = false;
        }
        // Hiện nút scroll lên
        if (_realtimeScrollController.position.pixels >=
            _realtimeScrollController.position.maxScrollExtent - 2000) {
          isShowScrollUpButton = false;
        } else {
          isShowScrollUpButton = true;
        }
      } else {
        if (_realtimeScrollController.offset > 200) {
          isShowScrollUpButton = true;
        } else {
          isShowScrollUpButton = false;
        }
      }
    });

    _noLiveScrollController.addListener(() {
      if (_noLiveScrollController.offset > 200) {
        isShowScrollUpButton = true;
      } else {
        isShowScrollUpButton = false;
      }
    });

    // Keep screen on
    Screen.keepOn(true);
    super.initState();
  }

  Timer tm1;
  Widget _buildAppbar() {
    return AppBar(
      title: Text("Tạo đơn hàng"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            _showPostSummaryInfoModal();
          },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewFacebookPostCommentSearchComment(
                  vm: _vm,
                ),
              ),
            );
          },
        ),
//        IconButton(
//          icon: Icon(Icons.tag_faces),
//          onPressed: () async {
//            for (int i = 0; i < 10000; i++) {
//              await Future.delayed(Duration(milliseconds: 1));
//              var random = Random().nextInt(_vm.comments.length);
//              _vm.addFakeComment(_vm.comments[random].facebookComment);
//
//              // _listKey.currentState.insertItem(_vm.topComments.length - 1);
//            }
//          },
//        ),
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.list),
                  ),
                  Expanded(
                    child: Text(
                        "Đơn hàng (${_vm.orderCount} | ${_vm.orderProductCount ?? 0} SP)"),
                  ),
                ],
              ),
              value: "order",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.share),
                  ),
                  Expanded(
                    child: Text("Thống kê lượt share"),
                  ),
                ],
              ),
              value: "shareCount",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.apps),
                  ),
                  Expanded(
                    child: Text("Tổng quan bài đăng"),
                  ),
                ],
              ),
              value: "summary",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.file_download),
                  ),
                  Expanded(
                    child: Text("Tải lại bình luận"),
                  ),
                ],
              ),
              value: "refreshComment",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.save_alt),
                  ),
                  Expanded(
                    child: Text("Lưu bình luận"),
                  ),
                ],
              ),
              value: "saveComment",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.games),
                  ),
                  Expanded(
                    child: Text("Game"),
                  ),
                ],
              ),
              value: "game",
            ),
            PopupMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.settings),
                  ),
                  Expanded(
                    child: Text("Cài đặt"),
                  ),
                ],
              ),
              value: "setting",
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case "setting":
                Navigator.pushNamed(context, AppRoute.setting_sale_online);
                break;

              case "order":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaleOnlineOrderListPage(
                      postId: widget.facebookPost.id,
                    ),
                  ),
                );
                break;

              case "shareCount":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacebookPostShareListPage(
                      postId: widget.facebookPost.id,
                      pageId: _vm.crmTeam.userUidOrPageId,
                    ),
                  ),
                );
                break;

              case "summary":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaleOnlineFacebookPostSummaryPage(
                      postId: _vm.facebookPost.id,
                      crmTeam: _vm.crmTeam,
                    ),
                  ),
                );
                break;

              case "saveComment":
                _vm.saveComment();
                break;
              case "refreshComment":
                _vm.initCommand();
                break;

              case "game":
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameLuckyWheelPage(
                              postId: _vm.facebookPost.id,
                              uId: _vm.crmTeam.userUidOrPageId,
                              commentVm: _vm,
                            )));
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildCommentItemView(CommentItemModel item) {
    return CommentItemView(
      item: item,
      onTapCreateOrder: () => _onCreateOrder(item),
      onTapViewInfo: () => _showPartnerAndOrderInfo(item),
      onTapOrderNumber: () => _showPartnerAndOrderInfo(item, true),
      onTapItem: () => _showCommentMoreAction(item),
      isShowMoreActon: _selectedCommentItem == item,
      onTapHideComment: () => _hideComment(item),
      onTapSendReply: () => _showReplyComment(item),
      onTapSendInbox: () => _showReplyComment(item, sendMessage: true),
      onTapMoreAction: () => _showMoreCommentActionModal(item),
    );
  }

  Widget _buildCommentLayout(CommentItemModel item, [Animation anim]) {
    if (item.comments != null && item.comments.length > 0) {
      return Column(
        children: <Widget>[
          _buildCommentItemView(item),
          Column(
            children: item.comments
                .map((f) => Padding(
                      padding: const EdgeInsets.only(left: 50, top: 8),
                      child: _buildCommentItemView(f),
                    ))
                .toList(),
          ),
        ],
      );
    } else {
      return _buildCommentItemView(item);
    }
  }

  Widget _buildListComment() {
    print("BUILD LIST COMMENT");
    return ScopedModelDescendant<NewFacebookPostCommentViewModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          if (_vm.realtimeComments.length == 0 && _vm.isBusy == false) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.facebookMessenger,
                      color: Colors.grey.shade300,
                      size: 72,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Bài đăng không có bình luận",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Scrollbar(
            child: ListView.separated(
              key: ObjectKey(_vm.currentPage),
              controller: _noLiveScrollController,
              itemBuilder: (context, index) =>
                  _buildCommentLayout(_vm.viewComments[index]),
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: _vm.viewComments?.length ?? 0,
              padding: EdgeInsets.all(8),
            ),
          );
        });
  }

  Widget _buildListCommentRealtime() {
    return ScopedModelDescendant<NewFacebookPostCommentViewModel>(
      rebuildOnChange: true,
      builder: (context, child, model) {
        if (_vm.realtimeComments.length == 0 && _vm.isBusy == false) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.facebookMessenger,
                    color: Colors.grey.shade300,
                    size: 72,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Bài đăng không có bình luận",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return Scrollbar(
          child: ListView.separated(
            key: PageStorageKey("realtimeListview"),
            reverse: _vm.isReverseCommentList,
            controller: _realtimeScrollController,
            itemBuilder: (context, index) =>
                _buildCommentLayout(_vm.realtimeComments[index]),
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemCount: _vm.realtimeComments?.length ?? 0,
            padding: EdgeInsets.all(8),
          ),
        );
      },
    );
  }
//TODO Animation list
//  Widget _buildAnimationListComment() {
//    return ScopedModelDescendant<NewFacebookPostCommentViewModel>(
//      rebuildOnChange: true,
//      builder: (context, child, model) => Scrollbar(
//        child: AnimatedList(
//          key: _listKey,
//          controller: _realtimeScrollController,
//          padding: EdgeInsets.all(8),
//          reverse: true,
//          itemBuilder: (context, index, enim) {
//            return SizeTransition(
//              axis: Axis.vertical,
//              sizeFactor: enim,
//              child: Padding(
//                padding: const EdgeInsets.only(
//                  top: 8,
//                ),
//                child: _buildCommentLayout(_vm.comments[index]),
//              ),
//            );
//          },
//        ),
//      ),
//    );
//  }

  Widget _buildBodyHeader() {
    return ScopedModelDescendant<NewFacebookPostCommentViewModel>(
      builder: (context, child, model) => Container(
        alignment: Alignment.center,
        height: 45,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: EdgeInsets.only(left: 5, right: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_vm.currentLiveStatus == LiveStatus.LIVE)
//              SpinKitFadingCircle(
//                color: Colors.red,
//                size: 15,
//              ),
              cupotino.CupertinoActivityIndicator(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text("${_vm.commentCount}"),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.3),
                    borderRadius: BorderRadius.circular(3),
                    color: _vm.productName != null
                        ? Colors.indigo.shade500
                        : Colors.white),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: MyMaterialButton(
                          color: _vm.productName != null
                              ? Colors.indigo
                              : Colors.white,
                          content: AutoSizeText(
                            "${_vm.productName ?? "Chọn sản phẩm"}",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            minFontSize: 9,
                            style: TextStyle(
                                color: _vm.productName != null
                                    ? Colors.white
                                    : Colors.blue),
                          ),
                        ),
                        onTap: () {
                          _showSelectProduct();
                        },
                      ),
                    ),
                    Icon(Icons.arrow_drop_down),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.white,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    InkWell(
                      child: MyMaterialButton(
                        content: Text(
                          "x ${_vm.productQuantity}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        _showEditProduct();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.only(left: 5, right: 5),
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(width: 0.4),
                  borderRadius: BorderRadius.circular(3),
                  color: _vm.liveCampaignName != null
                      ? Colors.indigo.shade400
                      : Colors.white),
              child: InkWell(
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: AutoSizeText(
                          "${_vm.liveCampaignName ?? "Chọn chiến dịch"}",
                          style: TextStyle(
                              color: _vm.liveCampaignName != null
                                  ? Colors.white
                                  : Colors.blue),
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                onTap: () {
                  if (_vm.liveCampaignName != null)
                    _showEditCampaign();
                  else
                    _showSelectCampaign();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ScopedModelDescendant<NewFacebookPostCommentViewModel>(
      builder: (context, child, model) {
        return Column(
          children: <Widget>[
            _buildBodyHeader(),
            Expanded(
              child:
                  _vm.initLiveStatus == LiveStatus.LIVE && _vm.currentPage == 1
                      ? _buildListCommentRealtime()
                      : _buildListComment(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NewFacebookPostCommentViewModel>(
      model: _vm,
      child: Scaffold(
        appBar: _buildAppbar(),
        body: UIViewModelBase(
          viewModel: _vm,
          child: _buildBody(),
        ),
        floatingActionButton: _isShowScrollUpButton ?? false
            ? FloatingActionButton(
                mini: true,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () async {
                  if (_isRealtimeView) {
                    await _realTimeScrollToLast(2000);
                    _realTimeScrollToLast();
                  } else {
                    _scrollToFirst();
                  }
                },
                child: Icon(Icons.vertical_align_top),
              )
            : SizedBox(),
        bottomNavigationBar: Paging(
          onItemPress: (index) {
            _vm.currentPage = index;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _realtimeConmmentSubscription?.cancel();
    _eventSubsciption?.cancel();
    _vm.dispose();
    Screen.keepOn(false);
    super.dispose();
  }
}

/// Nội dung 1 bình luận
class CommentItemView extends StatelessWidget {
  final CommentItemModel item;
  final VoidCallback onTapCreateOrder;
  final VoidCallback onTapViewInfo;
  final VoidCallback onTapAvata;
  final VoidCallback onTapItem;
  final VoidCallback onTapSendReply;
  final VoidCallback onTapSendInbox;
  final VoidCallback onTapHideComment;
  final VoidCallback onTapOrderNumber;
  final VoidCallback onTapMoreAction;
  final bool isShowMoreActon;
  CommentItemView(
      {@required this.item,
      this.onTapCreateOrder,
      this.onTapViewInfo,
      this.onTapAvata,
      this.onTapItem,
      this.onTapSendReply,
      this.onTapSendInbox,
      this.onTapOrderNumber,
      this.onTapHideComment,
      this.onTapMoreAction,
      this.isShowMoreActon = false});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<CommentItemModel>(
      model: item,
      child: ScopedModelDescendant<CommentItemModel>(
          builder: (context, child, model) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //avatar
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(item.partnerAvata ?? ""),
                          child: item.partnerAvata != null ? null : Text("Av"),
                        ),
                      ),
                      onTap: onTapAvata,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: item.isHidden
                                  ? Colors.grey.shade100
                                  : Colors.green.shade50,
                              border: Border.all(
                                  color: Colors.green.shade100, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0, bottom: 5),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "${item.facebookName ?? ""}",
                                            style: TextStyle(
                                                color: item.isHidden
                                                    ? Colors.black54
                                                    : Colors.indigo.shade500,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (item.partnerCode != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Text(item.partnerCode),
                                          ),
                                        Text(
                                          item.commentTime,
                                          style: TextStyle(
                                              color: Colors.grey.shade400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Thông tin khách hàng (Có phone, địa chỉ, đơn hàng, trạng thái khách)
                                  if (item.isHasInfo)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: <Widget>[
                                          if (item.isHasPhone)
                                            InkWell(
                                              child: Icon(
                                                Icons.phone,
                                                color: Colors.green,
                                              ),
                                            ),
                                          if (item.isHasAddress)
                                            InkWell(
                                              child: Icon(
                                                Icons.location_on,
                                                color: Colors.purple,
                                              ),
                                            ),
                                          // Mã đơn hàng
                                          if (item.orderCode != null)
                                            InkWell(
                                              child: Material(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Text(
                                                    "${item.orderCode} ( ${item.saleOnlineOrder?.printCount ?? ""} )",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              onTap: onTapOrderNumber,
                                            ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          // Trạng thái khách hàng
                                          if (item.partnerStatusText != null &&
                                              item.partnerStatusText != "")
                                            InkWell(
                                              child: Material(
                                                color: getPartnerStatusColor(
                                                    item.partnerStatusStyle),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Text(
                                                    item.partnerStatusText ??
                                                        "",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(item.comment),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      MyMaterialButton(
                                        content: Builder(
                                          builder: (context) {
                                            if (item.isPrintError &&
                                                item.status == null) {
                                              return Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child: SizedBox()),
                                                  Text(
                                                    "In lỗi",
                                                    style: cupotino.TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              if (item.status != null)
                                                return Stack(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                    Text("${item.status}"),
                                                  ],
                                                );
                                              else
                                                return Text(
                                                  "Tạo đơn",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                );
                                            }
                                          },
                                        ),
                                        color: item.isBusy
                                            ? Colors.red
                                            : Colors.lightBlue,
                                        onTap: onTapCreateOrder,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      MyMaterialButton(
                                        contentText: "Thông tin",
                                        color: Colors.deepPurpleAccent,
                                        onTap: onTapViewInfo,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      MyMaterialButton(
                                        contentText: " ... ",
                                        color: Colors.grey.shade500,
                                        onTap: onTapMoreAction,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: onTapItem,
                        ),
                        if (isShowMoreActon)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Text(
                                      "Trả lời",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onTap: onTapSendReply,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Text(
                                      "Gửi inbox",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onTap: onTapSendInbox,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Text(
                                      item.facebookComment.isHidden
                                          ? "Hiện"
                                          : "Ẩn",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onTap: () {
                                      onTapHideComment();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )),
    );
  }
}

class MyPopupMenuItemContent extends StatelessWidget {
  final Widget icon;
  final String title;
  MyPopupMenuItemContent({this.icon, this.title});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        icon,
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(title),
        )
      ],
    );
  }
}

/// Nút bấm trong bình luận
class MyMaterialButton extends StatelessWidget {
  final String contentText;
  final Widget content;
  final Color textColor;
  final Color color;
  final Function onTap;

  MyMaterialButton(
      {this.content,
      this.contentText,
      this.textColor = Colors.white,
      this.color = Colors.green,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.purple,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 5, bottom: 5, right: 8),
            child: content ??
                Text(
                  contentText ?? "",
                  style: TextStyle(color: textColor),
                ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Custome button
class MySizedButton extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color color;
  final VoidCallback onTap;
  final BoxDecoration decoration;
  MySizedButton(
      {this.child,
      this.width,
      this.height,
      this.color,
      this.onTap,
      this.decoration});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration ??
          BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.purple,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 5, bottom: 5, right: 8),
            child: child,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class Paging extends StatefulWidget {
  final Function(int index) onItemPress;
  Paging({this.onItemPress});
  @override
  _PagingState createState() => _PagingState();
}

class _PagingState extends State<Paging> with TickerProviderStateMixin {
  Widget _buildPageItem(int index, {NewFacebookPostCommentViewModel model}) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 3, top: 3, bottom: 3),
      height: 40,
      width: 40,
      color: model.currentPage == index + 1 ? Colors.green : Colors.grey,
      child: Center(
        child: Text(
          "${index + 1}",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NewFacebookPostCommentViewModel>(
      builder: (context, child, model) {
        return AnimatedSize(
          duration: Duration(milliseconds: 300),
          vsync: this,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.indigo)),
            height: model.pageVisible ? 50 : 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    child: Badge(
                      badgeContent: Text(
                        "${model.notReadCommentCount}",
                        style: TextStyle(color: Colors.white),
                      ),
                      position: BadgePosition.topLeft(),
                      child: _buildPageItem(0, model: model),
                    ),
                    onTap: () {
                      if (widget.onItemPress != null) widget.onItemPress(1);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 0),
                    scrollDirection: Axis.horizontal,
                    itemCount: model.pageCount,
                    itemBuilder: (context, index) => index == 0
                        ? SizedBox()
                        : InkWell(
                            child: index == 0
                                ? Badge(
                                    badgeContent: Text(
                                      "${model.notReadCommentCount}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    position: BadgePosition.topLeft(),
                                    child: _buildPageItem(index, model: model),
                                  )
                                : _buildPageItem(index, model: model),
                            onTap: () {
                              if (widget.onItemPress != null)
                                widget.onItemPress(index + 1);
                            },
                          ),
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

class LiveQuickSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
