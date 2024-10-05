import 'package:flutter/material.dart';
import 'package:flutter_database_sqllite/data/database/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allnotes = [];
  // ignore: non_constant_identifier_names
  Dbhelper? DbRef;

  @override
  void initState() {
    DbRef = Dbhelper.getinstance;
    getNotes();
    super.initState();
  }

  void getNotes() async {
    allnotes = await DbRef!.fatchNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: allnotes.isNotEmpty
          ? ListView.builder(
              itemCount: allnotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(
                    allnotes[index][Dbhelper.COLUMN_NOTE_TITLE],
                  ),
                  subtitle: Text(allnotes[index][Dbhelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * .22,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            bool? result = await showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => UpdateBottomSheetNotes(
                                noteId: allnotes[index][Dbhelper
                                    .COLUMN_NOTE_SNO], // Pass the note ID
                                currentTitle: allnotes[index][Dbhelper
                                    .COLUMN_NOTE_TITLE], // Pass the current title
                                currentDesc: allnotes[index][Dbhelper
                                    .COLUMN_NOTE_DESC], // Pass the current description
                              ),
                            );
                            if (result == true) {
                              getNotes(); // Refresh the notes list after updating
                            }
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: () async {
                              bool result = await DbRef!.deleteNote(
                                  Sno: allnotes[index]
                                      [Dbhelper.COLUMN_NOTE_SNO]);
                              if (result == true) {
                                getNotes();
                              }
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                );
              })
          : Center(child: Text('No notes yet!!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await showModalBottomSheet<bool>(
            context: context,
            builder: (_) => BottomSheetNotes(),
          );

          if (result == true) {
            getNotes();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class UpdateBottomSheetNotes extends StatefulWidget {
  final int noteId; // Note ID to update
  final String currentTitle; // Existing title of the note
  final String currentDesc; // Existing description of the note

  const UpdateBottomSheetNotes({
    super.key,
    required this.noteId,
    required this.currentTitle,
    required this.currentDesc,
  });

  @override
  State<UpdateBottomSheetNotes> createState() => _UpdateBottomSheetNotes();
}

class _UpdateBottomSheetNotes extends State<UpdateBottomSheetNotes> {
  late TextEditingController titleController;
  late TextEditingController descController;
  Dbhelper? DbRef;

  @override
  void initState() {
    DbRef = Dbhelper.getinstance;
    titleController = TextEditingController(
        text: widget.currentTitle); // Pre-fill with existing title
    descController = TextEditingController(
        text: widget.currentDesc); // Pre-fill with existing description
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Swidth = MediaQuery.of(context).size.width;
    var Sheight = MediaQuery.of(context).size.height;
    return Container(
      height: MediaQuery.of(context).size.height * .5 +
          MediaQuery.of(context).viewInsets.bottom,
      padding: EdgeInsets.only(
          top: Sheight * .03, left: Swidth * .03, right: Swidth * .03),
      width: Swidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Update Note',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: Sheight * .01,
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter Title',
              label: Text('Title'),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          SizedBox(
            height: Sheight * .01,
          ),
          TextField(
            textAlignVertical: TextAlignVertical.top,
            controller: descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter Description',
              label: Text('Desc'),
              alignLabelWithHint: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          SizedBox(
            height: Sheight * .02,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    var title = titleController.text;
                    var desc = descController.text;

                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check = await DbRef!.updateNote(
                        mtitle: title,
                        Sno: widget.noteId,
                        mDesc: desc,
                      );
                      if (check) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Note updated successfully!'),
                        ));

                        Navigator.pop(context, true);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please fill all text fields'),
                      ));
                    }
                  },
                  child: Text(' Update Note'),
                ),
              ),
              SizedBox(
                width: Swidth * .02,
              ),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomSheetNotes extends StatefulWidget {
  const BottomSheetNotes({
    super.key,
  });

  @override
  State<BottomSheetNotes> createState() => _BottomSheetNotesState();
}

class _BottomSheetNotesState extends State<BottomSheetNotes> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  Dbhelper? DbRef;

  @override
  void initState() {
    DbRef = Dbhelper.getinstance;
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Swidth = MediaQuery.of(context).size.width;
    var Sheight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.only(
          top: Sheight * .03, left: Swidth * .03, right: Swidth * .03),
      width: Swidth,
      child: Column(
        children: [
          Text(
            'Add notes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: Sheight * .01,
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter Title',
              label: Text('Title'),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          SizedBox(
            height: Sheight * .01,
          ),
          TextField(
            textAlignVertical: TextAlignVertical.top,
            controller: descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter Description',
              label: Text('Desc'),
              alignLabelWithHint: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          SizedBox(
            height: Sheight * .02,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    var title = titleController.text;
                    var desc = descController.text;

                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check =
                          await DbRef!.addnote(mTitle: title, mDesc: desc);
                      if (check) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Note added successfully!'),
                        ));

                        Navigator.pop(context, true);
                      }
                    } else {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please fill all text fields'),
                      ));
                    }
                  },
                  child: Text(' Add notes'),
                ),
              ),
              SizedBox(
                width: Swidth * .02,
              ),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
