class PrinterSetting {
  PrintSize printSize;
  PrintOrientation printOrientation;
  String printerInfo;
  List<SupportPrintSize> supportPrintSizes;
  String printerName;

  String get printSizeAndOrienttation =>
      "${printSize.toString().replaceAll("PrintSize.", "")}_${printOrientation.toString().replaceAll("PrintOrientation.", "")}";
  PrinterSetting(
      {this.printSize,
      this.printOrientation,
      this.printerInfo,
      this.supportPrintSizes,
      this.printerName});
}

class SupportPrintSize {
  final String name;
  final String code;

  SupportPrintSize(this.name, this.code);
}

enum PrintSize {
  WEB,
  A5,
  A4,
  BILL80,
  BILL58,
}

enum PrintOrientation {
  PORTRAIT,
  LANDSCAPE,
}
