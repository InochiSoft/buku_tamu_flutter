import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model.dart';
import 'database.dart';
import 'guest.dart';

class GuestsActivity extends StatefulWidget {
  GuestsActivity({Key key, this.event}) : super(key: key);

  final EventItem event;

  @override
  GuestsPage createState() => GuestsPage();
}

class GuestsPage extends State<GuestsActivity> {
  EventItem _event;
  GuestItem _guest;
  List<GuestItem> _listGuest = new List();
  DatabaseProvider databaseProvider = new DatabaseProvider();

  @override
  void initState(){
    _event = widget.event;
    super.initState();
  }

  void _refreshList() {
    databaseProvider.open().then((_){
      databaseProvider.getListGuest(_event.eventId).then((list){
        if (list != null){
          setState(() {
            _listGuest = list;
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
    var date = new DateTime.fromMillisecondsSinceEpoch(millis);
    int year = date.year;
    int month = date.month;
    int day = date.day;

    List<String> monthNames = ["", "Januari", "Februari", "Maret", "April",
      "Mei", "Juni", "Juli", "Agustus", "September",
      "Oktober", "November", "Desember"];

    return day.toString() + " " + monthNames[month] + " " + year.toString();
  }

  String formatTime(int millis){
    var date = new DateTime.fromMillisecondsSinceEpoch(millis);
    int hour = date.hour;
    int minute = date.minute;

    return sprintF(hour) + ":" + sprintF(minute);
  }

  Widget createGuestItem(GuestItem guest){
    return Card(
      elevation: 4.0,
      child: Material(
        color: Colors.brown.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _guest = guest;
            });
            showGuestActivity();
          },
          child: Row(
            children: <Widget>[
              Container (
                padding: EdgeInsets.all(2.0),
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade800,
                  size: 36.0,
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(guest.guestFullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              if (_listGuest.length > 0){
                                showDeleteDialog(guest);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.delete,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0,),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            color: Colors.grey.shade800,
                            size: 16.0,
                          ),
                          SizedBox(width: 5.0,),
                          Text(formatDate(guest.guestVisitTime) + " " +
                              formatTime(guest.guestVisitTime),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.phone_android,
                            color: Colors.grey.shade800,
                            size: 16.0,
                          ),
                          SizedBox(width: 5.0,),
                          Text(guest.guestNoPhone,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.email,
                            color: Colors.grey.shade800,
                            size: 16.0,
                          ),
                          SizedBox(width: 5.0,),
                          Text(guest.guestEmail,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0,),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade800,
                            size: 16.0,
                          ),
                          SizedBox(width: 5.0,),
                          Text(guest.guestAddress,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listViewBuilder(BuildContext context, int index){
    GuestItem guest = _listGuest[index];
    return createGuestItem(guest);
  }

  void showGuestActivity(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestActivity(event: _event, guest: _guest,),
      ),
    ).then((value){
      if (value != null)
        setState(() {
          _refreshList();
        });
    });
  }

  void showDeleteDialog(GuestItem guest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus"),
          content: Text("Ingin menghapus tamu?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Ya"),
              onPressed: () {
                databaseProvider.open().then((value){
                  databaseProvider.deleteGuest(guest.guestId).then((event) {
                    Fluttertoast.showToast(
                        msg: "Tamu berhasil dihapus",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1
                    );
                    setState(() {
                      _listGuest.remove(event);
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
        child: Text("Belum ada tamu"),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName),
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
                  "Daftar Tamu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
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
                          future: databaseProvider.getListGuest(_event.eventId),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                _listGuest = snapshot.data;
                                databaseProvider.close();

                                if (_listGuest.length == 0){
                                  return _blank;
                                } else {
                                  return ListView.builder(
                                    itemCount: _listGuest.length,
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
        onPressed: (){
          setState(() {
            _guest = null;
            showGuestActivity();
          });
        },
        backgroundColor: Colors.brown.shade200,
        tooltip: 'Tambah Tamu',
        child: Icon(Icons.add_circle,
          color: Colors.black45,
        ),
      ),
    );
  }
}
