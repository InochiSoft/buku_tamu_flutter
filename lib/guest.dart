import 'package:flutter/material.dart';
import 'model.dart';
import 'database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GuestActivity extends StatefulWidget {
  const GuestActivity({Key key, this.event, this.guest}) : super(key: key);
  final EventItem event;
  final GuestItem guest;

  @override
  GuestPage createState() {
    return GuestPage();
  }
}

class GuestPage extends State<GuestActivity>{
  EventItem _event;
  GuestItem _guest;
  String _selVisitTime = '';
  String _selName = '';
  String _selPhone = '';
  String _selAddress = '';
  String _selEmail = '';
  String _selNote = '';

  TextEditingController _controllerVisitTime;
  TextEditingController _controllerName;
  TextEditingController _controllerAddress;
  TextEditingController _controllerPhone;
  TextEditingController _controllerEmail;
  TextEditingController _controllerNote;

  @override
  void initState() {
    _guest = widget.guest;
    _event = widget.event;
    _controllerVisitTime = new TextEditingController();
    _controllerName = new TextEditingController();
    _controllerAddress = new TextEditingController();
    _controllerPhone = new TextEditingController();
    _controllerEmail = new TextEditingController();
    _controllerNote = new TextEditingController();

    if (_guest != null){
      _selName = _guest.guestFullName;
      _selAddress = _guest.guestAddress;
      DateTime visitTime = new DateTime.fromMillisecondsSinceEpoch(_guest.guestVisitTime);
      _selVisitTime = formatDate(visitTime) + " " + formatTime(new TimeOfDay.fromDateTime(visitTime));
      _selPhone = _guest.guestNoPhone;
      _selEmail = _guest.guestEmail;
      _selNote = _guest.guestNote;

      _controllerVisitTime.text = _selVisitTime;
      _controllerName.text = _selName;
      _controllerAddress.text = _selAddress;
      _controllerPhone.text = _selPhone;
      _controllerEmail.text = _selEmail;
      _controllerNote.text = _selNote;
    }

    super.initState();
  }

  String formatDate(DateTime date){
    int year = date.year;
    int month = date.month;
    int day = date.day;

    return day.toString() + "-" + sprintF(month)+ "-" + year.toString();
  }

  String formatTime(TimeOfDay time){
    int hour = time.hour;
    int minute = time.minute;

    return sprintF(hour) + ":" + sprintF(minute);
  }

  String sprintF(var number){
    return number.toString().padLeft(2, "0");
  }

  Future selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2030)
    );
    if(picked != null)
      setState(() {
        _selVisitTime = formatDate(picked);
        _controllerVisitTime.text = _selVisitTime;
      });
  }

  Future selectTime() async {
    var today = DateTime.now();
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: new TimeOfDay(
          hour: DateTime.now().hour,
          minute: DateTime.now().minute),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if(picked != null)
      setState(() {
        _selVisitTime = formatDate(today) + " " + formatTime(picked);
        _controllerVisitTime.text = _selVisitTime;
      });
  }

  void saveGuest(){
    bool isNew = false;

    if (_guest == null){
      _guest = new GuestItem();
      _guest.eventId = _event.eventId;

      isNew = true;
    }

    _guest.guestFullName = _selName;
    _guest.guestAddress = _selAddress;
    _guest.guestNoPhone = _selPhone;
    _guest.guestEmail = _selEmail;
    _guest.guestNote = _selNote;

    int year = DateTime.now().year;
    int month = DateTime.now().month;
    int day = DateTime.now().day;
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;
    int second = 0;

    if (_selVisitTime.isNotEmpty){
      List<String> arrDateTime = _selVisitTime.split(" ");
      if (arrDateTime.length >= 2){
        String strDate = arrDateTime[0];
        String strTime = arrDateTime[1];

        if (strDate.isNotEmpty){
          List<String> arrDate = strDate.split("-");
          if (arrDate.length == 3){
            day = int.parse(arrDate[0]);
            month = int.parse(arrDate[1]);
            year = int.parse(arrDate[2]);
          }
        }
        if (strTime.isNotEmpty){
          List<String> arrTime = strTime.split(":");
          if (arrTime.length >= 2){
            hour = int.parse(arrTime[0]);
            minute = int.parse(arrTime[1]);
            if (arrTime.length == 3){
              second = int.parse(arrTime[2]);
            }
          }
        }
      }
    }

    var selVisitTime = new DateTime(year, month, day, hour, minute, second);
    _guest.guestVisitTime = selVisitTime.millisecondsSinceEpoch;

    if (isNew){
      DatabaseProvider databaseProvider = new DatabaseProvider();
      databaseProvider.open().then((value){
        databaseProvider.insertGuest(_guest).then((guest) {
          Fluttertoast.showToast(
              msg: "Tamu berhasil ditambahkan",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1
          );
          databaseProvider.close();
          Navigator.pop(context, _guest);
        });
      });
    } else {
      DatabaseProvider databaseProvider = new DatabaseProvider();
      databaseProvider.open().then((value){
        databaseProvider.updateGuest(_guest).then((guest) {
          Fluttertoast.showToast(
              msg: "Acara berhasil diperbarui",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1
          );
          databaseProvider.close();
          Navigator.pop(context, _guest);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Acara"),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.brown.shade200,
              child: Card(
                elevation: 4.0,
                color: Colors.brown.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  side: BorderSide(
                    color: Colors.brown.shade400,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown.shade600,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 140,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Waktu Kunjungan",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  controller: _controllerVisitTime,
                                  onTap: selectTime,
                                  textInputAction: TextInputAction.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown.shade600,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Nama Lengkap",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  controller: _controllerName,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (value){
                                    setState(() {
                                      _selName = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown.shade600,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("No HP",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  controller: _controllerPhone,
                                  autocorrect: false,
                                  onChanged: (value){
                                    setState(() {
                                      _selPhone = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown.shade600,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Email",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _controllerEmail,
                                  autocorrect: false,
                                  onChanged: (value){
                                    setState(() {
                                      _selEmail = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown.shade600,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Alamat",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  minLines: 2,
                                  controller: _controllerAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.sentences,
                                  onChanged: (value){
                                    setState(() {
                                      _selAddress = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.brown.shade600,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Catatan",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  minLines: 2,
                                  controller: _controllerNote,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.sentences,
                                  onChanged: (value){
                                    setState(() {
                                      _selNote = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveGuest,
        backgroundColor: Colors.brown.shade200,
        tooltip: 'Tambah Acara',
        child: Icon(Icons.save,
          color: Colors.black45,
        ),
      ),
    );
  }
}
