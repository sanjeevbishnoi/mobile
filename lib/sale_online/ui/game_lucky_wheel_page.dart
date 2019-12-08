import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:screen/screen.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/sale_online/models/FacebookWinner.dart';
import 'package:tpos_mobile/sale_online/ui/facebook_post_share_list_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_facebook_post_comment_viewmodel.dart';

import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

import 'package:tpos_mobile/sale_online/viewmodels/game_lucky_wheel_viewmodel.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'game_lucky_wheel_help_page.dart';
import 'game_lucky_wheel_setting_page.dart';
import 'package:animated_background/animated_background.dart';

class GameLuckyWheelPage extends StatefulWidget {
  final uId;
  final postId;
  final NewFacebookPostCommentViewModel commentVm;
  GameLuckyWheelPage({
    this.uId,
    this.postId,
    this.commentVm,
  });

  @override
  _GameLuckyWheelPageState createState() => _GameLuckyWheelPageState();
}

class _GameLuckyWheelPageState extends State<GameLuckyWheelPage>
    with TickerProviderStateMixin {
  double transform = 0;
  _GameLuckyWheelPageState();

  LuckyWheelViewModel viewModel = new LuckyWheelViewModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _controller = new ScrollController();
  bool isReady = false;

  double deviceHeightContainer;
  double deviceWidthContainer;
  double fontSize;
  bool isClose = true;
  bool _isReFetchData = false;

  // Particles
  ParticleOptions particleOptions = ParticleOptions(
    image: Image.asset('images/star_stroke.png'),
    baseColor: Colors.blue,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.5,
    maxOpacity: 1.0,
    spawnMinSpeed: 30.0,
    spawnMaxSpeed: 70.0,
    spawnMinRadius: 7.0,
    spawnMaxRadius: 15.0,
    particleCount: 40,
  );

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  /// Chuẩn bị chơi
  Future<void> _goToElementPrepare() async {
    if (viewModel.players == null || viewModel.players.length == 0) return;
    if (viewModel.isPrepaing || viewModel.isPlaying) return;
    if (mounted)
      setState(() {
        viewModel.isPrepaing = true;
      });
    try {
      double offset = (deviceHeightContainer / 5) *
          viewModel.players.indexOf(viewModel.players.last).toDouble();

      await _controller.animateTo(
        offset,
        duration: const Duration(milliseconds: 5000),
        curve: Curves.easeOut,
      );
    } catch (e) {
      viewModel.isPrepaing = false;
    }

    if (mounted)
      setState(() {
        viewModel.isPrepaing = false;
      });
  }

  /// Chơi luôn
  Future<int> _goToElement() async {
    if (viewModel.players == null || viewModel.players.length == 0) {
      locator<DialogService>().showError(content: "Không có người chơi nào");
      return 0;
    }
    if (mounted)
      setState(() {
        viewModel.isPlaying = true;
      });

    viewModel.startGame();

    double offset =
        -50005 + (deviceHeightContainer / 5) * viewModel.winPlayerIndex;
    double step = 10;
    int mili = 1;
    int offsetleft = 10;
    for (int i = 0; i < 1000000000; i++) {
      _controller.jumpTo(offset);
      await Future.delayed(Duration(milliseconds: mili));
      offset += step;
      offsetleft -= 1;

      // if (step > 0 && offsetleft == 0) {
      step -= 0.001;
      offsetleft = 10;
      // }

      if (step < 0) {
        break;
      }
    }

    int index = (offset / ((deviceHeightContainer) / 5)).round();

    if (mounted)
      setState(() {
        viewModel.isPlaying = false;
      });

    await Navigator.push(
      context,
      HeroDialogRoute(builder: (BuildContext context) {
        return _buildPopUp(context, index);
      }),
    );
    return index;
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    deviceWidthContainer = deviceWidth * 0.9;
    deviceHeightContainer = deviceHeight * 0.8;
    fontSize = deviceWidth / 414.0;

    return ScopedModel<LuckyWheelViewModel>(
      model: viewModel,
      child: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Scaffold(
          key: _scaffoldKey,
          body: Transform(
            transform: Matrix4.rotationY(transform),
            alignment: Alignment.center,
            child: UIViewModelBaseGame(
              viewModel: viewModel,
              child: ScopedModelDescendant<LuckyWheelViewModel>(
                builder: (context, child, model) => Container(
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Color(0xFF5600E8), Color(0xFF3ADDFF)],
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: AnimatedBackground(
                    behaviour: RandomParticleBehaviour(
                      options: particleOptions,
                      paint: particlePaint,
                    ),
                    vsync: this,
                    child: Column(
                      children: <Widget>[
                        _buildGradientAppBar(),
                        Center(
                          child: Container(
                            height: deviceHeightContainer,
                            width: deviceWidthContainer,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: deviceHeightContainer * 0.3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        " 🌟 ",
                                        style: TextStyle(
                                          fontSize: (30.0 * fontSize),
                                          shadows: <BoxShadow>[
                                            new BoxShadow(
                                              color: new Color(0xFF064BC2),
                                              blurRadius: 10.0,
                                              offset: new Offset(0.0, 10.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '🎁\nVÒNG XOAY\nMAY MẮN',
                                        style: TextStyle(
                                          fontFamily: 'UVNVan_B',
                                          fontSize: (30.0 * fontSize),
                                          color: Colors.white,
                                          shadows: <BoxShadow>[
                                            new BoxShadow(
                                              color: new Color(0xFF064BC2),
                                              blurRadius: 10.0,
                                              offset: new Offset(0.0, 10.0),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        " 🌟 ",
                                        style: TextStyle(
                                          fontSize: (30 * fontSize),
                                          shadows: <BoxShadow>[
                                            new BoxShadow(
                                              color: new Color(0xFF064BC2),
                                              blurRadius: 10.0,
                                              offset: new Offset(0.0, 10.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: InkWell(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.people, color: Colors.white),
                                        Text(
                                          "${viewModel.players?.length} ",
                                          style: TextStyle(
                                            fontSize: (20 * fontSize),
                                            color: Colors.white,
                                            shadows: <BoxShadow>[
                                              new BoxShadow(
                                                color: new Color(0xFF064BC2),
                                                blurRadius: 10.0,
                                                offset: new Offset(0.0, 10.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.share, color: Colors.white),
                                        Text(
                                          "${viewModel.playerShareCount} ",
                                          style: TextStyle(
                                            fontSize: (20 * fontSize),
                                            color: Colors.white,
                                            shadows: <BoxShadow>[
                                              new BoxShadow(
                                                color: new Color(0xFF064BC2),
                                                blurRadius: 10.0,
                                                offset: new Offset(0.0, 10.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.comment,
                                            color: Colors.white),
                                        Text(
                                          "${viewModel.playerCommentCount} ",
                                          style: TextStyle(
                                            fontSize: (20 * fontSize),
                                            color: Colors.white,
                                            shadows: <BoxShadow>[
                                              new BoxShadow(
                                                color: new Color(0xFF064BC2),
                                                blurRadius: 10.0,
                                                offset: new Offset(0.0, 10.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.refresh,
                                            color: Colors.white),
                                      ],
                                    ),
                                    onTap: () {
                                      viewModel.initCommand();
                                    },
                                  ),
                                ),
                                // List
                                Expanded(
                                  child: ScopedModelDescendant<
                                      LuckyWheelViewModel>(
                                    builder: (context, child, model) => Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: deviceWidthContainer * 0.9,
                                          decoration: new BoxDecoration(
                                            color: new Color(0xFFFFFFFF),
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                            boxShadow: <BoxShadow>[
                                              new BoxShadow(
                                                color: new Color(0xFF064BC2),
                                                blurRadius: 10.0,
                                                offset: new Offset(0.0, 5.0),
                                              ),
                                              new BoxShadow(
                                                color: new Color(0xFF064BC2),
                                                blurRadius: 10.0,
                                                offset: new Offset(0.0, -5.0),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(3.0 * fontSize),
                                            child:
                                                ListWheelScrollView.useDelegate(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              diameterRatio: 100,
                                              controller: _controller,
                                              itemExtent:
                                                  deviceHeightContainer / 5,
                                              childDelegate:
                                                  ListWheelChildLoopingListDelegate(
                                                children: List<Widget>.generate(
                                                    viewModel.players?.length ??
                                                        0, (index) {
                                                  return _buildItem(index);
                                                }),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: Image.asset(
                                            "images/arrow.png",
                                            width: 50 * fontSize,
                                            height: 50 * fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: deviceHeightContainer * 0.1,
                                  width: deviceWidthContainer * 0.9,
                                  margin: EdgeInsets.only(top: 30.0),
                                  decoration: BoxDecoration(boxShadow: [
                                    new BoxShadow(
                                      color: new Color(0xFF064BC2),
                                      blurRadius: 10.0,
                                      offset: new Offset(0.0, 10.0),
                                    ),
                                  ]),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: RaisedButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0)),
                                          padding: EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 15,
                                              bottom: 15),
                                          color: Colors.green,
                                          child: Text(
                                            "Hướng dẫn",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16 * fontSize),
                                          ),
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                builder: (ctx) =>
                                                    new GameLuckyWheelHelpPage(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      new SizedBox(
                                        width: 10 * fontSize,
                                      ),
                                      new Expanded(
                                        flex: 1,
                                        child: RaisedButton(
                                          padding: EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 15,
                                              bottom: 15),
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0)),
                                          child: Text(
                                            "Quay",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16 * fontSize),
                                          ),
                                          color: Color(0xFFFE5250),
                                          onPressed: viewModel.isPlaying ||
                                                  viewModel.isPrepaing
                                              ? null
                                              : () async {
                                                  try {
                                                    await _goToElement();
                                                  } catch (e, s) {}
                                                },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    return Padding(
      padding: EdgeInsets.only(top: 3.0 * fontSize),
      child: Container(
        decoration: new BoxDecoration(
          color: Color(0xFFFF28A7),
          gradient: new LinearGradient(
              colors: [Color(0xFFFF28A7), Color(0xFFFE5250)],
              begin: Alignment.bottomRight,
              end: new Alignment(-1.0, -1.0)),
          borderRadius: new BorderRadius.circular(3.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: "hero_${viewModel.players[index].uId}",
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.white,
                  )),
                  width: deviceHeightContainer / 6.25,
                  margin: EdgeInsets.only(right: 10),
                  child: new FadeInImage(
                    placeholder: new AssetImage("images/game_avatar.jfif"),
                    image: new CachedNetworkImageProvider(
                      "http://graph.facebook.com/${viewModel.players[index]?.id}/picture?width=${(deviceHeightContainer / 6.25).round()}",
                    ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    fadeInDuration: new Duration(milliseconds: 200),
                    fadeInCurve: Curves.linear,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(viewModel.players[index].name,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22 * fontSize,
                          )),
                      Row(
                        children: <Widget>[
                          Icon(Icons.share, color: Colors.white),
                          Text(
                            "${viewModel.players[index].countShare ?? "0"}  ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20 * fontSize,
                              color: Colors.white,
                            ),
                          ),
                          Icon(Icons.comment, color: Colors.white),
                          Text(
                            " ${viewModel.players[index].countComment ?? "0"}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20 * fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildPopUp(BuildContext context, int index) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    fontSize = deviceWidth / 414.0;
    return Center(
      child: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: particleOptions.copyWith(
              image: Image.asset('images/ballon.png'),
              spawnMaxRadius: 50,
              particleCount: 20),
          paint: particlePaint,
        ),
        vsync: this,
        child: AlertDialog(
          content: Transform(
            transform: Matrix4.rotationY(transform),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "⭐ Xin chúc mừng! ⭐",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18 * fontSize, color: Colors.red),
                      ),
                      Text(
                        "${viewModel.players[index].name}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24 * fontSize, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Hero(
                  tag: "hero_${viewModel.players[index].uId}",
                  child: Container(
                    width: deviceHeightContainer / 2,
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.white,
                    )),
                    child: FadeInImage(
                      placeholder: new AssetImage(
                          "images/game_luckywheel_avatar_white.jpg"),
                      image: NetworkImage(
                          "http://graph.facebook.com/${viewModel.players[index]?.id}/picture?height=${(deviceHeightContainer / 2).round()}&width=${(deviceHeightContainer / 2).round()}"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          padding: EdgeInsets.all(5 * fontSize),
                          color: Colors.green,
                          child: Text(
                            "Lưu & In",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16 * fontSize),
                          ),
                          onPressed: () async {
                            await viewModel.updateFacebookWinner();
                          },
                        ),
                      ),
                      new SizedBox(
                        width: 10,
                      ),
                      new Expanded(
                        flex: 1,
                        child: RaisedButton(
                          padding: EdgeInsets.all(5 * fontSize),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          child: Text(
                            "Đóng",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16 * fontSize),
                          ),
                          color: Color(0xFFFE5250),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future showDialogFacebookWinner() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return StreamBuilder<List<FacebookWinner>>(
              initialData: viewModel.facebookWinners.reversed.toList(),
              stream: viewModel.facebookWinnersStream,
              builder: (context, AsyncSnapshot<List<FacebookWinner>> snapshot) {
                return AlertDialog(
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.all(0),
                  title: Text("Danh sách người trúng"),
                  content: Container(
                    width: 1000,
                    padding: EdgeInsets.only(top: 10),
                    child: Scrollbar(
                      child: ListView.separated(
                          shrinkWrap: false,
                          itemCount: snapshot.data?.length ?? 0,
                          separatorBuilder: (ctx, index) {
                            return Divider();
                          },
                          itemBuilder: (ctx, index) {
                            return ListTile(
                              contentPadding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                              ),
                              leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text("${index + 1}."),
                                    FadeInImage(
                                      width: deviceHeightContainer / 7.25,
                                      placeholder:
                                          new AssetImage("images/no_image.png"),
                                      image: new CachedNetworkImageProvider(
                                          "http://graph.facebook.com/${snapshot.data[index].facebookUId}/picture?width=${(deviceHeightContainer / 7.25).round()}",
                                          errorListener: () {
                                        print("load image fail");
                                      }),
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      fadeInDuration:
                                          new Duration(milliseconds: 200),
                                      fadeInCurve: Curves.linear,
                                    ),
                                  ]),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${snapshot.data[index].facebookName}",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        itemBuilder: (context) => [
                                          PopupMenuItem<String>(
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(Icons.message),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      "Gửi tin nhắn Messenger"),
                                                ),
                                              ],
                                            ),
                                            value: "messenger",
                                          ),
                                          PopupMenuItem<String>(
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(Icons.message),
                                                ),
                                                Expanded(
                                                  child: Text("In phiếu"),
                                                ),
                                              ],
                                            ),
                                            value: "print",
                                          ),
                                        ],
                                        onSelected: (value) {
                                          switch (value) {
                                            case "messenger":
                                              urlLauch(
                                                "fb://messaging/${snapshot.data[index].facebookUId}",
                                              );
                                              break;
                                            case "print":
                                              viewModel.printWin(
                                                  snapshot
                                                      .data[index].facebookName,
                                                  snapshot
                                                      .data[index].facebookUId);
                                              break;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${DateFormat("dd/MM/yyyy  HH:mm", "en_US").format(
                                      snapshot.data[index].dateCreated
                                          .toLocal(),
                                    )}",
                                    style: TextStyle(
                                        color: Colors.indigo.shade400),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("ĐÓNG"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        });
  }

  @override
  initState() {
    viewModel.init(
        postId: widget.postId,
        facebookUid: widget.postId,
        crmTeam: widget.commentVm?.crmTeam);
    viewModel.initCommand().then((value) {
      _showUpdateNotify();
    });
    // Chỉ màn hình dọc
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Lắng nghe sự kiện từ vm
    viewModel.eventController.listen((event) {
      if (event.eventName == LuckyWheelViewModel.REFRESH_PLAYER_EVENT) {
        // gọi chuẩn bị chơi game

        _goToElementPrepare();
      }
    });

    super.initState();
  }

  void _showUpdateNotify() async {
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.all(0),
        content: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 40),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Color(0xFF5600E8), Color(0xFF3ADDFF)],
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Nếu trước đó bạn chưa từng lưu bình luận và thống kê lượt share thì bây giờ hãy làm điều đó để đảm bảo dữ liệu được đầy đủ nhất",
                style: TextStyle(color: Colors.white, fontSize: 16 * fontSize),
              ),
              Text(
                "Quá trình này sẽ mất một chút ít thời gian",
                style: TextStyle(color: Colors.orange, fontSize: 16 * fontSize),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Expanded(
                      flex: 1,
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0)),
                        padding: EdgeInsets.all(5 * fontSize),
                        color: Colors.green,
                        child: Text(
                          "Lưu\nbình luận",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontSize: 16 * fontSize),
                        ),
                        onPressed: () async {
                          await widget.commentVm?.saveComment();
                          _isReFetchData = true;
                        },
                      ),
                    ),
                    new SizedBox(
                      width: 10,
                    ),
                    new Expanded(
                      flex: 1,
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0)),
                        padding: EdgeInsets.all(5 * fontSize),
                        color: Colors.green,
                        child: Text(
                          "Cập nhật\nshare",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontSize: 16 * fontSize),
                        ),
                        onPressed: () async {
                          _isReFetchData = true;
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return FacebookPostShareListPage(
                              pageId: widget.commentVm.crmTeam.userUidOrPageId,
                              postId: widget.postId,
                              autoClose: true,
                            );
                          }));
                        },
                      ),
                    ),
                    new SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        padding: EdgeInsets.all(5 * fontSize),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0)),
                        child: Text(
                          "Tiếp tục \n :)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontSize: 16 * fontSize),
                        ),
                        color: Color(0xFFFE5250),
                        onPressed: () async {
                          // Tải lại danh sách và tiếp tục

                          if (_isReFetchData) {
                            await viewModel.initCommand();
                            Future.delayed(Duration(seconds: 1));
                          }

                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GameLuckyWheelSettingPage()));

                          viewModel.refreshPlayer();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    new SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildGradientAppBar() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    fontSize = deviceWidth / 414.0;
    return new Container(
      margin: new EdgeInsets.only(left: 10.0),
      padding: new EdgeInsets.only(top: statusBarHeight),
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new IconButton(
              iconSize: 24 * fontSize,
              color: Colors.white,
              icon: Icon(Icons.close),
              onPressed: () {
                if (viewModel.isPlaying) return;

                Navigator.pop(context);
              },
            ),
            IconButton(
              iconSize: 24 * fontSize,
              color: Colors.white,
              onPressed: () {
                setState(() {
                  if (transform == pi) {
                    transform = 0;
                  } else {
                    transform = pi;
                  }
                });
              },
              icon: Icon(
                Icons.screen_rotation,
              ),
            ),
            IconButton(
              iconSize: 24 * fontSize,
              color: Colors.white,
              onPressed: () async {
                showDialogFacebookWinner();
              },
              icon: Icon(
                Icons.list,
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  iconSize: 24 * fontSize,
                  color: Colors.white,
                  onPressed: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return GameLuckyWheelSettingPage();
                    }));

                    viewModel.refreshPlayer();
                  },
                  icon: Icon(
                    Icons.settings,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ParticleType {
  Shape,
  Image,
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  String get barrierLabel => null;
}

class UIViewModelBaseGame extends StatelessWidget {
  final ViewModel viewModel;
  final Widget child;
  final Widget Function(BuildContext) errorBuilder;
  final Widget Function(BuildContext) indicatorBuilder;
  final Color defaultIndicatorColor;
  final Color defaultIndicatorBackgroundColor;
  final Color backgroundColor;
  UIViewModelBaseGame(
      {@required this.viewModel,
      @required this.child,
      this.errorBuilder,
      this.indicatorBuilder,
      this.defaultIndicatorColor,
      this.defaultIndicatorBackgroundColor,
      this.backgroundColor});

  Widget _buildDefaultIndicator({String message, BuildContext context}) {
    return Material(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Color(0xFF5600E8), Color(0xFF3ADDFF)],
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                message ?? "",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: defaultIndicatorBackgroundColor ?? Colors.grey.shade300,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Có gì đó không đúng rồi"),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Về trang trước"),
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    child: Text("Thử lại"),
                    onPressed: () {},
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        StreamBuilder<ViewModelState>(
          stream: viewModel.stateController,
          initialData: ViewModelState(isBusy: true, message: "Đang tải..."),
          builder: (context, snapshot) {
            if (snapshot.data.isError) {
              return errorBuilder ?? _buildDefaultError();
            }

            if (snapshot.data.isBusy) {
              return indicatorBuilder ??
                  _buildDefaultIndicator(
                      message: snapshot.data.message, context: context);
            }
            return SizedBox();
          },
        ),
      ],
    );
  }
}
