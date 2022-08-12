import 'dart:developer';

import 'package:async/async.dart';
import 'package:medical_app/controller_time.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

class Medical {
  // đo lượng đường trong  máu và nhập lại kết quả xuống bên dưới

  // nội dung chung cho cả 2 phương án đầu tiên
  String glucose_infusion_6H12H22H = """ 
-	 Truyền glucose 10% 500ml pha truyền 10UI Actrapid (1 chai, tốc độ 100ml/h) 
"""; //  6h – 12h – 22h
  get getGlucoseinfusion_6H12H22H => this.glucose_infusion_6H12H22H;
  set setGlucoseinfusion_6H12H22H(String value) =>
      this.glucose_infusion_6H12H22H = value;
  void setInitialGlucoseinfusion_6H12H22H() =>
      this.glucose_infusion_6H12H22H = """ 
-	 Truyền glucose 10% 500ml pha truyền 10UI Actrapid (1 chai, tốc độ 100ml/h)  
"""; //  6h – 12h – 22h

// nội dung phương án cho tiêm Insulin
  String yInsu22H = """ 
- Tiêm dưới da insulin tác dụng chậm :
    + Liều khởi đầu: 0.2 UI/kg/ngày 
    + Loại Insulin: Lantus
""";
  get getYInsu22H => this.yInsu22H;
  void setYInsu22H(double value) => this.yInsu22H = """ 
- Tiêm dưới da insulin tác dụng chậm :
    + Liều khởi đầu: ${value} UI/kg/ngày 
    + Loại Insulin: Lantus
""";

// nội dung phương án bổ sung khi không đạt mục tiêu
  String sloveFailedContext = "Tiêm dưới da Actrapid 2UI\n";
  get getSloveFailedContext => this.sloveFailedContext;
  void _setSloveFailedContext(int value) =>
      this.sloveFailedContext = "Tiêm dưới da Actrapid ${value} UI\n";

// nội dung phương án cho không tiêm Insulin
  String nInsulinAllTime = "- Tạm ngừng các thuốc hạ đường máu ";

// nội dung phương án cho không đạt mục tiêu ở phương án sử dụng trên
  String upLatium = "Tăng liều lên 2UI";

  // tên phác đồ
  String namePD = "Phác đồ hiện tại: \n NUÔI DƯỠNG ĐƯỜNG TĨNH MẠCH ";
  get getNamePD => this.namePD;
  // set setNamePD(String namePD) => this.namePD = namePD;

  // Thời gian bắt đầu phác đồ
  String timeStart = "00:00";
  get getTimeStart => this.timeStart;
  set setTimeStart(String timeStart) => this.timeStart = timeStart;

  // nội dung hiển thị
  String _content_display = "Bạn có đang tiêm Insulin không :  ";
  get getContentdisplay => this._content_display;
  set setContentdisplay(String value) => this._content_display = value;

  // Kiểm tra trạng thái ban đầu
  bool _initialStateBool = false;
  get getInitialStateBool => this._initialStateBool;
  set setInitialStateBool(bool initialStateBool) =>
      this._initialStateBool = initialStateBool;
  // Kiểm tra trạng thai phương án cuối
  bool _lastStateBool = false;
  get getLastStateBool => this._lastStateBool;
  set setLastStateBool(bool value) => this._lastStateBool = value;

  // check restart app
  bool flagRestart = true;

  // số lần sử dụng 1 phương án
  int countUsedSolve = 0;
  get getCountUsedSolve => this.countUsedSolve;
  set setCountUsedSolve(int i) => this.countUsedSolve = i;
  void upCountUsedSolve() => this.countUsedSolve++;
  void downCountUsedSolve() => this.countUsedSolve--;

  // Kiểm tra nồng độ Glucozo và in ra kết quả nếu failed
  void set_Content_State_Check_Gluco_Failed(double gluco) {
    if ((8.3 < gluco) && (gluco <= 11.1)) {
      _setSloveFailedContext(2);
    } else if (gluco > 11.1) {
      _setSloveFailedContext(4);
    } else {
      setYInsu22H(0.2);
      print("Có lỗi xảy ra, không xác định");
    }
  }

  // danh sách trạng thái tiêm đạt hay không (8 lần / ngày)
  List<double> _listResultInjection = [
    -1.0,
    -1.0,
    -1.0,
    -1.0,
    -1.0,
    -1.0,
    -1.0,
    -1.0
  ];
  get getListResultInjection => this._listResultInjection;
  set setListResultInjection(List<double> listTemp) =>
      this._listResultInjection = listTemp;

