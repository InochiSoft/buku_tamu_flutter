import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

var tableEvent = 'tblEvent';
var tableGuest = 'tblGuest';

class DatabaseProvider {
  Database database;

  /* Fungsi untuk membuka kelas database */
  Future open() async {
    var databasesPath = await getDatabasesPath();
    /* Menentukan nama dan alamat database */
    String path = join(databasesPath, 'guest_book.db');

    /* Membuka database */
    database = await openDatabase(path, version: 1,
      /* Membuat tabel bila belum terdapat tabel pada database */
      onCreate: (Database db, int version) async {
        /* Membangun query pembuatan tabel tblEvent */
        String sqlTableEvent = "CREATE TABLE $tableEvent (";
        for (var i = 0; i < eventColumns.length; i++){
          ColumnItem columnItem = eventColumns[i];
          sqlTableEvent += columnItem.name + " " + columnItem.type + " " + columnItem.extra;
          if (i < (eventColumns.length - 1)){
            sqlTableEvent += ",";
          }
        }
        sqlTableEvent += ");";

        /* Membuat query pembuatan indeks pada table tblEvent */
        String indexTableEvent = " CREATE INDEX idx_" + tableEvent + "_" +
            "row_event" + " ON " + tableEvent + " (" +  eventColumns[0].name + ");";

        /* Membangun query pembuatan tabel tblGuest */
        String sqlTableGuest = "CREATE TABLE $tableGuest (";
        for (var i = 0; i < guestColumns.length; i++){
          ColumnItem columnItem = guestColumns[i];
          sqlTableGuest += columnItem.name + " " + columnItem.type + " " + columnItem.extra;
          if (i < (guestColumns.length - 1)){
            sqlTableGuest += ",";
          }
        }
        sqlTableGuest += ");";

        /* Membuat query pembuatan indeks pada table tblGuest */
        String indexTableGuest = " CREATE INDEX idx_" + tableGuest + "_" +
            "row_guest" + " ON " + tableGuest + " (" + guestColumns[0].name + "," + guestColumns[1].name + ");";

        /* Mengeksekusi query pembuatan tabel-tabel */
        db.execute(sqlTableEvent);
        db.execute(indexTableEvent);
        db.execute(sqlTableGuest);
        db.execute(indexTableGuest);
      },
    );
  }

  /* Fungsi untuk menutup kelas database */
  Future close() async => database.close();

  /* Fungsi untuk menambah baris ke tabel tblEvent */
  Future<EventItem> insertEvent(EventItem event) async {
    event.eventId = await database.insert(tableEvent, event.toMapInsert());
    return event;
  }

  /* Fungsi untuk menghapus baris di tabel tblEvent */
  Future<int> deleteEvent(int id) async {
    return await database.delete(tableEvent, where: eventColumns[0].name + ' = ?', whereArgs: [id]);
  }

  /* Fungsi untuk memperbarui baris di tabel tblEvent */
  Future<int> updateEvent(EventItem event) async {
    return await database.update(tableEvent, event.toMap(),
        where: eventColumns[0].name + ' = ?', whereArgs: [event.eventId]);
  }

  /* Fungsi untuk mengambil baris di tabel tblEvent */
  Future<EventItem> getEvent(int id) async {
    List<Map> maps = await database.query(tableEvent,
        columns: getColumnsName(eventColumns),
        where: eventColumns[0].name + ' = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return EventItem.fromMap(maps.first);
    }
    return null;
  }

  /* Fungsi untuk mengambil daftar baris di tabel tblEvent */
  Future<List<EventItem>> getListEvent() async {
    List<Map> maps = await database.query(tableEvent,
        columns: getColumnsName(eventColumns)
    );
    List<EventItem> listEvent = List();
    if (maps.length > 0) {
      for (Map map in maps) {
        EventItem event = EventItem.fromMap(map);
        listEvent.add(event);
      }
      return listEvent;
    }
    return listEvent;
  }

  /* Fungsi untuk menambah baris ke tabel tblGuest */
  Future<GuestItem> insertGuest(GuestItem guest) async {
    guest.guestId = await database.insert(tableGuest, guest.toMapInsert());
    return guest;
  }

  /* Fungsi untuk menghapus baris di tabel tblGuest */
  Future<int> deleteGuest(int id) async {
    return await database.delete(tableGuest, where: guestColumns[0].name + ' = ?', whereArgs: [id]);
  }

  /* Fungsi untuk memperbarui baris ke tabel tblGuest */
  Future<int> updateGuest(GuestItem guest) async {
    return await database.update(tableGuest, guest.toMap(),
        where: guestColumns[0].name + ' = ?', whereArgs: [guest.guestId]);
  }

  /* Fungsi untuk mengambil baris di tabel tblGuest */
  Future<GuestItem> getGuest(int id) async {
    List<Map> maps = await database.query(tableGuest,
        columns: getColumnsName(guestColumns),
        where: guestColumns[0].name + ' = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return GuestItem.fromMap(maps.first);
    }
    return null;
  }

  /* Fungsi untuk mengambil daftar baris di tabel tblGuest berdasarkan eventId */
  Future<List<GuestItem>> getListGuest(int eventId) async {
    List<Map> maps = await database.query(tableGuest,
      columns: getColumnsName(guestColumns),
      where: guestColumns[1].name + " = ? ",
      whereArgs: [eventId]
    );
    List<GuestItem> listGuest = List();
    if (maps.length > 0) {
      for (Map map in maps) {
        GuestItem guest = GuestItem.fromMap(map);
        listGuest.add(guest);
      }
      return listGuest;
    }
    return listGuest;
  }

}