/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/crm_team.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_facebook_post_viewmodel.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'new_facebook_post_comment_page.dart';

class SaleOnlineFacebookPostPage extends StatefulWidget {
  final CRMTeam crmTeam;

  SaleOnlineFacebookPostPage({
    @required this.crmTeam,
  });

  @override
  _SaleOnlineFacebookPostPageState createState() =>
      _SaleOnlineFacebookPostPageState();
}

class _SaleOnlineFacebookPostPageState
    extends State<SaleOnlineFacebookPostPage> {
  final dividerMin = new Divider(
    height: 2,
  );

  _SaleOnlineFacebookPostPageState();

  SaleOnlineFacebookPostViewModel viewModel =
      saleOnlineViewModelLocator<SaleOnlineFacebookPostViewModel>();

  ScrollController postScrollController = new ScrollController();
  bool _isPullToRefresh = false;
  @override
  void initState() {
    super.initState();

    viewModel.init(
      crmTeam: widget.crmTeam,
    );

    viewModel.dialogMessageController.listen((data) {
      registerDialogToView(context, data);
    });

    postScrollController.addListener(() {
      double maxScroll = postScrollController.position.maxScrollExtent;
      double currentScroll = postScrollController.position.pixels;
      double delta = 200.0; // or something else..
      if (maxScroll - currentScroll <= delta) {
        // whatever you determine here
        viewModel.loadMoreFacebookPostCommand();
      }
    });

    timeAgo.setLocaleMessages("vi", timeAgo.ViMessages());
  }

  @override
  void didChangeDependencies() {
    viewModel.notifyPropertyChangedController.listen((name) {
      setState(() {});
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("${widget.crmTeam.name}"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctxt) {
                    TextEditingController _customPostIdController =
                        new TextEditingController();
                    return new AlertDialog(
                      title: Text("Nhập ID Live video"),
                      content: new TextField(
                        controller: _customPostIdController,
                        style: TextStyle(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: "Ví dụ: 1722166934595222",
                            labelText: "ID Bài đăng"),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("HỦY BỎ"),
                          onPressed: () {
                            Navigator.pop(ctxt);
                          },
                        ),
                        FlatButton(
                          child: Text("ĐỒNG Ý"),
                          onPressed: () {
                            Navigator.pop(ctxt);
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (ctxt) {
                                  return NewFacebookPostCommentPage(
                                    crmTeam: widget.crmTeam,
                                    facebookPost: new FacebookPost(
                                      type: "video",
                                      id: "${widget.crmTeam.userAsuidOrPageId}_${_customPostIdController.text.trim()}",
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: UIViewModelBase(
        viewModel: viewModel,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _showHeader(),
            Expanded(child: _showPost()),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _showHeader() {
    return new Container(
      color: Colors.white,
      height: 50,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Text("Loại: "),
          new StreamBuilder<FacebookPostType>(
              stream: viewModel.postTypeStream,
              initialData: viewModel.postType,
              builder: (context, snapshot) {
                return new DropdownButton(
                  underline: SizedBox(),
                  style: TextStyle(color: Colors.blueAccent, fontSize: 17),
                  hint: Text("Lọc theo"),
                  items: FacebookPostType.values.map((FacebookPostType f) {
                    String name = "";
                    switch (f) {
                      case FacebookPostType.all:
                        name = "Tất cả";
                        break;
                      case FacebookPostType.link:
                        name = "Link";
                        break;
                      case FacebookPostType.video:
                        name = "Video";
                        break;
                      case FacebookPostType.photo:
                        name = "Photo";
                        break;
                      case FacebookPostType.offer:
                        name = "Offer";
                        break;
                      case FacebookPostType.status:
                        name = "Status";
                        break;
                    }

                    return new DropdownMenuItem<FacebookPostType>(
                      value: f,
                      child: Text(
                        "$name",
                      ),
                    );
                  }).toList(),
                  onChanged: (item) {
                    viewModel.postType = item;
                    viewModel.refreshFacebookPost();
                  },
                  value: viewModel.postType,
                );
              }),
          new Checkbox(
            value: viewModel.isOnlyShowPostHasComment,
            onChanged: (bool value) {
              setState(() {
                viewModel.isOnlyShowPostHasComment = value;
                viewModel.refreshFacebookPost();
              });
            },
          ),
          Expanded(
            child: new Text(
              "Chỉ hiện > 10 bình luận:",
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  String trimComment(String comment) {
    if (comment != null && comment != "") {
      if (comment.runes.length >= 100) {
        // return comment.substring(0, 100);
        return String.fromCharCodes(comment.runes, 0, 100) + "...";
      } else {
        return comment;
      }
    } else {
      return "";
    }
  }

  Widget _showPost() {
    return RefreshIndicator(
      semanticsLabel: "Loading",
      semanticsValue: "Loading",
      onRefresh: () async {
        _isPullToRefresh = true;
        await viewModel.refreshFacebookPost();
        _isPullToRefresh = false;
        return Future.value(true);
      },
      child: new StreamBuilder<List<FacebookPost>>(
        stream: viewModel.facebookPostsStream,
        initialData: viewModel.facebookPosts,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: FlatButton(
                  child: Text(
                    "${snapshot.error}",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    setState(() {});
                    await viewModel.refreshFacebookPost();
                  },
                ),
              );
            }

            return StreamBuilder<bool>(
                stream: viewModel.isLoadingFacebookPostStream,
                initialData: viewModel.isLoadingFacebookPost,
                builder: (context, snapshot) {
                  if (snapshot.data && _isPullToRefresh == false) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return new CustomScrollView(
                    controller: postScrollController,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ct, index) {
                            if (index == viewModel.facebookPosts.length) {
                              if (viewModel.facebookPostPaging != null &&
                                  viewModel.facebookPostPaging.next != null) {
                                // load more
                                return StreamBuilder(
                                    stream: viewModel
                                        .isLoadingMoreFacebookPostStream,
                                    initialData:
                                        viewModel.isLoadingMoreFacebookPost,
                                    builder: (ctx, snapshot) {
                                      if (snapshot.data == true) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: FlatButton(
                                            color: Colors.indigo,
                                            textColor: Colors.white,
                                            shape: OutlineInputBorder(
                                              borderSide: BorderSide(width: 0),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              "Tải thêm...",
                                            ),
                                            onPressed: () {
                                              viewModel.loadFacebookPost();
                                            },
                                          ),
                                        );
                                      }
                                    });
                              } else {
                                return Text("");
                              }
                            } else {
                              return new Card(
                                margin: EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 8,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.only(left: 0),
                                    title: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Ngày
                                        new Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            children: <Widget>[
                                              if (viewModel
                                                  .facebookPosts[index].isVideo)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: Icon(
                                                    FontAwesomeIcons.video,
                                                    size: 17,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              if (viewModel
                                                  .facebookPosts[index].isLive)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Text(
                                                    "TRỰC TIẾP",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              Icon(
                                                Icons.date_range,
                                                color: Colors.blue.shade400,
                                              ),
                                              Expanded(
                                                child: new Text(
                                                  " ${DateFormat("dd/MM/yyyy HH:mm", "en_US").format(
                                                    viewModel
                                                        .facebookPosts[index]
                                                        .createdTime
                                                        .toLocal(),
                                                  )}",
                                                  style: TextStyle(
                                                      color:
                                                          Colors.blue.shade400),
                                                ),
                                              ),
                                              InkWell(
                                                child: Icon(
                                                  Icons.more_horiz,
                                                  color: Colors.grey,
                                                ),
                                                onTap: () {
                                                  _showModalBottomMenu(viewModel
                                                      .facebookPosts[index]);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        viewModel.facebookPosts[index]
                                                        .liveCampaignName !=
                                                    null &&
                                                viewModel.facebookPosts[index]
                                                    .liveCampaignName.isNotEmpty
                                            ? SizedBox(
                                                child: Card(
                                                  color: Colors.green,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: Text(
                                                      "Chiến dịch: ${viewModel.facebookPosts[index].liveCampaignName}",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                        new Text(
                                            "${trimComment(viewModel.facebookPosts[index].message)}"),
                                      ],
                                    ),
                                    leading: _showPostImage(
                                        facebookPost:
                                            viewModel.facebookPosts[index]),
                                    subtitle: new Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              timeAgo.format(
                                                  viewModel.facebookPosts[index]
                                                      .createdTime,
                                                  locale: "vi"),
                                            ),
                                          ),
                                          Icon(
                                            Icons.thumb_up,
                                            color: Colors.blue.shade400,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              " ${viewModel.facebookPosts[index].toltalLike}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Icon(Icons.comment),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              "${viewModel.facebookPosts[index].totalComment}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: viewModel
                                                              .facebookPosts[
                                                                  index]
                                                              .isSave ==
                                                          true
                                                      ? Colors.black87
                                                      : Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) {
                                            return NewFacebookPostCommentPage(
                                              crmTeam: widget.crmTeam,
                                              facebookPost: viewModel
                                                  .facebookPosts[index],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: ctx,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            content: Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              height: 100,
                                              width: 100,
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: <Widget>[
                                                  ListTile(
                                                    title:
                                                        Text("Đi tới bài viết"),
                                                    onTap: () async {
                                                      var url =
                                                          "https://facebook.com/${viewModel.facebookPosts[index].id}";
                                                      if (await canLaunch(
                                                          url)) {
                                                        await launch(url);
                                                      } else {
                                                        throw 'Could not launch Maps';
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          childCount:
                              (viewModel.facebookPosts?.length ?? 0) + 1 ?? 0,
                        ),
                      ),
                    ],
                  );
                });
          }
        },
      ),
    );
  }

  Widget _showPostImage({FacebookPost facebookPost}) {
    return SizedBox(
      height: 80,
      width: 80,
      child: new Stack(
        children: <Widget>[
          facebookPost.picture == null
              ? Image.asset(
                  "images/no_image.png",
                  height: 90,
                  width: 90,
                )
              : Image.network(
                  "${facebookPost.picture}",
                  fit: BoxFit.cover,
                  height: 90,
                  width: 90,
                ),
          Center(child: _showPostImageType(facebookPost.type)),
        ],
      ),
    );
  }

  Widget _showPostImageType(String type) {
    switch (type) {
      case "video":
        return Image.asset(
          "images/facebook_play.png",
          height: 50,
          width: 50,
        );
        break;
      case "link":
        return SizedBox();
        break;
      case "photo":
        return SizedBox();
        break;
    }

    return SizedBox();
  }

  void _showModalBottomMenu(FacebookPost post) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return BottomSheet(
            shape: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            builder: (context) => ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
//                ListTile(
//                  leading: Icon(Icons.open_in_new),
//                  title: Text("Mở trên facebook"),
//                  onTap: () async {
//                    Navigator.pop(context);
//                    // Goto facebook
//
//                    //333347943781959_827106614338372
//                    var url = "fb://feed";
//                    print(url);
//                    if (await canLaunch(url)) {
//                      await launch(url);
//                    } else {
//                      print("cannot");
//                    }
//                  },
                // ),
                dividerMin,
                ListTile(
                  leading: Icon(Icons.open_in_browser),
                  title: Text("Mở trên trình duyệt"),
                  onTap: () async {
                    var url = "https://facebook.com/${post.id}";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch Maps';
                    }
                  },
                ),
                dividerMin,
                ListTile(
                  leading: Icon(
                    Icons.save,
                    color: Colors.blue,
                  ),
                  title: Text("Lưu bình luận"),
                  onTap: () async {
                    Navigator.pop(context);
                    viewModel.saveComment(post);
                  },
                ),
                ListTile(),
              ],
            ),
            onClosing: () {},
          );
        });
  }

//  Widget _showLongPressMenu() {
//    return new AlertDialog(
//      content: Column(),
//    );
//  }
}