  // danh sách thời gian đo đường máu mao mạch
  List<String> _listTimeResultInjection = [
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none"
  ];
  get getListTimeResultInjection => this._listTimeResultInjection;
  set setListTimeResultInjection(List<String> list) =>
      this._listTimeResultInjection = list;
  double getItemListResultInjection(int i) => this._listResultInjection[i];
  void addItemListResultInjectionItem(String value) {
    for (var i = 0; i < 8; i++) {
      if (_listResultInjection[i] + 1.0 == 0) {
        _listResultInjection[i] = double.parse(value);
        String s = DateTime.now().toString().substring(0, 16);
        List<String> listDH = s.split(' ');
        List<String> listDDMMYY = listDH[0].split('-');
        String result =
            "${listDH[1]}   ${listDDMMYY[2]}/${listDDMMYY[1]}/${listDDMMYY[0]}";
        _listTimeResultInjection[i] = result;
        break;
      }
    }
  }

  // loại bỏ lần tiêm cuối trong danh sách
  void RemoveLastItemInjection() {
    for (var i = 7; i >= 0; i--) {
      if (_listResultInjection[i] != -1) {
        _listResultInjection[i] = -1;
        _listTimeResultInjection[i] = "none";
        break;
      }
    }
  }

  // kiểm tra hàm lượng glucozo có đạt mục tiêu hay không
  int getCheckGlucozo(double glu) {
    if (glu >= 3.9 && glu <= 8.3) {
      return 0;
    } else if (glu <= 11.1 && glu > 8.3) {
      return 1;
    } else if (glu > 11.1) {
      return 2;
    }
    return -1;
  }

  // kiểm tra lượng glucose hiện tại có đạt mục tiêu hay không ?
  bool getCheckGlucozoIndex(int i) => (this._listResultInjection[i] >= 3.9 &&
          this._listResultInjection[i] <= 8.3)
      ? true
      : false;
  // lấy ra kết quả lần thất bại cuối cùng
  double getLastFaildedResultValue() {
    for (int i = 7; i >= 0; i--) {
      if (!getCheckGlucozoIndex(i) && this._listResultInjection[i] != -1)
        return this._listResultInjection[i];
    }
    return -1;
  }

  // lấy ra thời gian tiêm
  String getTimeInjectItemList(int i) => _listTimeResultInjection[i];

  bool getItemCheckFlag(int i) =>
      getCheckGlucozo(getItemListResultInjection(i)) == 0 ? true : false;
  int getCountInject() {
    for (var i = 0; i < 8; i++) {
      if (this._listResultInjection[i] == -1) return i;
    }
    return 8;
  }

  // Reset value default;
  void resetInjectionValueDefault() {
    for (var i = 0; i < 8; i++) {
      this._listResultInjection[i] = -1;
      this._listTimeResultInjection[i] = "none";
    }
  }

  // reset all value
  void resetAllvalueIinitialStatedefaut() {
    resetInjectionValueDefault();
    this.timeStart = DateTime.now().toString().substring(0, 16);
    this.setYInsu22H(0.2);
    if (getCountUsedSolve == 1) {
      downCountUsedSolve();
    }
    // phương án đề xuất đã hiện hay chưa
    this.checkDoneTask = false;
    // lựa chọn phương án ban đầu
    this._initialStateBool = false;
    // chuyển phương án cuối
    this._lastStateBool = false;
    // ẩn hiện chỗ nhập glucose
    this.isVisibleGlucose = false;
    // Lựa chọn ban đầu
    this.isVisibleYesNoo = true;
    // ẩn hiện nút "chuyển tiếp"
    this.isVisibleButtonNext = false;
    // kiểm tra xem đẫ qua bước nhập glucose hiện tại hay chưa
    this.checkCurrentGlucose = false;
    this.countUsedSolve = 0;
    this.oldDisplayContent = "Đây là phương án đầu tiên";
    this._content_display = "Bạn có đang tiêm Insulin không :  ";
  }

  // kiểm tra xem có đạt mục tiêu số lần đạt không
  int getCheckPassInjection() {
    int count = 0;
    for (var i = 0; i < getCountInject(); i++) {
      !getItemCheckFlag(i) ? count++ : null;
      if (count >= 5) {
        return 0;
      }
    }
    if (getCountInject() - count >= 4) {
      return 1;
    }
    return -1;
  }

  String oldDisplayContent = "Đây là phương án đầu tiên";
  void setOldDisplayContent() => this.oldDisplayContent =
      "Phương án trước đó: \n ${this._content_display}";

