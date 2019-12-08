import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_payment.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FastSaleOrderPaymentViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("FastSaleOrderPaymentViewModel");

  FastSaleOrderPaymentViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  AccountPayment _payment;
  AccountPayment get payment => _payment;
  List<AccountJournal> _accountJournals;
  List<AccountJournal> get accountJournals => _accountJournals;
  AccountJournal _selectedAccountJournal;
  AccountJournal get selectedAccountJournal => _selectedAccountJournal;

  double amount;
  DateTime datePayment;
  String description;

  void init({AccountPayment defaultPayment, double amount, String content}) {
    _payment = defaultPayment ?? new AccountPayment();
    this.amount = _payment.amount ?? amount ?? 0;
    datePayment = _payment.paymentDate ?? DateTime.now();
    description = _payment.communication ?? content;
  }

  Future initCommand() async {
    onIsBusyAdd(true);
    // Tải phương thức thanh toán
    await _loadPaymentJournals();
    onIsBusyAdd(false);
  }

  ///Command Lụa chọn phương thức thanh toán
  Future selectAccountJournalCommand(AccountJournal value) async {
    _selectedAccountJournal = value;
    // get new data
    onStateAdd(true);
    try {
      var onChangeResult = await _tposApi.accountPaymentOnChangeJournal(
          this.selectedAccountJournal.id, this.payment.paymentType);

      if (onChangeResult.error == null) {
        this.payment.paymentMethodId = onChangeResult.value.paymentMethodId;
      }
    } catch (e, s) {
      _log.severe("selectAccountCommand", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", e.toString()));
    }
    onPropertyChanged("");
    onStateAdd(false);
  }

  // Submit command
  Future<bool> submitPaymentCommand() async {
    onStateAdd(true);
    try {
      payment.paymentDate = this.datePayment;
      payment.communication = this.description;
      payment.amount = this.amount;

      payment.currencyId = 1;
      payment.journalId = this.selectedAccountJournal.id;
      payment.journal = this.selectedAccountJournal;

      var submitResult = await _tposApi.accountPaymentCreatePost(payment);
      if (submitResult.error == false) {
        onDialogMessageAdd(
            OldDialogMessage.flashMessage("Lưu hóa đơn thành công"));
        return result(true);
      } else {
        onDialogMessageAdd(
            OldDialogMessage.error("", submitResult.message, title: "Error!"));
        return result(false);
      }
    } catch (e, s) {
      _log.severe("submit payment", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", e.toString(),
          title: "Lỗi không xác định"));
      return result(false);
    }
  }

  Future _loadPaymentJournals() async {
    try {
      var getResult = await _tposApi.accountJournalGetWithCompany();
      if (getResult.error == false) {
        _accountJournals = getResult.result;
        onPropertyChanged("");
      } else {
        onDialogMessageAdd(OldDialogMessage.error("", getResult.message,
            title: "Không tải được!"));
      }
    } catch (e, s) {
      _log.severe("", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", e.toString(),
          title: "Lỗi không xác định!"));
    }
  }

  bool result(bool value) {
    onStateAdd(false);
    return value;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
