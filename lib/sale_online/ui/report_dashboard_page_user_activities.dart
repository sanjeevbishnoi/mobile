import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/data_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/widget_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/user_activities.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class UserActivitiesPage extends StatefulWidget {
  @override
  _UserActivitiesPageState createState() => _UserActivitiesPageState();
}

class _UserActivitiesPageState extends State<UserActivitiesPage> {
  UserActivities userActivities;
  int skip = 0;
  TposApiService tposApiService = locator<ITposApiService>();
  bool isLoading = true;
  bool isShowGoToTop = false;
  bool isSearch = false;
  bool isLoadInitFail = false;

  List<ActivityItem> activityItemsForDisplay = new List<ActivityItem>();
  List<ActivityItem> activityItemsData = new List<ActivityItem>();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _searchController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    myInit();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  Future myInit() async {
    setState(() {
      isLoading = true;
      isLoadInitFail = false;
    });
    try {
      var values = await tposApiService.getUserActivities(skip: skip);
      this.userActivities = values;
      activityItemsForDisplay = [...values.items];
      activityItemsData = [...values.items];
      isLoading = false;
      skip = skip + activityItemsForDisplay.length;
      setState(() {});
    } catch (e) {
      isLoading = false;
      isLoadInitFail = true;
      showCusSnackBar(
          currentState: _scaffoldKey.currentState,
          child: Text("${convertErrorToString(e)}"));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: isShowGoToTop
          ? null
          : FloatingActionButton(
              backgroundColor: Color(0xff3C763D),
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuart,
                );
              },
              child: Icon(
                Icons.keyboard_arrow_up,
              ),
            ),
    );
  }

  void _scrollListener() {
    //nếu kéo xuống cuối màn hình
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !isSearch) {
      //call api hoạt động user
      loadMoreData();
      //kéo xuống cuối màn hình sẽ tự nhích lên 10 (tránh lỗi liên tục load khi ở cuối màn hình)
      _scrollController.animateTo(_scrollController.offset - 10,
          duration: Duration(seconds: 1), curve: Curves.ease);
    }

    if (_scrollController.offset < 100 && !isShowGoToTop) {
      setState(() {
        isShowGoToTop = true;
      });
    }
    if (_scrollController.offset > 100 && isShowGoToTop) {
      setState(() {
        isShowGoToTop = false;
      });
    }

    ///reach the top
    /*if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {}*/
  }

  Future loadMoreData() async {
    try {
      var values = await tposApiService.getUserActivities(skip: skip);
      setState(() {
        activityItemsData.addAll(values.items);
        activityItemsForDisplay = [...activityItemsData];
        skip = skip + values.items.length;
        this.userActivities.items = activityItemsForDisplay;
      });
      showCusSnackBar(
          currentState: _scaffoldKey.currentState,
          child: Text(values.items.length == 0
              ? "Đã hết dữ liệu"
              : "Đã tải thêm ${values.items.length} hoạt động"));
    } catch (e) {
      showCusSnackBar(
        currentState: _scaffoldKey.currentState,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(convertErrorToString(e)),
            RaisedButton(
              child: Text("Thử lại"),
              onPressed: () {
                loadMoreData();
              },
            )
          ],
        ),
      );
    }
  }

  Widget _buildBody() {
    return isLoading
        ? loadingScreen(text: "Đang tải dữ liệu hoạt động")
        : Scrollbar(
            child: isLoadInitFail
                ? Container(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.boxOpen,
                            color: Colors.grey,
                            size: 30,
                          ),
                          Text(
                            "Tải dữ liệu thất bại",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                          ),
                          RaisedButton(
                            onPressed: () {
                              myInit();
                            },
                            child: Text(
                              "Thử lại",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    controller: _scrollController,
                    itemCount: activityItemsForDisplay.length,
                    itemBuilder: (context, index) {
                      ActivityItem item = activityItemsForDisplay[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Container(
                                    color: Color(0xff23B7E5),
                                    width: 1,
                                    height: 66,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage(
                                        "images/avatar_50x.png",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          item.user?.name ?? "N/A",
                                          style: TextStyle(
                                              color: Color(0xff3C763D),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            convertTime(item.dateCreated),
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    convertUserActivityHtml(item.content,
                                        objectName: item.objectName),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
          );
  }

  Widget convertUserActivityHtml(String text, {String objectName = ""}) {
    List<String> list = new List<String>();
    text.split(RegExp(r"<span+(.*'>)|<a+(.*'>)")).forEach((text) {
      list.add(text
          .replaceAll(
              RegExp(
                  r"<\/span>(.*>)|<\/a>(.*>)|<span+(.*'>)|<span+(.*'>)|<a+(.*'>)"),
              "")
          .replaceAll("\</span>", ""));
    });

    int count = 0;

    List<TextSpan> listTextSpan = list.map(
      (f) {
        Color textColor = Colors.black;
        bool isBold = false;
        if (list[count].toLowerCase().contains("xóa") && count == 1) {
          textColor = Color(0xffA94442);
          isBold = true;
        } else if (count == 1) {
          textColor = Color(0xff31708F);
          isBold = true;
        }

        count++;
        return TextSpan(
          text: f,
          style: TextStyle(
            color: textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        );
      },
    ).toList();

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "$objectName: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...listTextSpan
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return isSearch
        ? AppBar(
            title: Container(
              color: Colors.white,
              child: TextField(
                autofocus: true,
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) {
                  setState(() {
                    activityItemsForDisplay = activityItemsData.where((f) {
                      String content = removeDiacritics((f.content +
                              f.objectName)
                          .replaceAll(
                              RegExp(
                                  r"<\/span>(.*>)|<\/a>(.*>)|<span+(.*'>)|<span+(.*'>)|<a+(.*'>)"),
                              "")
                          .replaceAll(r"<\/span>", "")
                          .toLowerCase());
                      return content
                          .contains(removeDiacritics(text.toLowerCase()));
                    }).toList();
                    print(activityItemsForDisplay.length);
                  });
                },
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    isSearch = false;
                    activityItemsForDisplay = activityItemsData;
                    _scrollController.animateTo(0,
                        duration: Duration(seconds: 1), curve: Curves.ease);
                  });
                },
              )
            ],
          )
        : AppBar(
            backgroundColor: Color(0xff3C763D),
            title: Text("Lịch sử hoạt động"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    isSearch = true;
                  });
                },
              )
            ],
          );
  }
}
