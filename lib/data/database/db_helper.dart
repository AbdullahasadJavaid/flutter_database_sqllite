import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Dbhelper {
  //private constructer
  Dbhelper._();
  //geting the instance of dbheloper constructor
  static final Dbhelper getinstance = Dbhelper._();
  static final TABLE_NOTE = 'note';
  static final COLUMN_NOTE_SNO = 's_no';
  static final COLUMN_NOTE_TITLE = 'title';
  static final COLUMN_NOTE_DESC = 'desc';
  //globle variable for database
  Database? myDb;
//becouse it tank some it to open detadase so we use await or async
  Future<Database> getDB() async {
    //short form for checking the Database is not null if null then open database
    myDb ??= await openDb();
    return myDb!;
    //checking the data is not null if null then return mydb else its openDb
    // if (myDb != null) {
    //   return myDb!;
    // } else {
    //   myDb = await openDb();
    //   return myDb!;
    // }
  }

  Future<Database> openDb() async {
    //getting the pathDirectory
    Directory appDir = await getApplicationDocumentsDirectory();
    //getting dbpath j=and use join with database name and dirpath
    String dbPath = join(appDir.path, 'noteDB.db');
    return openDatabase(dbPath, onCreate: (db, version) {
      // create all tables here
      db.execute(
          "create table $TABLE_NOTE($COLUMN_NOTE_SNO integer primary key autoincrement,$COLUMN_NOTE_TITLE text,$COLUMN_NOTE_DESC text)");
    }, version: 1);
  }

//function for insert data in database
  Future<bool> addnote({required String mTitle, required String mDesc}) async {
    //get the database
    var db = await getDB();
    //use build in function for inseration
    int rowsEffected = await db.insert(
        //use table name with values map key pare
        TABLE_NOTE,
        {COLUMN_NOTE_TITLE: mTitle, COLUMN_NOTE_DESC: mDesc});
    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> fatchNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mydata = await db.query(TABLE_NOTE);
    return mydata;
  }

//update note
  Future<bool> updateNote(
      {required String mtitle, required String mDesc, required int Sno}) async {
    var db = await getDB();
    int rowEffected = await db.update(
        TABLE_NOTE, {COLUMN_NOTE_TITLE: mtitle, COLUMN_NOTE_DESC: mDesc},
        where: "$COLUMN_NOTE_SNO= $Sno");
    return rowEffected > 0;
  }

//delete note
  Future<bool> deleteNote({required int Sno}) async {
    var db = await getDB();
    int rowEffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$Sno']);
    return rowEffected > 0;
  }
}
