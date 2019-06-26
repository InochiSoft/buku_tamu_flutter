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

/* Activity utama, untuk menampilkan daftar event/acara */
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

  /* Inisialisasi awal */
  @override
  void initState(){
    /* Memanggil metode createDefaultEvent */
    createDefaultEvent();

    super.initState();
    
    /* Memuat data pada ListView */
    _refreshList();
  }

  /* Metode untuk membuat event/acara otomatis
     saat tabel belum mempunyai satupun baris acara
  */
  void createDefaultEvent(){
    /* Membuka koneksi ke database */
    databaseProvider.open().then((_){
      /* Memanggil fungsi getListEvent untuk mengoleksi daftar event */
      databaseProvider.getListEvent().then((list){
        if (list != null){
          /* Ketika daftar event kosong */
          if (list.length == 0){
            /* Membuat event baru */
            EventItem eventDef = new EventItem();

            eventDef.eventName = "Perkawinan Jang Karim dan Nyi Imas";
            eventDef.eventAddress = "Garut";
            eventDef.isCompleted = 0;

            int currTime = DateTime.now().millisecondsSinceEpoch;

            eventDef.eventDate = currTime;
            eventDef.eventTime = currTime;
            eventDef.createDate = currTime;

            /* Memasukan event baru ke tabel */
            databaseProvider.insertEvent(eventDef).then((event) {
              /* Menutup database setelah proses input */
              databaseProvider.close();
            });
          }
        }
      });
    });
  }

  /* Metode untuk memuat ulang daftar event */
  void _refreshList() {
    /* Membuka database */
    databaseProvider.open().then((_){
      /* Memanggil fungsi getListEvent untuk mengambil daftar event */
      databaseProvider.getListEvent().then((list){
        if (list != null){
          /* Memperbarui variabel _listEvent */
          setState(() {
            _listEvent = list;
          });
          /* Menutup database */
          databaseProvider.close();
        }
      });
    });
  }

  /* Fungsi untuk mengonversi angka di bawah 10 menjadi 2 digit.
     Misalnya: 01, 02, 03, dst sampai 09
  */
  String sprintF(var number){
    return number.toString().padLeft(2, "0");
  }

  /* Mengonversi millisecond (unix time) menjadi format tanggal.
     Misalnya: 22 Januari 2019
  */
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

  /* Mengonversi millisecond (unix time) menjadi format waktu.
     Misalnya: 23:59
  */
  String formatTime(int millis){
    if (millis != null){
      var date = new DateTime.fromMillisecondsSinceEpoch(millis);
      int hour = date.hour;
      int minute = date.minute;

      return sprintF(hour) + ":" + sprintF(minute);
    }
    return '';
  }

  /* Fungsi untuk membuat widget item dari ListView */
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
          /* Saat baris widget ditap */
          onTap: () {
            /* Simpan nilai event pada variabel _event */
            setState(() {
              _event = event;
            });
            /* Memanggil GuestsActivity */
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
                        /* Saat tombol edit (pensil) ditap */
                        onTap: (){
                          /* Simpan nilai event pada variabel _event */
                          setState(() {
                            _event = event;
                          });
                          /* Memanggil EventActivity untuk pengeditan event */
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
                        /* Saat tombol hapus (tong sampah) ditap */
                        onTap: (){
                          if (_listEvent.length > 0){
                            /* Simpan nilai event pada variabel _event */
                            setState(() {
                              _event = event;
                            });
                            /* Menampilkan dialog konfirmasi penghaspusan */
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

  /* Fungsi untuk membangun daftar item dari ListView */
  Widget listViewBuilder(BuildContext context, int index){
    EventItem event = _listEvent[index];
    return createEventItem(event);
  }

  /* Metode untuk menampilkan EventActivity */
  void showEventActivity(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventActivity(event: _event,),
      ),
    ).then((value){
      /* memuat ulang ListView saat MainActivity tampil kembali */
      if (value != null)
      setState(() {
        _refreshList();
      });
    });
  }

  /* Metode untuk menampilkan GuestsActivity */
  void showGuestsActivity(){
    Navigator.push(
      context,
      MaterialPageRoute(
        /* Memangil GuestsActivity sambil mengirim obyek _event */
        builder: (context) => GuestsActivity(event: _event,),
      ),
    );
  }

  /* Metode untuk menampilkan dialog konfirmasi penghapusan event */
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
              /* Saat mengetap/mengklik tombol Ya pada dialog */
              onPressed: () {
                /* Membuka database */
                databaseProvider.open().then((value){
                  /* Menghapus event dari database */
                  databaseProvider.deleteEvent(_event.eventId).then((event) {
                    /* Menampilkan Toast setelah penghapusan */
                    Fluttertoast.showToast(
                        msg: "Acara berhasil dihapus",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1
                    );
                    /* Menghapus item event dari _listEvent.
                       Menggunakan setState agar item-item pada
                       _listEvent diperbarui sehingga daftar item
                       pada ListView ikut diperbarui
                    */
                    setState(() {
                      _listEvent.remove(event);
                    });
                    /* Menutup database */
                    databaseProvider.close();
                    /* Menutup dialog */
                    Navigator.of(context).pop();
                  });
                });
              },
            ),
            FlatButton(
              child: Text("Tidak"),
              /* Saat mengetap/mengklik tombol Tidak pada dialog */
              onPressed: () {
                /* Menutup dialog */
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
            /* Memuat data pada ListView saat tombol Refresh ditap */
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
                  /* Menggunakan FutureBuilder untuk mengakses database */
                  child: FutureBuilder(
                    future: databaseProvider.open(),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      /* Saat koneksi ke database berhasil terhubung */
                      if (snapshot.connectionState == ConnectionState.done) {
                        return FutureBuilder(
                          /* Menggunakan FutureBuilder untuk mengambil daftar event */
                          future: databaseProvider.getListEvent(),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            /* Saat pemanggilan fungsi mendapatkan data */
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                /* Mengisi variabel _listEvent dari data snapshot */
                                _listEvent = snapshot.data;
                                databaseProvider.close();

                                /* Saat _listEvent kosong */
                                if (_listEvent.length == 0){
                                  /* Tampilkan widget _blank */
                                  return _blank;

                                /* Saat _listEvent tidak kosong */
                                } else {
                                  /* Bangun widget ListView */
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
        /* Saat FloatingActionButton ditap */
        onPressed:(){
          /* Null-kan nilai _event */
          setState(() {
            _event = null;
          });
          /* Memanggil EventActivity */
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
