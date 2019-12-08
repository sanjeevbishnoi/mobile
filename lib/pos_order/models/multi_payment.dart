import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';

class MultiPayment {
  double amountTotal;
  double amountPaid;
  double amountReturn;
  double amountDebt;
  int accountJournalId;

  MultiPayment(
      {this.amountTotal,
      this.amountPaid,
      this.amountReturn,
      this.amountDebt,
      this.accountJournalId});
}