  // Thiết lập trạng thái state  thay đổi
  void setChangeStatus() {
    if (!this.checkCurrentGlucose) {
      this._content_display = "";
      if (_initialStateBool) {
        this._content_display = "${nInsulinAllTime} \n";
      }
      if (getCheckOpenCloseTimeStatus("6:00", "6:30")) {
        if (this.checkDoneTask) {
          this._content_display =
              "Bạn phải đợi đến 12h trưa để đo đường máu mao mạch";
        } else {
          this._content_display += " ${glucose_infusion_6H12H22H} ";
          if (getCheckGlucozo(this.getLastFaildedResultValue()) == 1) {
            this._setSloveFailedContext(2);
            this._content_display += this.sloveFailedContext;
          } else if (getCheckGlucozo(this.getLastFaildedResultValue()) == 2) {
            this._setSloveFailedContext(4);
            this._content_display += this.sloveFailedContext;
          }
        }
      } else if (getCheckOpenCloseTimeStatus("6:31", "11:59")) {
        this._content_display =
            "Bạn phải đợi đến 12h trưa để đo đường máu mao mạch";
      } else if (getCheckOpenCloseTimeStatus("12:00", "12:30")) {
        if (this.checkDoneTask) {
          this._content_display =
              "Bạn phải đợi đến 6h tối để đo đường máu mao mạch";
        } else {
          this._content_display += "${glucose_infusion_6H12H22H}";
          if (getCheckGlucozo(this.getLastFaildedResultValue()) == 1) {
            this._setSloveFailedContext(2);
            this._content_display += this.sloveFailedContext;
          } else if (getCheckGlucozo(this.getLastFaildedResultValue()) == 2) {
            this._setSloveFailedContext(4);
            this._content_display += this.sloveFailedContext;
          }
        }
      } else if (getCheckOpenCloseTimeStatus("12:31", "17:59")) {
        this._content_display =
            "Bạn phải đợi đến 6h tối để đo đường máu mao mạch";
      } else if (getCheckOpenCloseTimeStatus("18:00", "18:30")) {
        if (this.checkDoneTask) {
          this._content_display =
              "Bạn phải đợi đến 10h tối để đo đường máu mao mạch";
        } else {
          if (getCheckGlucozo(this.getLastFaildedResultValue()) == 1) {
            this._setSloveFailedContext(2);
            this._content_display += this.sloveFailedContext;
          } else if (getCheckGlucozo(this.getLastFaildedResultValue()) == 2) {
            this._setSloveFailedContext(4);
            this._content_display += this.sloveFailedContext;
          } else {
            this._content_display =
                "Bạn phải đợi đến 10h tối để đo đường máu mao mạch";
          }
        }
      } else if (getCheckOpenCloseTimeStatus("18:31", "21:59")) {
        this._content_display =
            "Bạn phải đợi đến 10h tối để đo đường máu mao mạch";
      } else if (getCheckOpenCloseTimeStatus("22:00", "22:30")) {
        if (this.checkDoneTask) {
          this._content_display =
              "Bạn phải đợi đến 6h sáng để đo đường máu mao mạch";
        } else {
          if (!_initialStateBool) {
            this._content_display +=
                " ${glucose_infusion_6H12H22H} ${yInsu22H}";
          } else {
            this._content_display += " ${glucose_infusion_6H12H22H}";
          }
          if (getCheckGlucozo(this.getLastFaildedResultValue()) == 1) {
            this._setSloveFailedContext(2);
            this._content_display += this.sloveFailedContext;
          } else if (getCheckGlucozo(this.getLastFaildedResultValue()) == 2) {
            this._setSloveFailedContext(4);
            this._content_display += this.sloveFailedContext;
          }
        }
      } else {
        this._content_display =
            "Bạn phải đợi đến 6h sáng để đo đường máu mao mạch";
      }
    } else {
      this._content_display = "Theo dõi đường máu mao mạch";
    }
  }

