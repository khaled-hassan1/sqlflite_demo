import 'package:flutter/material.dart';

import '../helper/db_helper.dart';
import '../model/person.dart';

class ListNotes extends StatefulWidget {
  final List<Person> persons;
  const ListNotes({super.key, required this.persons});

  @override
  State<ListNotes> createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {



  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: widget.persons.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(widget.persons[index].title),
            subtitle: Text(widget.persons[index].description),
            leading: const Icon(Icons.person),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  widget.persons.removeAt(index);
                });
              },
            ),

          ),
        );
      },
    );
  }

  
  }

