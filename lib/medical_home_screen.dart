import 'dart:ffi';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_app/controller_time.dart';
import 'package:medical_app/history_screen.dart';
import 'package:medical_app/medical_class.dart';
import 'package:medical_app/sizeDevide.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:toast/toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import "dart:async";

class MedicalHomeScreen extends StatefulWidget {
  const MedicalHomeScreen({Key? key}) : super(key: key);

  @override
  State<MedicalHomeScreen> createState() => _MedicalHomeScreenState();
}

class _MedicalHomeScreenState extends State<MedicalHomeScreen>
    with WidgetsBindingObserver {
  Medical medicalObject = Medical();
  // late AppLifecycleState _lastLifecycleState;
  final TextEditingController _editingController = TextEditingController();
  // get instancr firebase database
  final reference = FirebaseDatabase.instance.ref("Medicals/medical");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // sava data when close app
  @override
  void dispose() {
    print("app was closed");
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused &&
        medicalObject.flagRestart == false) {
      await reference.set({
        "namePD": medicalObject.getNamePD,
        "initialStateBool": medicalObject.getInitialStateBool,
        "lastStateBool": medicalObject.getLastStateBool,
        "listResultInjection": medicalObject.getListResultInjection,
        "listTimeResultInjection": medicalObject.getListTimeResultInjection,
        "isVisibleGlucose": medicalObject.isVisibleGlucose,
        "isVisibleYesNoo": medicalObject.isVisibleYesNoo,
        "countUsedSolve": medicalObject.getCountUsedSolve,
        "timeStart": medicalObject.getTimeStart.toString(),
        "sloveFailedContext": medicalObject.getSloveFailedContext,
        "yInsu22H": medicalObject.getYInsu22H,
        "oldDisplayContent": medicalObject.oldDisplayContent,
        "flagRestart": medicalObject.flagRestart,
        "isVisibleButtonNext": medicalObject.isVisibleButtonNext,
        "checkCurrentGlucose": medicalObject.checkCurrentGlucose,
        "checkCurrentGlucose": medicalObject.checkCurrentGlucose,
        "checkDoneTask": medicalObject.checkDoneTask,
        //  "address": {"line1": "100 Mountain View"}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const BackButtonIcon(),
          ),
        ),
        body: FutureBuilder(
            future: medicalObject.readDataRealTimeDB("Medicals/medical"),
            builder: (context, snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xfff5f6f6),
                          Colors.white,
                        ],
                      )),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // profile thông tin bệnh nhân
                          Row(
                            children: [
                              SizedBox(
                                height: 90,
                                width: 90,
                                child: CircleAvatar(
                                  radius: 48, // Image radius
                                  backgroundImage: NetworkImage(
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqkKsJE9otzQr3RAnkLRCThzaxfoJ0_6W2sg&usqp=CAU'),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10, top: 5),
                                height: 100,
                                width: widthDevideMethod(0.6),
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text('Nguyễn Kiều Anh'),
                                    Text(
                                      ' Tiểu Đường , 27 tuổi , Nữ giới',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(
                                      height: heightDevideMethod(0.012),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: widthDevideMethod(0.03),
                                        ),
                                        // xem chi tiết thông tin bệnh nhân
                                        SizedBox(
                                          height: 30,
                                          child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text('Xem chi tiết'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.blue[400],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          width: widthDevideMethod(0.05),
                                        ),
                                        //  Nhắn tin với bệnh nhân
                                        SizedBox(
                                          height: 30,
                                          child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text('Nhắn tin'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.blue[400],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Logic bác sĩ
                          Container(
                            padding: const EdgeInsets.only(bottom: 20, top: 20),
                            child: Text(
                              '${medicalObject.getNamePD}',
                              style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            height: heightDevideMethod(0.42),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: heightDevideMethod(0.4),
                                  child: Row(
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: widthDevideMethod(0.1),
                                        height: heightDevideMethod(0.37),
                                      ),
                                      SizedBox(
                                          width: widthDevideMethod(0.7),
                                          child: Image.asset(
                                              "assets/doctor.jpg",
                                              fit: BoxFit.fitHeight)),
                                      Expanded(
                                          child: Container(
                                              color: const Color(0xfff5f6f6))),
                                    ],
                                  ),
                                ),
                                Positioned(
                                    right: 30,
                                    top: 20,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.info,
                                        color: Colors.grey[800],
                                        size: 40,
                                      ),
                                      tooltip: medicalObject.oldDisplayContent,
                                      onPressed: () {},
                                    )),
                                Positioned(
                                  top: 120,
                                  left: 10,
                                  child: Container(
                                    alignment: Alignment.topCenter,
                                    width: widthDevideMethod(0.91),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/bbchat1.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            height: heightDevideMethod(0.03)),

                                        //  Bạn có đang tiêm Insulin không ?
                                        Row(
                                          children: [
                                            Container(
                                              width: widthDevideMethod(0.04),
                                            ),
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 5),
                                                child: Text(
                                                  '${medicalObject.getContentdisplay}  ',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              alignment: Alignment.center,
                                              child: Visibility(
                                                visible: medicalObject
                                                    .isVisibleYesNoo,
                                                child: ToggleSwitch(
                                                  customWidths: const [
                                                    40.0,
                                                    50.0
                                                  ],
                                                  customHeights: const [20, 20],
                                                  initialLabelIndex: 2,
                                                  cornerRadius: 20.0,
                                                  activeFgColor: Colors.white,
                                                  inactiveBgColor: Colors.grey,
                                                  inactiveFgColor: Colors.white,
                                                  totalSwitches: 2,
                                                  fontSize: 14,
                                                  labels: const ['No', 'Yes'],
                                                  activeBgColors: const [
                                                    [Colors.pink],
                                                    [Colors.green]
                                                  ],
                                                  onToggle: (index) {
                                                    medicalObject.flagRestart =
                                                        false;
                                                    medicalObject.setTimeStart =
                                                        DateTime.now()
                                                            .toString()
                                                            .substring(0, 16);
                                                    print(medicalObject
                                                        .getTimeStart);
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      setState(() {
                                                        medicalObject
                                                                .isVisibleYesNoo =
                                                            false;
                                                        medicalObject
                                                                .setInitialStateBool =
                                                            index == 0
                                                                ? true
                                                                : false;
                                                        if (medicalObject
                                                            .checkValidMeasuringTimeFocus()) {
                                                          medicalObject
                                                              .setChangeVisibleGlucose();
                                                        } else {
                                                          medicalObject
                                                              .setChangeCheckCurrentGlucose();
                                                          medicalObject
                                                              .setChangeVisibleButtonNext();
                                                        }
                                                        medicalObject
                                                            .setChangeStatus();
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: 10,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.restart_alt_rounded,
                                      size: 35,
                                    ),
                                    tooltip: 'restart',
                                    onPressed: () => _showMyDialog(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Nút chuyển tiếp phương án
                          Visibility(
                            visible: medicalObject.isVisibleButtonNext,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (medicalObject
                                      .checkValidMeasuringTimeFocus()) {
                                    if (!medicalObject.checkDoneTask) {
                                      setState(() {
                                        medicalObject
                                            .setChangeVisibleButtonNext(); // ẩn nút
                                        medicalObject
                                            .setChangeVisibleGlucose(); // hiện nhập glucose
                                        medicalObject.checkCurrentGlucose =
                                            false;
                                      });
                                    } else {
                                      showToast("Chưa đến giờ đo đâu",
                                          duration: 3, gravity: Toast.bottom);
                                    }
                                  } else {
                                    medicalObject.checkDoneTask = false;
                                    showToast("Chưa đến giờ đo",
                                        duration: 3, gravity: Toast.bottom);
                                  }
                                  setState(() {
                                    medicalObject.setChangeStatus();
                                  });
                                },
                                child: const Text('Chuyển tiếp >>>')),
                          ),
                          // Nút hoàn thành phương án
                          // Visibility(
                          //   visible: medicalObject.checkDoneTask,
                          //   child: ElevatedButton(
                          //       onPressed: () {
                          //         if (medicalObject
                          //             .checkValidMeasuringTimeFocus()) {
                          //           if (!medicalObject.checkDoneTask) {
                          //             setState(() {
                          //               medicalObject
                          //                   .setChangeVisibleButtonNext(); // ẩn nút
                          //               medicalObject
                          //                   .setChangeVisibleGlucose(); // hiện nhập glucose
                          //             });
                          //           } else {
                          //             showToast("Chưa đến giờ đo",
                          //                 duration: 3, gravity: Toast.bottom);
                          //           }
                          //         } else {
                          //           medicalObject.checkDoneTask = false;
                          //           showToast("Chưa đến giờ đo",
                          //               duration: 3, gravity: Toast.bottom);
                          //         }
                          //         setState(() {
                          //           medicalObject.setChangeStatus();
                          //         });
                          //       },
                          //       child: const Text('Hoàn Thành >>>')),
                          // ),

                          Visibility(
                            visible: medicalObject.isVisibleGlucose,
                            child: Column(
                              children: [
                                SizedBox(width: widthDevideMethod(0.05)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      ' Nhập giá trị (mol/l) : ',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: TextField(
                                        controller: _editingController,
                                        maxLength: 5,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[0-9.]')),
                                        ],
                                        decoration: const InputDecoration(
                                          counter: Offstage(),
                                        ),
                                        style: const TextStyle(fontSize: 20),
                                        onSubmitted: (value) {
                                          _editingController.text = '';
                                          _showDialogInputGlucose(value);
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HistoryScreen(
                                                      medical: medicalObject))),
                                      child: const Icon(
                                        Icons.history,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ];
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ];
              } else {
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ];
              }
              return snapshot.hasData
                  ? SingleChildScrollView(
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: children,
                        ),
                      ),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: children,
                        ),
                      ),
                    );
            }));
  }

  // show toast infomation
  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Khôi phục mặc định'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Dữ liệu sẽ bị xóa toàn bộ về trạng thái ban đầu '),
                Text('Bạn có chắc chắn không ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  medicalObject.flagRestart = true;
                  medicalObject.removeDataBase("Medicals/medical");
                  medicalObject.resetAllvalueIinitialStatedefaut();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //  verifyle kết quả  đo
  Future<void> _showDialogInputGlucose(String value) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đường máu mao mạch'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Giá trị bạn nhập vào là ${value}'),
                Text('nhấn "Yes" để xác nhận chính xác hoặc "No" để nhập lại'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  this._logicStateInfomation(value);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // xử lý logic
  Future<void> _logicStateInfomation(String value) async {
    setState(() {
      medicalObject.addItemListResultInjectionItem(
          value); // double.parse(value.toString())
      Future.delayed(
          const Duration(seconds: 1),
          (() => showToast(
              "Lượng Glucose $value ${medicalObject.getCheckGlucozo(double.parse(value.toString())) == 0 ? "đạt mục tiêu" : "KHÔNG đạt mục tiêu"} ",
              duration: 3,
              gravity: Toast.bottom)));

      medicalObject.setChangeCheckCurrentGlucose(); // nhập xong
      medicalObject.setChangeVisibleButtonNext(); // hiện lại nút next
      medicalObject.setChangeVisibleGlucose(); //  ẩn thanh nhập
      medicalObject.setChangeStatus(); // thay đổi trạng thái
      medicalObject.checkDoneTask = true; // đã hiện phác đồ
    });
  }
}

    //// Xử lý false khi không đạt yêu cầu

    // if (medicalObject.getCountInject() >= 4) {
    //     if (medicalObject.getCheckPassInjection() == 0) {
    //       // Trường hợp không tiêm Insulin không đạt mục tiêu
    //       if (medicalObject.getInitialStateBool) {
    //         // ko tiêm Insulin không đạt mục tiêu lần 1
    //         if (medicalObject.getCountUsedSolve == 0) {
    //           medicalObject.set_Content_State_Check_Gluco_Failed(
    //               medicalObject.getLastFaildedResultValue());
    //           medicalObject.setOldDisplayContent();
    //           medicalObject.setContentdisplay =
    //               """Phương án hiện tại không đạt yêu cầu \n nên thêm ${medicalObject.getSloveFailedContext}""";

    //           medicalObject.upCountUsedSolve();
    //           medicalObject.resetInjectionValueDefault();
    //           Future.delayed(const Duration(seconds: 8), (() {
    //             setState(() {
    //               medicalObject.setChangeStatus();
    //             });
    //           }));
    //           // không tiêm Insulin không đạt mục tiêu lần 2
    //         } else if (medicalObject.getCountUsedSolve == 1) {
    //           medicalObject.setOldDisplayContent();
    //           medicalObject.setContentdisplay =
    //               "Phương án hiện tại không đạt yêu cầu \n chuyển sang 1 phương án khác !";
    //           medicalObject.downCountUsedSolve();
    //           medicalObject.setInitialStateBool =
    //               !medicalObject.getInitialStateBool;
    //           medicalObject.resetInjectionValueDefault();
    //           Future.delayed(const Duration(seconds: 8), (() {
    //             setState(() {
    //               medicalObject.setChangeStatus();
    //             });
    //           }));
    //         }
    //       } else {
    //         // Phương án tiêm insulin không đạt mục tiêu
    //         if (!medicalObject.getLastStateBool) {
    //           //  tiêm Insulin không đạt mục tiêu lần 1
    //           if (medicalObject.getCountUsedSolve == 0) {
    //             medicalObject.set_Content_State_Check_Gluco_Failed(
    //                 medicalObject.getLastFaildedResultValue());
    //             medicalObject.setOldDisplayContent();
    //             medicalObject.setContentdisplay =
    //                 """Phương án hiện tại không đạt yêu cầu \n nên thêm ${medicalObject.getSloveFailedContext}""";
    //             medicalObject.upCountUsedSolve();
    //             medicalObject.resetInjectionValueDefault();
    //             Future.delayed(const Duration(seconds: 6), (() {
    //               setState(() {
    //                 medicalObject.setChangeStatus();
    //               });
    //             }));
    //           } else if (medicalObject.getCountUsedSolve == 1) {
    //             medicalObject.setOldDisplayContent();
    //             medicalObject.setContentdisplay =
    //                 "Phương án hiện tại không đạt yêu cầu \n cần tăng liều Lantus lên 2UI !";
    //             medicalObject.downCountUsedSolve();
    //             medicalObject.setYInsu22H(2);
    //             medicalObject.setLastStateBool = true;
    //             medicalObject.resetInjectionValueDefault();
    //             Future.delayed(const Duration(seconds: 6), (() {
    //               setState(() {
    //                 medicalObject.setChangeStatus();
    //               });
    //             }));
    //           }
    //         } else {
    //           // Phương án cuối cùng tăng liều 2UI Lantus
    //           if (medicalObject.getCountUsedSolve == 0) {
    //             medicalObject.upCountUsedSolve();
    //             medicalObject.set_Content_State_Check_Gluco_Failed(
    //                 medicalObject.getLastFaildedResultValue());
    //             medicalObject.setOldDisplayContent();
    //             medicalObject.setContentdisplay =
    //                 """Phương án hiện tại không đạt yêu cầu \n nên thêm ${medicalObject.getSloveFailedContext}""";
    //             medicalObject.resetInjectionValueDefault();
    //             Future.delayed(const Duration(seconds: 6), (() {
    //               setState(() {
    //                 medicalObject.setChangeStatus();
    //               });
    //             }));
    //           } else if (medicalObject.getCountUsedSolve == 1) {
    //             medicalObject.setOldDisplayContent();
    //             medicalObject.setContentdisplay =
    //                 "Phác đồ này không đạt hiểu quả \n hãy chuyển sang phác đồ \n TRUYỀN INSULIN BƠM TIÊM ĐIỆN ";
    //             // medicalObject.resetAllvalueIinitialStatedefaut();
    //           }
    //         }
    //       }
    //     } else if (medicalObject.getCheckPassInjection() == 1) {
    //       medicalObject.setOldDisplayContent();
    //       medicalObject.setContentdisplay =
    //           "Phương án này đang có hiệu quả tốt \n tiếp tục sử dụng phương án này nhé !";
    //       Future.delayed(const Duration(seconds: 6), (() {
    //         setState(() {
    //           medicalObject.setChangeStatus();
    //         });
    //       }));
    //       medicalObject.resetInjectionValueDefault();
    //     }
    //   }