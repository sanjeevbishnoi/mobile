import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/services/app_setting_service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_login_viewmodel.dart';
import 'package:tpos_mobile/themes.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

class NewLoginPage extends StatefulWidget {
  @override
  _NewLoginPageState createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  var _settingService = locator<ISettingService>();
  var _viewModel = locator<NewLoginViewModel>();

  final FocusNode _shopUrlFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final shopUrlTextController = new TextEditingController();
  final userInputTextController = new TextEditingController();
  final passwordInputTextController = new TextEditingController();

  final _panelWidthPaddingRate = 10;
  bool _showPassword = false;

  final _boxDecorate = BoxDecoration(
    border: Border.all(
      color: Colors.grey.withOpacity(0.5),
      width: 1.0,
    ),
    borderRadius: BorderRadius.circular(25.0),
  );

  final _inputTextStyle = TextStyle(fontSize: 16);

  @override
  void initState() {
    super.initState();
    _viewModel.initCommand();
    shopUrlTextController.text =
        (_settingService.shopUrl ?? "").replaceAll("https://", "");
    userInputTextController.text = _settingService.shopUsername;

    _viewModel.loginStateObservable.listen(
      (state) {
        if (state.isCompleted) {
          Navigator.pushReplacementNamed(
              context, AppRoute.home_navigation_page);
        }
        if (state.isError) {
          showGeneralDialog(
              barrierColor: Colors.grey.withOpacity(0.7),
              barrierDismissible: true,
              barrierLabel: "show",
              transitionDuration: Duration(milliseconds: 500),
              context: context,
              pageBuilder: (context, _, __ss) {
                return AlertDialog(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    "Sự cố đăng nhập",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: Text(state.message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("ĐỒNG Ý"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ViewBaseWidget(
      isBusyStream: _viewModel.isBusyController,
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        body: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return _showLoginPanel();
  }

  Widget _showLoginPanel() {
    final _media = MediaQuery.of(context);
    final _padding = _media.size.width * 10 / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Center(
            child: new ListView(
              shrinkWrap: false,
              padding: EdgeInsets.only(
                  left: _padding, right: _padding, top: 5, bottom: 5),
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                _showLogo(),
                _showHostInput(),
                _showUserInput(),
                _showPasswordInput(),
                _showPrimaryButton(),

                //Đăng ký
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, right: 8, bottom: 8, left: 8),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "CHƯA CÓ TẢI KHOẢN? ĐĂNG KÝ NGAY",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pushNamed(context, AppRoute.register_page);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Hotline: 090.807.5455",
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget _showLogo() {
    return Container(
      padding: EdgeInsets.only(top: 80, bottom: 10, left: 50, right: 50),
      child: Image.asset("images/tpos_logo_512.png"),
    );
  }

  Widget _showHostInput() {
    return Container(
      decoration: _boxDecorate,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      child: Row(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              Icons.language,
              color: Colors.grey,
            ),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          new Expanded(
            child: TextFormField(
              controller: shopUrlTextController,
              maxLines: 1,
              keyboardType: TextInputType.url,
              keyboardAppearance: Brightness.dark,
              textInputAction: TextInputAction.next,
              autofocus: false,
              focusNode: _shopUrlFocus,
              style: _inputTextStyle,
              onFieldSubmitted: (tern) {
                _shopUrlFocus.unfocus();
                FocusScope.of(context).requestFocus(_usernameFocus);
              },
              decoration: new InputDecoration(
                border: InputBorder.none,
                prefixText: "https://",
                hintText: 'tenshop.tpos.vn',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _showUserInput() {
    return Container(
      decoration: _boxDecorate,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      child: Row(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey,
            ),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          Expanded(
            child: new TextFormField(
              controller: userInputTextController,
              maxLines: 1,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              autofocus: false,
              focusNode: _usernameFocus,
              style: _inputTextStyle,
              onFieldSubmitted: (tern) {
                _usernameFocus.unfocus();
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
              decoration: new InputDecoration(
                hintText: 'Tên đăng nhập',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showPasswordInput() {
    return Container(
      decoration: _boxDecorate,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      child: Row(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              Icons.lock_open,
              color: Colors.grey,
            ),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          Expanded(
            child: new TextFormField(
              controller: passwordInputTextController,
              maxLines: 1,
              obscureText: !_showPassword,
              autofocus: false,
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.done,
              style: _inputTextStyle,
              decoration: new InputDecoration(
                hintText: 'Mật khẩu',
                border: InputBorder.none,
              ),
              onEditingComplete: () {
                _viewModel.loginCommandAdd(
                  new LoginCommand(
                    shopUrl: "https://${shopUrlTextController.text.trim()}",
                    username: userInputTextController.text.trim(),
                    password: passwordInputTextController.text.trim(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              child: Icon(
                Icons.remove_red_eye,
                color: _showPassword ? Colors.green : Colors.grey.shade500,
              ),
              onTap: () {
                setState(() {
                  this._showPassword = !this._showPassword;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Container(
        height: 45,
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary1Color,
              AppTheme.primary2Color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 3,
              color: AppTheme.primary1Color,
            ),
          ],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Material(
          color: Colors.transparent,
          child: new InkWell(
            splashColor: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              _viewModel.loginCommandAdd(
                new LoginCommand(
                  shopUrl: "https://${shopUrlTextController.text.trim()}",
                  username: userInputTextController.text.trim(),
                  password: passwordInputTextController.text.trim(),
                ),
              );

              MainApp.observer.analytics.logLogin(loginMethod: "appLogin");
            },
            child: Center(
              child: Text(
                "ĐĂNG NHẬP",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginBackgroundPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
//    final height = size.height;
//    final width = size.width;
//    Paint paint = Paint();
    //Color backgroundColor = Color.fromRGBO(78, 143, 73, 1);
//    /Color backgroundColor = Colors.green.shade50.withOpacity(0.5);

//    Path mainBackground = Path();
//    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
//    paint.color = backgroundColor;
//    canvas.drawPath(mainBackground, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(50.0, 10.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
