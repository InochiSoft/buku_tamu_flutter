import 'package:flutter/material.dart';
import 'model.dart';
import 'database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EventActivity extends StatefulWidget {
  const EventActivity({Key key, this.event}) : super(key: key);
  final EventItem event;

  @override
  EventPage createState() {
    return EventPage();
  }
}

class EventPage extends State<EventActivity>{
  EventItem _event;
  String _selDate = '';
  String _selTime = '';
  String _selName = '';
  String _selAddress = '';

  TextEditingController _controllerDate;
  TextEditingController _controllerTime;
  TextEditingController _controllerName;
  TextEditingController _controllerAddress;

  @override
  void initState() {
    _event = widget.event;
    _controllerDate = new TextEditingController();
    _controllerTime = new TextEditingController();
    _controllerName = new TextEditingController();
    _controllerAddress = new TextEditingController();

    if (_event != null){
      _selName = _event.eventName;
      _selAddress = _event.eventAddress;
      _selDate = formatDate(new DateTime.fromMillisecondsSinceEpoch(_event.eventDate));
      _selTime = formatTime(new TimeOfDay.fromDateTime(new DateTime.fromMillisecondsSinceEpoch(_event.eventTime)));

      _controllerName.text = _selName;
      _controllerAddress.text = _selAddress;
      _controllerDate.text = _selDate;
      _controllerTime.text = _selTime;
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
        _selDate = formatDate(picked);
        _controllerDate.text = _selDate;
      });
  }

  Future selectTime() async {
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
        _selTime = formatTime(picked);
        _controllerTime.text = _selTime;
      });
  }

  void saveEvent(){
    bool isNew = false;

    if (_event == null){
      _event = new EventItem();
      _event.isCompleted = 0;

      isNew = true;
    }

    _event.eventName = _selName;
    _event.eventAddress = _selAddress;

    int year = DateTime.now().year;
    int month = DateTime.now().month;
    int day = DateTime.now().day;

    if (_selDate.isNotEmpty){
      List<String> arrDate = _selDate.split("-");
      if (arrDate.length == 3){
        day = int.parse(arrDate[0]);
        month = int.parse(arrDate[1]);
        year = int.parse(arrDate[2]);
      }
    }

    var selDTDate = new DateTime(year, month, day, 0, 0, 0);

    _event.createDate = DateTime.now().millisecondsSinceEpoch;
    _event.eventDate = selDTDate.millisecondsSinceEpoch;

    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;

    if (_selTime.isNotEmpty){
      List<String> arrTime = _selTime.split(":");
      if (arrTime.length >= 2){
        hour = int.parse(arrTime[0]);
        minute = int.parse(arrTime[1]);
      }
    }

    var selDTTime = new DateTime(year, month, day, hour, minute, 0);
    _event.eventTime = selDTTime.millisecondsSinceEpoch;

    if (isNew){
      DatabaseProvider databaseProvider = new DatabaseProvider();
      databaseProvider.open().then((value){
        databaseProvider.insertEvent(_event).then((event) {
          Fluttertoast.showToast(
              msg: "Acara berhasil ditambahkan",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1
          );
          databaseProvider.close();
          Navigator.pop(context, _event);
        });
      });
    } else {
      DatabaseProvider databaseProvider = new DatabaseProvider();
      databaseProvider.open().then((value){
        databaseProvider.updateEvent(_event).then((event) {
          Fluttertoast.showToast(
              msg: "Acara berhasil diperbarui",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1
          );
          databaseProvider.close();
          Navigator.pop(context, _event);
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
                                width: 120,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Tanggal",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  controller: _controllerDate,
                                  onTap: selectDate,
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
                                  child: Text("Waktu",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: TextField(
                                  controller: _controllerTime,
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
                                  child: Text("Nama",
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
                                width: 120,
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
        onPressed: saveEvent,
        backgroundColor: Colors.brown.shade200,
        tooltip: 'Tambah Acara',
        child: Icon(Icons.save,
          color: Colors.black45,
        ),
      ),
    );
  }
}
