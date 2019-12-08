import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/company.dart';
import 'package:tpos_mobile/pos_order/models/multi_payment.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/pos_order/models/state_cart.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/pos_order/ui/pos_cart_page.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';
import 'dart:io';

class PosPaymentViewModel extends ViewModelBase {
  DialogService _dialog;
  DatabaseFunction _dbFuction;
  IPosTposApi _tposApi;
  PosPaymentViewModel(
      {IPosTposApi tposApiService, DialogService dialogService}) {
    _dialog = dialogService ?? locator<DialogService>();
    _dbFuction = dialogService ?? locator<IDatabaseFunction>();
    _tposApi = tposApiService ?? locator<IPosTposApi>();
  }

  double tongTien = 0;
  double soTienConNo = 0;
  double soTienThua = 0;
  double soTienKhachTra = 0;
  String position = "1";
  bool checkInvoice = false;

  List<Payment> _payments = [];
  Payment payment = Payment();
  List<AccountJournal> _accountJournals = [];
  List<MultiPayment> _multiPayments = [];

  List<AccountJournal> get accountJournals => _accountJournals;
  set accountJournals(List<AccountJournal> value) {
    _accountJournals = value;
    notifyListeners();
  }

  List<MultiPayment> get multiPayments => _multiPayments;
  set multiPayment(List<MultiPayment> value) {
    _multiPayments = value;
    notifyListeners();
  }

  List<DropdownMenuItem<String>> lstPhuongThuc = [];

  void handleTienNo(String value) {
    double soTien = double.parse(value.toString().replaceAll(".", ""));
    if (tongTien > soTien) {
      soTienConNo = tongTien - soTien;
    } else {
      soTienConNo = 0;
    }
  }

  void handleTienThua(String value) {
    double soTien = double.parse(value.toString().replaceAll(".", ""));
    if (tongTien < soTien) {
      soTienThua = soTien - tongTien;
    } else {
      soTienThua = 0;
    }
  }

  void updateSoTienTra(String value) {
    soTienKhachTra = double.parse(value.toString().replaceAll(".", ""));
  }

  void handleTinhTien(String value) {
    updateSoTienTra(value);
    handleTienNo(value);
    handleTienThua(value);
    notifyListeners();
  }

  Future<void> updateData(double tongTien) async {
    await getAccountJournals();
    for (var i = 0; i < accountJournals.length; i++) {
      lstPhuongThuc.add(DropdownMenuItem<String>(
        value: "1",
        child: Text(
          "${_accountJournals[i].name}",
        ),
      ));
    }

    MultiPayment multiPayment = MultiPayment();
    multiPayment.amountTotal = tongTien;
    multiPayment.amountPaid = tongTien;
    multiPayment.amountDebt = 0;
    multiPayment.amountReturn = 0;
    multiPayment.accountJournalId = accountJournals[0].id;

    multiPayments.add(multiPayment);

    notifyListeners();
  }

  void addPayment(String value, double tongTien) {
    ////////

    if (multiPayments[multiPayments.length - 1].amountDebt <= 0) {
      double amount = double.parse(value.replaceAll(".", ""));
      MultiPayment payment = MultiPayment();
      payment.amountTotal = 0;
      payment.amountPaid = amount;
      payment.amountDebt = 0;
      payment.amountReturn =
          (multiPayments[multiPayments.length - 1].amountReturn + amount);
      if (payment.amountDebt < 0) {
        payment.amountDebt = 0;
      }
      if (payment.amountReturn < 0) {
        payment.amountReturn = 0;
      }

      multiPayments.add(payment);
    } else {
      double amount = double.parse(value.replaceAll(".", ""));
      MultiPayment payment = MultiPayment();
      payment.amountTotal =
          (multiPayments[multiPayments.length - 1].amountTotal -
              multiPayments[multiPayments.length - 1].amountPaid);
      payment.amountPaid = amount;
      payment.amountDebt =
          payment.amountTotal - double.parse(value.replaceAll(".", ""));
      payment.amountReturn =
          double.parse(value.replaceAll(".", "")) - payment.amountTotal;
      if (payment.amountDebt < 0) {
        payment.amountDebt = 0;
      }
      if (payment.amountReturn < 0) {
        payment.amountReturn = 0;
      }

      multiPayments.add(payment);
    }

    notifyListeners();
  }

  void updatePayment(int index, String value) {
    //////
    multiPayments[index].amountPaid = double.parse(value.replaceAll(".", ""));
    multiPayments[index].amountDebt = multiPayments[index].amountTotal -
        double.parse(value.replaceAll(".", ""));
    multiPayments[index].amountReturn =
        double.parse(value.replaceAll(".", "")) -
            multiPayments[index].amountTotal;
    if (multiPayments[index].amountDebt < 0) {
      multiPayments[index].amountDebt = 0;
    }
    if (multiPayments[index].amountReturn < 0) {
      multiPayments[index].amountReturn = 0;
    }

    notifyListeners();
  }

  void changePhuongThuc(String value) {
    position = value;
    notifyListeners();
  }

  Future<void> getAccountJournals() async {
    accountJournals = await _dbFuction.queryGetAccountJournals();
  }