  AsyncMemoizer<String> memCache = AsyncMemoizer();
  // Read data from RealTime Database
  Future<String> readDataRealTimeDB(String s) async {
    return memCache.runOnce(() async {
      final refer = FirebaseDatabase.instance.ref();
      // await refer.child(s).onValue.listen((event) {}
      final snapshot = await refer.child(s).get();
      if (snapshot.exists) {
        var value = Map<String, dynamic>.from(snapshot.value as Map);
        this.timeNext = value["timeNext"];
        this.isVisibleButtonNext = value["isVisibleButtonNext"];
        this.isVisibleGlucose = value["isVisibleGlucose"];
        this.isVisibleYesNoo = value["isVisibleYesNoo"];
        this.checkCurrentGlucose = value["checkCurrentGlucose"];
        this.checkDoneTask = value["checkDoneTask"];
        this.setInitialStateBool = value["initialStateBool"];
        this.setLastStateBool = value["lastStateBool"];
        this.setCountUsedSolve = value["countUsedSolve"];
        this.setListResultInjection =
            (value["listResultInjection"] as List<dynamic>)
                .map((e) => (e as int).toDouble())
                .toList();
        this.setListTimeResultInjection =
            (value["listTimeResultInjection"] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
        this.setTimeStart = value["timeStart"].toString();
        this.sloveFailedContext = value["sloveFailedContext"];
        this.yInsu22H = value["yInsu22H"];
        this.oldDisplayContent = value["oldDisplayContent"];
        this.flagRestart = value["flagRestart"] ?? false;
        this.flagRestart
            ? this._content_display = "Bạn có đang tiêm Insulin không :  "
            : setChangeStatus();
      }
      return "done";
    });
  }

  // Remove data
  Future<void> removeDataBase(String s) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(s);
    await ref.remove();
  }

  //check state display Object
  bool isVisibleGlucose = false; // hiển thị thanh nhập kết quả Glucose
  bool isVisibleYesNoo = true; //  hiển thị lựa chọn Yes/No
  bool isVisibleButtonNext = false; // hiển thị nút Next

  // kiểm tra hiện tại đã tới hay qua bước nhập hay chưa
  bool checkCurrentGlucose = false;

  // kiểm tra phương án đã hiển thị
  bool checkDoneTask = false;
  void setChangeCheckDoneTask() => this.checkDoneTask = !this.checkDoneTask;

  // change display checkCurrentGlucose
  void setChangeCheckCurrentGlucose() =>
      this.checkCurrentGlucose = !this.checkCurrentGlucose;

  // change display button next
  void setChangeVisibleButtonNext() =>
      this.isVisibleButtonNext = !this.isVisibleButtonNext;
  // void display mesuaring glucose
  void setChangeVisibleGlucose() =>
      this.isVisibleGlucose = !this.isVisibleGlucose;

  // kiểm tra thời gian đo hợp lệ
  bool checkValidMeasuringTimeFocus() {
    if (getCheckOpenCloseTimeStatus('6:00', '6:30') ||
        getCheckOpenCloseTimeStatus('12:00', '12:30') ||
        getCheckOpenCloseTimeStatus('18:00', '18:30') ||
        getCheckOpenCloseTimeStatus('22:00', '22:30')) {
      return true;
    }
    return false;
  }

  String timeNext = '6:00_6:30';

  //in ra khoảng thời gian hợp lệ hiện tại
  void timeCurrentValid() {
    if (getCheckOpenCloseTimeStatus('6:00', '6:30')) {
      this.timeNext = '6:00_6:30';
    } else if (getCheckOpenCloseTimeStatus('12:00', '12:30')) {
      this.timeNext = '12:00_12:30';
    } else if (getCheckOpenCloseTimeStatus('18:00', '18:30')) {
      this.timeNext = '18:00_18:30';
    } else {
      this.timeNext = '22:00_22:30';
    }
  }

  // in ra thời gian theo dõi hợp lệ tiếp theo
  void timeNextValid() {
    if (getCheckOpenCloseTimeStatus('6:00', '6:30')) {
      this.timeNext = '12:00_12:30';
    } else if (getCheckOpenCloseTimeStatus('12:00', '12:30')) {
      this.timeNext = '18:00_18:30';
    } else if (getCheckOpenCloseTimeStatus('18:00', '18:30')) {
      this.timeNext = '22:00_22:30';
    } else {
      this.timeNext = '6:00_6:30';
    }
  }

  // toJSONEncodable() {
  //   Map<String, dynamic> subthis = new Map();
  //   subthis['content_display'] = this._content_display;
  //   subthis['namePD'] = this.namePD;
  //   subthis['initialStateBool'] = this._initialStateBool;
  //   subthis['listResultInjection'] = this._listResultInjection;
  //   subthis['listTimeResultInjection'] = this._listTimeResultInjection;
  //   subthis['lastStateBool'] = this._lastStateBool;
  //   subthis['countUsedSolve'] = this.countUsedSolve;
  //   subthis['isVisibleGlucose'] = this.isVisibleGlucose;
  //   subthis['isVisibleYesNoo'] = this.isVisibleYesNoo;
  // }
}

// class MedicalList {
//   List<Medical> items = [];

//   toJSONEncodable() {
//     return items.map((item) {
//       return item.toJSONEncodable();
//     }).toList();
//   }
// }
