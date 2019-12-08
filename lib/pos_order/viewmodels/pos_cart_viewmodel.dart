import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';
import 'package:tpos_mobile/pos_order/models/cart_product.dart';
import 'package:tpos_mobile/pos_order/models/company.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/pos_order/models/price_list.dart';
import 'package:tpos_mobile/pos_order/models/promotion.dart';
import 'package:tpos_mobile/pos_order/models/state_cart.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_helper.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'dart:io';

class PosCartViewModel extends ViewModelBase {
  DialogService _dialog;
  IPosTposApi _tposApi;
  IDatabaseFunction _dbFuction;
  PosCartViewModel({IPosTposApi tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<IPosTposApi>();
    _dialog = dialogService ?? locator<DialogService>();
    _dbFuction = dialogService ?? locator<IDatabaseFunction>();
  }
  final dbHelper = DatabaseHelper.instance;

  Partners _partner = Partners();

  List<StateCart> childCarts = [];
  List<Lines> _lstLine = [];
  List<Session> _sessions = [];
  List<CartProduct> _products = [];
  List<Partners> _partners = [];
  List<PriceList> _priceLists = [];
  List<AccountJournal> _accountJournals = [];
  List<Companies> _companies = [];
  List<Payment> lstpayment = [];
  List<Promotion> _promotions = [];

  String _oldPosition = "0";
  int _countPayment = 0;
  String positionCart = "-1";

  int get countPayment => _countPayment;
  set countPayment(int value) {
    _countPayment = value;
    notifyListeners();
  }

  List<Lines> get lstLine => _lstLine;
  set lstLine(List<Lines> value) {
    _lstLine = value;
    notifyListeners();
  }

  List<Session> get sessions => _sessions;
  set sessions(List<Session> value) {
    _sessions = value;
    notifyListeners();
  }

  List<CartProduct> get products => _products;
  set products(List<CartProduct> value) {
    _products = value;
    notifyListeners();
  }

  List<Partners> get partners => _partners;
  set partners(List<Partners> value) {
    _partners = value;
    notifyListeners();
  }

  List<PriceList> get priceLists => _priceLists;
  set priceLists(List<PriceList> value) {
    _priceLists = value;
    notifyListeners();
  }

  Partners get partner => _partner;
  set partner(Partners value) {
    _partner = value;
    notifyListeners();
  }

  List<AccountJournal> get accountJournals => _accountJournals;
  set accountJournals(List<AccountJournal> value) {
    _accountJournals = value;
    notifyListeners();
  }

  List<Companies> get companies => _companies;
  set companies(List<Companies> value) {
    _companies = value;
    notifyListeners();
  }

  List<Promotion> get promotions => _promotions;
  set promotions(List<Promotion> value) {
    _promotions = value;
    notifyListeners();
  }

  Future<void> getSession() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getPosSession();
      if (result != null) {
        sessions = result;
        childCarts = await _dbFuction.queryAllRowsCart();
        if (childCarts.length == 0) {
          addCartBegin();
        } else {
          updateCartPosition();
        }

        /// Check Sessiom
        List<Session> _sessions = await _dbFuction.querySessions();
        if (_sessions.length == 0) {
          addSession();
        } else {
          updateSession();
        }
      }
    } on SocketException catch (e, s) {
      childCarts = await _dbFuction.queryAllRowsCart();
      sessions = await _dbFuction.querySessions();
      updateCartPosition();
    } catch (e, s) {
      logger.error("loadSession", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> getProducts() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getProducts();
      if (result != null) {
        products = result;
        List<CartProduct> _lstProduct = await _dbFuction.queryProductAllRows();
        if (_lstProduct.length == 0) {
          addProduct();
        }
      }
    } on SocketException catch (e, s) {
      products = await _dbFuction.queryProductAllRows();
    } catch (e, s) {
      logger.error("loadProductFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> getPartners() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getPartners();
      if (result != null) {
        partners = result;
        List<Partners> _lstPartner = await _dbFuction.queryGetPartners();
        if (_lstPartner.length == 0) {
          addPartner();
        }
      }
    } on SocketException catch (e, s) {
      partners = await _dbFuction.queryGetPartners();
    } catch (e, s) {
      logger.error("loadProductFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> getPriceLists() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getPriceLists();
      if (result != null) {
        priceLists = result;
        List<PriceList> _lstPrice = await _dbFuction.queryGetPriceLists();
        if (_lstPrice.length == 0) {
          addPriceList();
        }
      }
    } on SocketException catch (e, s) {
      priceLists = await _dbFuction.queryGetPriceLists();
    } catch (e, s) {
      logger.error("loadPriceListFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> getAccountJournal() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getAccountJournals();
      if (result != null) {
        accountJournals = result;
        List<AccountJournal> _lstAccountJournal =
            await _dbFuction.queryGetAccountJournals();
        if (_lstAccountJournal.length == 0) {
          addAccountJournal();
        }
      }
    } on SocketException catch (e, s) {
      accountJournals = await _dbFuction.queryGetAccountJournals();
    } catch (e, s) {
      logger.error("loadPriceListFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> getCompanies() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.getCompanys();
      if (result != null) {
        companies = result;
        List<Companies> _lstCompany = await _dbFuction.queryCompanys();
        if (_lstCompany.length == 0) {
          addCompany();
        }
      }
    } on SocketException catch (e, s) {
      companies = await _dbFuction.queryCompanys();
    } catch (e, s) {
      logger.error("loadCompanyFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  Future<void> copyProductCart(Lines line) async {
    int result = await _dbFuction.insertProductCart(line);
    getProductsForCart();
  }

  Future<void> countInvoicePayment() async {
    lstpayment = await _dbFuction.queryPayments();
    countPayment = lstpayment.length;
  }

  Future<void> handlePayment() async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.exePayment(lstpayment, false);
      if (result) {
        showNotifyPayment("Thực hiện thành công");
        await _dbFuction.deletePayments();
      } else {
        showNotifyPayment("Thục hiện thất bại");
      }
      setState(false);
    } on SocketException catch (e, s) {
//      payment.lines = null;
//      payment.statementIds = null;
//      var result = await _dbFuction.insertPayment(payment);
      setState(false);
    } catch (e, s) {
      logger.error("handlePaymentFail", e, s);
      _dialog.showError(error: e);
    }
  }

  Future<void> addCart(bool isLoadCarts) async {
    String dateCreateCart = convertDatetimeToString(DateTime.now());
    String newPosition =
        "${int.parse(childCarts[childCarts.length - 1].position) + 1}";

    // Cập nhật kiểm tra xem giỏ vừa mới xóa có phải là giỏ cuối hay ko
    if (int.parse(_oldPosition) >= int.parse(newPosition)) {
      newPosition = (int.parse(_oldPosition) + 1).toString();
    }
    positionCart = newPosition;
    var id = await _dbFuction.insertCart(StateCart(
        time: dateCreateCart,
        position: "$newPosition",
        check: 1,
        loginNumber: _sessions[0].loginNumber));

    // Chỉ load lại khi thực hiện thêm giỏ hàng mới bằng cách nhấn button
    if (isLoadCarts) {
      await getCarts();
    }

    // Cập nhật lại các giỏ hàng cũ sẽ ko check và giỏ hàng mới sẽ đc check
    List<StateCart> _updateCarts = [];
    _updateCarts = childCarts;
    for (var i = 0; i < _updateCarts.length; i++) {
      if (_updateCarts[i].position != newPosition) {
        _updateCarts[i].check = 0;
      }
      await _dbFuction.updateCart(_updateCarts[i]);
    }
    getProductsForCart();
    //  notifyListeners();
  }

  Future<int> deleteCart({StateCart cart, bool isDelete}) async {
    int result = 0;
    String postion;
    if (cart != null) {
      postion = cart.position;
    } else {
      postion = positionCart;
    }
    if (childCarts.length > 1) {
      // kiểm tra và cập nhật lại quyền cho giỏ khác
      String newPositionAfterDelete;
      for (var i = 0; i < childCarts.length; i++) {
        if (childCarts[i].position == postion) {
          childCarts[i].check = 0;
          if (i == childCarts.length - 1) {
            //isDelete = false;
            StateCart updateCart = StateCart();
            updateCart = childCarts[i - 1];
            updateCart.check = 1;
            await _dbFuction.updateCart(updateCart);
            newPositionAfterDelete = updateCart.position;
          } else {
            StateCart updateCart = StateCart();
            updateCart = childCarts[i + 1];
            updateCart.check = 1;
            await _dbFuction.updateCart(updateCart);
            newPositionAfterDelete = updateCart.position;
          }
        }
      }

      _oldPosition = postion;

      // kiểm tra có phải là thanh toán rồi xóa hay ko
      if (!isDelete) {
        await addCart(
            false); // true false để xác nhận có load lại dũ liệu ngay khi thêm vào hay ko
      }

      result = await _dbFuction.deleteCart(postion);

      if (isDelete) {
        positionCart =
            postion; // Cập nhật vị trí giỏ bị xóa để xóa tất cả các sản phẩm trong giỏ đó
        // Xóa tất cả sản phẩm trong giỏ đã bị xóa
        await getProductsForCart();
        for (var i = 0; i < lstLine.length; i++) {
          _dbFuction.deleteProductCart(lstLine[i]);
        }
        // Cập nhật lại vị trí giỏ mới và lấy sản phẩm cho giỏ mới
        positionCart = newPositionAfterDelete.toString();
        getProductsForCart();
      }
    } else {
      result = 1;
      await addCart(false);
      await _dbFuction.deleteCart(postion);
    }
    await getCarts(); // Lấy danh sách cart

    return result;
  }

  Future<void> updateProductCart(Lines line) async {
    var result = await _dbFuction.updateProductCart(line);
    if (result == 1) {
      getProductsForCart();
      showNotifyUpdateProduct("Cập nhật sản phẩm thành công ");
    } else {
      showNotifyUpdateProduct("Cập nhật sản phẩm thất bại ");
    }
  }

  Future<bool> deleteProductCart(Lines line) async {
    bool isResult = true;
    var result = await _dbFuction.deleteProductCart(line);
    if (result == 1) {
      isResult = true;
    } else {
      isResult = false;
    }
    return isResult;
  }

  Future<void> getPromotions() async {
    setState(true);
    try {
      var result = await _tposApi.getPromotions(promotions);
      if(result != null){
        promotions = result;
        // add promotion to Lines
        for(var i =0; i< promotions.length; i++){
            List<Lines> promotionLines = await _dbFuction.queryGetProductWithID(positionCart, promotions[i].productId);
            if(promotionLines.length == 0){
              if(promotions[i].productId != 0){
                Lines line = Lines();
                insertProductPromotion(promotions[i]);
              }
            }else if(promotionLines[0].isPromotion && promotionLines[0].promotionProgramId != promotions[i].promotionProgramId ){
              Lines line = Lines();
              line.discount = promotionLines[0].discount;
              line.discountType = "percent";
              line.note = promotionLines[0].note;
              line.priceUnit = promotionLines[0].priceUnit;
              line.productId = promotionLines[0].productId;
              line.qty = promotions[i].qty + promotionLines[0].qty;
              line.uomId = promotions[i-1].uOMId;
              line.isPromotion = promotionLines[0].isPromotion;
              line.promotionProgramId = promotionLines[0].promotionProgramId;
              line.tb_cart_position = positionCart;
              line.productName = promotionLines[0].productName;
              line.id = promotionLines[0].id;
              print(json.encode(line.toJson()));
              await _dbFuction.updateProductCart(line);
            }else if(promotionLines[0].isPromotion && promotionLines.length == 1 && promotionLines[0].promotionProgramId == promotions[i].promotionProgramId ){
                await _dbFuction.deleteProductCart(promotionLines[0]);
                insertProductPromotion(promotions[i]);
            }
        }
        getProductsForCart();
      }
    } on SocketException catch (e, s) {

    } catch (e, s) {
      logger.error("loadProductFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  void insertProductPromotion(Promotion promotion) async {
    Lines line = Lines();
    line.discount = promotion.discount;
    line.discountType = "percent";
    line.note = promotion.notice;
    line.priceUnit = promotion.priceUnit;
    line.productId = promotion.productId;
    line.qty = promotion.qty;
    line.uomId = promotion.uOMId;
    line.isPromotion = promotion.isPromotion;
    line.promotionProgramId = promotion.promotionProgramId;
    line.tb_cart_position = positionCart;
    line.productName = promotion.productNameGet;

    await _dbFuction.insertProductCart(line);
  }

  void handleCheckCart(int index) async {
    positionCart = childCarts[index].position;
    for (var i = 0; i < childCarts.length; i++) {
      if (i == index) {
        childCarts[i].check = 1;
      } else {
        childCarts[i].check = 0;
      }
      await _dbFuction.updateCart(childCarts[i]);
    }
    getProductsForCart();
    notifyListeners();
  }

  void addCartBegin() async {
    String dateCreateCart = convertDatetimeToString(DateTime.now());

    childCarts.add(StateCart(
        position: "${_sessions[0].sequenceNumber}",
        check: 1,
        time: dateCreateCart,
        loginNumber: _sessions[0].loginNumber));
    var id = await _dbFuction.insertCart(StateCart(
        position: "${_sessions[0].sequenceNumber}",
        check: 1,
        time: dateCreateCart,
        loginNumber: _sessions[0].loginNumber));
    positionCart = "${_sessions[0].sequenceNumber}";
  }

  void addProduct() async {
    for (var i = 0; i < _products.length; i++) {
      await _dbFuction.insertProduct(_products[i]);
    }
  }

  void addPartner() async {
    for (var i = 0; i < partners.length; i++) {
      await _dbFuction.insertPartner(partners[i]);
    }
  }

  void addPriceList() async {
    for (var i = 0; i < _priceLists.length; i++) {
      await _dbFuction.insertPriceList(_priceLists[i]);
    }
  }

  void addAccountJournal() async {
    for (var i = 0; i < _accountJournals.length; i++) {
      await _dbFuction.insertAccountJournals(_accountJournals[i]);
    }
  }

  void addSession() async {
    await _dbFuction.insertSession(sessions[0]);
  }

  void addCompany() async {
    await _dbFuction.insertCompany(companies[0]);
  }

  void getCarts() async {
    childCarts.clear();
    childCarts = await _dbFuction.queryAllRowsCart();
    notifyListeners();
  }

  void updateSession() async {
    await _dbFuction.updateSession(sessions[0]);
  }

  void getProductsForCart() async {
    setState(true);
    List<Lines> lines = await _dbFuction.queryGetProductsForCart(positionCart);
    lstLine = lines;
    setState(false);
  }

  void updateCartPosition() {
    String dateCreateCart = convertDatetimeToString(DateTime.now());
    for (var i = 0; i < childCarts.length; i++) {
      // Cập nhật giỏ hàng được chọn
      if (childCarts[i].check == 1) {
        positionCart = childCarts[i].position;
      }

      // Cập nhật lại thời gian tao cho giỏ hàng
      childCarts[i].time = dateCreateCart;

      // Cập nhật vị trí position trc khí thoát app
      _oldPosition = (sessions[0].sequenceNumber - 1).toString();

      _dbFuction.updateCart(childCarts[i]);
    }
    getProductsForCart();
  }

  double cartAmountTotal() {
    double amountTotal = 0;
    for (var i = 0; i < _lstLine.length; i++) {
      amountTotal += (lstLine[i].qty *
          lstLine[i].priceUnit *
          (1 - lstLine[i].discount / 100));
    }
    return amountTotal;
  }

  void removeProduct(Lines item) {
    lstLine.remove(item);
    notifyListeners();
  }

  void excPayment() async {
    // update Lines

    await countInvoicePayment();
    for (var i = 0; i < lstpayment.length; i++) {
      List<Lines> _lines = await _dbFuction
          .queryGetProductsForCart(lstpayment[i].sequenceNumber.toString());
      print(_lines.length.toString());
      // cập nhật và add số sản phẩm cho giỏ hàng
      for (var i = 0; i < _lines.length; i++) {
        _lines[i].productName = null;
        _lines[i].tb_cart_position = null;
        _lines[i].isPromotion = null;
      }
      lstpayment[i].lines = _lines;

      // update StatementIds

      List<StatementIds> statementIds = await _dbFuction
          .queryStatementIds(lstpayment[i].sequenceNumber.toString());
      print(statementIds.length);
      for (var i = 0; i < statementIds.length; i++) {
        statementIds[i].position = null;
      }
      lstpayment[i].statementIds = statementIds;
      print(json.encode(lstpayment[i].toJson()));
    }

    await handlePayment();
    await countInvoicePayment();
    notifyListeners();
  }

  void handlePromotion() {
    List<Promotion> lstPromotion = [];
    for(var i=0; i< lstLine.length; i++){
      Promotion promotion = Promotion();
      promotion.discount = lstLine[i].discount;
      promotion.discountType = lstLine[i].discountType;
      promotion.discountFixed = (lstLine[i].priceUnit*lstLine[i].qty*lstLine[i].discount/100);
      promotion.name = lstLine[i].productName;
      promotion.priceUnit = lstLine[i].priceUnit;
      promotion.productId = lstLine[i].productId;
      promotion.productNameGet = lstLine[i].productName;
      promotion.qty = lstLine[i].qty;
      promotion.uOMId = lstLine[i].uomId;
      promotion.isPromotion = lstLine[i].isPromotion;
      lstPromotion.add(promotion);
    }
    promotions = lstPromotion;
    print(json.encode({"model": lstPromotion.map((val) => val.toJson()).toList()}));
    getPromotions();
  }

  void showNotifyUpdateProduct(String message) {
    _dialog.showNotify(title: "Thông báo", message: message);
  }

  void showNotifyDeleteProduct() {
    _dialog.showNotify(title: "Thông báo", message: "Đã xóa sản phẩm");
  }

  void showErrorDeleteCart() {
    _dialog.showError(title: "ERROR", content: "Không thể xóa giỏ hàng!");
  }

  void showNotifyPayment(String message) {
    _dialog.showNotify(title: "Thông báo", message: "$message");
  }
}
