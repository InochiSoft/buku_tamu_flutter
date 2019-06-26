import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model.dart';
import 'database.dart';
import 'guest.dart';

/* Activity  untuk menampilkan daftar guest/tamu */
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

  /* Inisialisasi awal */
  @override
  void initState(){
    /* Mengambil nilai widget.event yang dikirim Navigator
       dan mengisikan ke variabel _event
    */
    _event = widget.event;
    super.initState();
  }

  /* Metode untuk memuat ulang daftar guest */
  void _refreshList() {
    /* Membuka database */
    databaseProvider.open().then((_){
      /* Memanggil fungsi getListGuest untuk mengambil daftar guest
         berdasarkan eventId dari _event
      */
      databaseProvider.getListGuest(_event.eventId).then((list){
        if (list != null){
          /* Memperbarui variabel _listGuest */
          setState(() {
            _listGuest = list;
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
     Misalnya: 24 Maret 2019
  */
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

  /* Mengonversi millisecond (unix time) menjadi format waktu.
     Misalnya: 08:09
  */
  String formatTime(int millis){
    var date = new DateTime.fromMillisecondsSinceEpoch(millis);
    int hour = date.hour;
    int minute = date.minute;

    return sprintF(hour) + ":" + sprintF(minute);
  }

  /* Fungsi untuk membuat widget item dari ListView */
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
          /* Saat baris widget ditap */
          onTap: () {
            /* Simpan nilai guest pada variabel _guest */
            setState(() {
              _guest = guest;
            });
            /* Memanggil GuestsActivity untuk pengeditan guest */
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
                            /* Saat tombol hapus (tong sampah) ditap */
                            onTap: (){
                              if (_listGuest.length > 0){
                                /* Simpan nilai guest pada variabel _guest */
                                setState(() {
                                  _guest = guest;
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

  /* Fungsi untuk membangun daftar item dari ListView */
  Widget listViewBuilder(BuildContext context, int index){
    GuestItem guest = _listGuest[index];
    return createGuestItem(guest);
  }

  /* Metode untuk menampilkan GuestActivity */
  void showGuestActivity(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestActivity(event: _event, guest: _guest,),
      ),
    ).then((value){
      /* memuat ulang ListView saat GuestsActivity tampil kembali */
      if (value != null)
        setState(() {
          _refreshList();
        });
    });
  }

  /* Metode untuk menampilkan dialog konfirmasi penghapusan guest */
  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus"),
          content: Text("Ingin menghapus tamu?"),
          actions: <Widget>[
            FlatButton(
              /* Saat mengetap/mengklik tombol Ya pada dialog */
              child: Text("Ya"),
              onPressed: () {
                /* Membuka database */
                databaseProvider.open().then((value){
                  /* Menghapus guest dari database */
                  databaseProvider.deleteGuest(_guest.guestId).then((guest) {
                    /* Menampilkan Toast setelah penghapusan */
                    Fluttertoast.showToast(
                        msg: "Tamu berhasil dihapus",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1
                    );
                    /* Menghapus item guest dari _listGuest.
                       Menggunakan setState agar item-item pada
                       _listGuest diperbarui sehingga daftar item
                       pada ListView ikut diperbarui
                    */
                    setState(() {
                      _listGuest.remove(guest);
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
                  /* Menggunakan FutureBuilder untuk mengakses database */
                  child: FutureBuilder(
                    future: databaseProvider.open(),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      /* Saat koneksi ke database berhasil terhubung */
                      if (snapshot.connectionState == ConnectionState.done) {
                        /* Menggunakan FutureBuilder untuk mengambil daftar guest */
                        return FutureBuilder(
                          future: databaseProvider.getListGuest(_event.eventId),
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            /* Saat pemanggilan fungsi mendapatkan data */
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                /* Mengisi variabel _listGuest dari data snapshot */
                                _listGuest = snapshot.data;
                                databaseProvider.close();

                                /* Saat _listEvent kosong */
                                if (_listGuest.length == 0){
                                  /* Tampilkan widget _blank */
                                  return _blank;

                                /* Saat _listGuest tidak kosong */
                                } else {
                                  /* Bangun widget ListView */
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
        /* Saat FloatingActionButton ditap */
        onPressed: (){
          setState(() {
            /* Null-kan nilai _guest */
            _guest = null;
            /* Memanggil GuestActivity */
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