  String getAccountJournal(int id) {
    String name = "";
    for (var i = 0; i < _accountJournals.length; i++) {
      if (id == _accountJournals[i].id) {
        name = _accountJournals[i].name;
      }
    }
    return name;
  }

  void confirmPayment() {
    Payment payment = Payment();
  }

  void addInfoPayment(int cachThucGiam, double discount, String position,
      int partnerID, BuildContext context) async {
    List<Lines> _lines = await _dbFuction.queryGetProductsForCart(position);
    List<Session> _sessions = await _dbFuction.querySessions();
    List<Companies> _companies = await _dbFuction.queryCompanys();
    List<StateCart> _carts = await _dbFuction.queryCartByPosition(position);

    double amountPaid = 0;
    payment.statementIds = [];
    for (var i = 0; i < multiPayments.length; i++) {
      // Tính tổng tiền khách đã trả
      amountPaid += multiPayments[i].amountPaid;

      StatementIds statementId = StatementIds();
      statementId.amount = multiPayments[i].amountPaid;
      statementId.journalId = multiPayments[i].accountJournalId;
      statementId.statementId = _sessions[0].id;
      statementId.accountId = _companies[0].transferAccountId;
      statementId.name = _carts[0].time;
      payment.statementIds.add(statementId);
    }
    // cập nhật và add số sản phẩm cho giỏ hàng
    for (var i = 0; i < _lines.length; i++) {
      _lines[i].productName = null;
      _lines[i].tb_cart_position = null;
      _lines[i].isPromotion = null;
    }
    payment.lines = _lines;
    // tính tổng số tiền khách đã trả

    payment.amountPaid = amountPaid;
    payment.amountReturn = amountPaid - tongTien;
    payment.amountTax = 0;
    payment.amountTotal = tongTien;
    payment.customerCount = 1;
    if (cachThucGiam == 0) {
      payment.discountType = "percentage";
      payment.discount = discount;
      payment.discountFixed = 0;
    } else if (cachThucGiam == 1) {
      payment.discountType = "amount_fixed";
      payment.discountFixed = discount;
      payment.discount = 0;
    }

    //payment.discountType = "";
    payment.loyaltyPoints = 0;
    //payment.name;
    payment.posSessionId = _sessions[0].id;
    payment.sequenceNumber = int.parse(position);
    payment.spentPoints = 0;
    payment.totalPoints = 0;
    payment.wonPoints = 0;
    payment.partnerId = partnerID;
    payment.userId = "6ae9a8e1-3acd-40c0-b3f7-96d49ce403e9";
    payment.creationDate = _carts[0].time;
    payment.uid =
        "${limitNumber(_sessions[0].id.toString(), 5)}-${limitNumber(_carts[0].loginNumber.toString(), 3)}-${limitNumber(_carts[0].position, 4)}";
    payment.name =
        "ĐH ${limitNumber(_sessions[0].id.toString(), 5)}-${limitNumber(_carts[0].loginNumber.toString(), 3)}-${limitNumber(_carts[0].position, 4)}";
    _payments.add(payment);

    // Xử lý add thông tin check hóa đơn
    List<InvoicePayment> invoicePayments = [];
    InvoicePayment invoicePayment = InvoicePayment();
    invoicePayment.isCheck = checkInvoice ? 1 : 0;
    invoicePayment.sequence = position;
    invoicePayments.add(invoicePayment);

    if (_lines.length == 0) {
      _dialog.showNotify(title: "Thông báo", message: "Giỏ hàng trống");
    } else {
      handlePayment(context, _carts[0]);
    }
    notifyListeners();
  }

  String limitNumber(String number, int limit) {
    String res = number;
    if (number.length < limit) {
      int count = limit - number.length;
      for (var i = 0; i < count; i++) {
        res = "0" + res;
      }
    }
    return res;
  }

  Future<void> handlePayment(BuildContext context, StateCart cart) async {
    setState(true);
    try {
      var result = await _tposApi.exePayment(_payments, checkInvoice);
      if (result) {
        showNotifyPayment("Thục hiện thanh toán thành công");
        Navigator.pop(context, cart);
      } else {
        if (checkInvoice) {
          await savePaymentSqlite(context, cart);
        }
        showNotifyPayment("Thục hiện thanh toán thất bại");
      }
      setState(false);
    } on SocketException catch (e, s) {
      await savePaymentSqlite(context, cart);
      setState(false);
    } catch (e, s) {
      logger.error("handlePaymentFail", e, s);
      _dialog.showError(error: e);
    }
  }

  void savePaymentSqlite(BuildContext context, StateCart cart) async {
    for (var i = 0; i < payment.statementIds.length; i++) {
      payment.statementIds[i].position = payment.sequenceNumber.toString();
      await _dbFuction.insertStatementIds(payment.statementIds[i]);
    }
    payment.lines = null;
    payment.statementIds = null;
    await _dbFuction.insertPayment(payment);
    Navigator.pop(context, cart);
  }

  void showNotifyPayment(String message) {
    _dialog.showNotify(title: "Thông báo", message: "$message");
  }

  void isCheckInvoice() {
    checkInvoice = !checkInvoice;
    notifyListeners();
  }
}
