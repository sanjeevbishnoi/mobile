const KHONG = "Không";
const MOT = "Một";
const HAI = "Hai";
const BA = "Ba";
const BON = "Bốn";
const NAM = "Năm";
const SAU = "Sáu";
const BAY = "Bảy";
const TAM = "Tám";
const CHIN = "Chín";
const LAM = "Lăm";
const LE = "Lẻ";
const MUOI = "Mươi";
const MUOIF = "Mười";
const MOTS = "Mốt";
const TRAM = "Trăm";
const NGHIN = "Nghìn";
const TRIEU = "Triệu";
const TY = "Tỷ";

final List<String> number = [
  KHONG,
  MOT,
  HAI,
  BA,
  BON,
  NAM,
  SAU,
  BAY,
  TAM,
  CHIN
];

List<String> readNum(String a) {
  List<String> kq = [];

  //Cắt chuổi string chử số ra thành các chuổi nhỏ 3 chử số
  List<String> listNum = split(a, 3);
  // print(object)
  while (listNum.length != 0) {
    //Xét 3 số đầu tiên của chuổi (số đầu tiên của List_Num)
    switch (listNum.length % 3) {
      //3 số đó thuộc hàng trăm
      case 1:
        var result = kq.addAll(read_3num(listNum[0]));
        break;
      // 3 số đó thuộc hàng nghìn
      case 2:
        List<String> nghin = read_3num(listNum[0]);
        if (nghin.isNotEmpty) {
          kq.addAll(nghin);
          kq.add(NGHIN);
        }
        break;
      //3 số đó thuộc hàng triệu
      case 0:
        List<String> trieu = read_3num(listNum[0]);
        if (trieu.isNotEmpty) {
          kq.addAll(trieu);
          kq.add(TRIEU);
        }
        break;
    }

    //Xét nếu 3 số đó thuộc hàng tỷ
    if (listNum.length ==
            int.parse((listNum.length / 3).toString().substring(0, 1)) * 3 +
                1 &&
        listNum.length != 1) kq.add(TY);

    //Xóa 3 số đầu tiên để tiếp tục 3 số kế
    listNum.removeAt(0);
  }

  kq.add("Đồng");
  return kq;
}

List<String> read_3num(String a) {
  List<String> kq = new List<String>();
  int num = -1;
  try {
    num = int.parse(a);
  } catch (Exception) {}
  if (num == 0) return kq;
  int hangTram = -1;
  try {
    hangTram = int.parse(a.substring(0, 1));
  } catch (Exception) {}
  int hangChuc = -1;
  try {
    hangChuc = int.parse(a.substring(1, 2));
  } catch (Exception) {}
  int hang_dv = -1;
  try {
    hang_dv = int.parse(a.substring(2, 3));
  } catch (Exception) {}

  //xét hàng trăm
  if (hangTram != -1) {
    kq.add(number[hangTram]);
    kq.add(TRAM);
  }

  //xét hàng chục
  switch (hangChuc) {
    case -1:
      break;
    case 1:
      kq.add(MUOIF);
      break;
    case 0:
      if (hang_dv != 0) kq.add(LE);
      break;
    default:
      kq.add(number[hangChuc]);
      kq.add(MUOI);
      break;
  }

  //xét hàng đơn vị
  switch (hang_dv) {
    case -1:
      break;
    case 1:
      if ((hangChuc != 0) && (hangChuc != 1) && (hangChuc != -1))
        kq.add(MOTS);
      else
        kq.add(number[hang_dv]);
      break;
    case 5:
      if ((hangChuc != 0) && (hangChuc != -1))
        kq.add(LAM);
      else
        kq.add(number[hang_dv]);
      break;
    case 0:
      if (kq.isEmpty) kq.add(number[hang_dv]);
      break;
    default:
      kq.add(number[hang_dv]);
      break;
  }
  return kq;
}

List<String> split(String str, int chunkSize) {
  int du = str.length % chunkSize;
  print(str.length.toString() + " - " + du.toString());
  //Nếu độ dài chuổi không phải bội số của chunkSize thì thêm # vào trước cho đủ.
  if (du != 0) for (int i = 0; i < (chunkSize - du); i++) str = "#" + str;
  return splitStringEvery(str, chunkSize);
}

//Hàm cắt chuổi ra thành chuổi nhỏ
List<String> splitStringEvery(String s, int interval) {
  List<String> arrList = new List<String>();
  List<String> result = new List();
  // var result = s.split("(?<=\\G.{" + interval.toString() + "})");
  int j = 0;

  int lastIndex = int.parse((s.length / interval)
      .toString()
      .replaceAll(".", "")
      .substring(0, (s.length / interval).toString().length - 2));

  // Tính số lượng chuỗi sau khi lấy chuỗi số chia cho 3
  for (var i = 0; i < lastIndex; i++) {
    result.add(s.substring(j, j + interval).toString());
    j += 3;
  }
  for (int i = 0; i < s.length / interval; i++) {
    print(result[i]);
  }
  arrList.addAll(result);
  return arrList;
}

String convertNumberToWord(String input) {
  var _moneyString = StringBuffer();
  var result = readNum(input);
  result.forEach((item) {
    _moneyString.write(item + " ");
  });
  return _moneyString.toString();
}
