import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model.dart';
import 'database.dart';
import 'event.dart';
import 'guests.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Tamu',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MainActivity(title: 'Buku Tamu'),
    );
  }
}

class MainActivity extends StatefulWidget {
  MainActivity({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MainPage createState() => MainPage();
}

class MainPage extends State<MainActivity> {
  EventItem _event;
  List<EventItem> _listEvent = new List();
  DatabaseProvider databaseProvider = new DatabaseProvider();

  @override
  void initState(){
    createDefaultEvent();
    super.initState();
  }

  void createDefaultEvent(){
    databaseProvider.open().then((_){
      databaseProvider.getListEvent().then((list){
        if (list != null){
          if (list.length == 0){
            EventItem eventDef = new EventItem();

            eventDef.eventName = "Perkawinan Jang Karim dan Nyi Imas";
            eventDef.eventAddress = "Garut";
            eventDef.isCompleted = 0;

            int currTime = DateTime.now().millisecondsSinceEpoch;

            eventDef.eventDate = currTime;
            eventDef.eventTime = currTime;
            eventDef.createDate = currTime;

            databaseProvider.insertEvent(eventDef).then((event) {
              databaseProvider.close();
            });
          }
        }
      });
    });
  }

  void _refreshList() {
    databaseProvider.open().then((_){
      databaseProvider.getListEvent().then((list){
        if (list != null){
          setState(() {
            _listEvent = list;
          });
          databaseProvider.close();
        }
      });
    });
  }

  String sprintF(var number){
    return number.toString().padLeft(2, "0");
  }

  String formatDate(int millis){
    if (millis != null){
      var date = new DateTime.fromMillisecondsSinceEpoch(millis);
      int year = date.year;
      int month = date.month;
      int day = date.day;

      List<String> monthNames = ["", "Januari", "Februari", "Maret", "April",
        "Mei", "Juni", "Juli", "Agustus", "September",
        "Oktober", "November", "Desember"];

      return day.toString() + " " + monthNames[month] + " " + year.toString();
    }
    return '';
  }

  String formatTime(int millis){
    if (millis != null){
      var date = new DateTime.fromMillisecondsSinceEpoch(millis);
      int hour = date.hour;
      int minute = date.minute;

      return sprintF(hour) + ":" + sprintF(minute);
    }
    return '';
  }

  Widget createEventItem(EventItem event){
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
        side: BorderSide(
          color: Colors.brown.shade200,
          width: 1.0,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.brown.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          side: BorderSide(
            color: Colors.brown.shade200,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _event = event;
            });
            showGuestsActivity();
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.event_note,
                  color: Colors.grey.shade600,
                  size: 56.0,
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(event.eventName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(formatDate(event.eventDate) + " " +
                          formatTime(event.eventTime),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black45,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(event.eventAddress,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black45,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            _event = event;
                          });
                          showEventActivity();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.edit,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (){
                          if (_listEvent.length > 0){
                            setState(() {
                              _event = event;
                            });
                            showDeleteDialog();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.delete,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listViewBuilder(BuildContext context, int index){
    EventItem event = _listEvent[index];
    return createEventItem(event);
  }

  void showEventActivity(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventActivity(event: _event,),
      ),
    ).then((value){
      if (value != null)
      setState(() {
        _refreshList();
      });
    });
  }

  void showGuestsActivity(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestsActivity(event: _event,),
      ),
    ).then((value){
      if (value != null)
        setState(() {

        });
    });
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus"),
          content: Text("Ingin menghapus acara?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Ya"),
              onPressed: () {
                databaseProvider.open().then((value){
                  databaseProvider.deleteEvent(_event.eventId).then((event) {
                    Fluttertoast.showToast(
                        msg: "Acara berhasil dihapus",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1
                    );
                    setState(() {
                      _listEvent.remove(event);
                    });
                    databaseProvider.close();
                    Navigator.of(context).pop();
                  });
                });
              },
            ),
            FlatButton(
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget _loading = Center (
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 10,),
          Text("Menyiapkan Data")
        ],
      ),
    );

    Widget  _blank = Center(
      child: Container(
        height: 40,
        child: Text("Belum ada acara tersedia"),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshList
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Colors.brown.shade200,
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 8.0
                ),
                child: Text(
                  "Silakan memilih acara tersedia, atau tap pada tombol tambah di bawah untuk membuat acara baru",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: FutureBuilder(
                    future: databaseProvider.open(),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if (snapshot.connectionState == ConnectionState.done) {
                        return FutureBuilder(
                          future: databaseProvider.getListEvent(),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                _listEvent = snapshot.data;
                                databaseProvider.close();

                                if (_listEvent.length == 0){
                                  return _blank;
                                } else {
                                  return ListView.builder(
                                    itemCount: _listEvent.length,
                                    itemBuilder: listViewBuilder,
                                  );
                                }
                              } else {
                                return _blank;
                              }
                            } else {
                              return _blank;
                            }
                          },
                        );
                      } else {
                        return _loading;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          setState(() {
            _event = null;
          });
          showEventActivity();
        },
        backgroundColor: Colors.brown.shade200,
        tooltip: 'Tambah Acara',
        child: Icon(Icons.add_box,
          color: Colors.black45,
        ),
      ),
    );
  }
}
