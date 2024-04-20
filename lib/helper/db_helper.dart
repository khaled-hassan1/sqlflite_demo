// import 'package:sqlite_demo/helper/db.dart';
// import 'package:sqlite_demo/model/person.dart';

// class DBHelper extends SqfliteDatabase {
//   Future<List<Person>> getAllPersons() async {
//     List<Person> persons = [];
//     List<Map<String, dynamic>> fetechData = await query('person');
//     for (var map in fetechData) {
//       persons.add(Person.fromMap(map));
//     }
//     return persons;
//   }

//   Future<int> insertNewPerson(Person person) async {
//     return await insert('person', person);
//   }
//   Future<int> updatePerson(Person person ,String id) async {
//     return await update('person', Person.toMap(person), id);
//   }

//   Future<int> deletePerson(String id) async {
//     return await delete('person', id);
//   }

// Future<void> close() async {
//   return await delete.close();
// }
// }
import 'package:sqlite_demo/helper/db.dart';
import 'package:sqlite_demo/model/person.dart';

class DBHelper {
  final SqfliteDatabase _sqfliteDatabase = SqfliteDatabase();

  Future<List<Person>> getAllPersons() async {
    List<Person> persons = [];
    List<Map<String, dynamic>> fetechData =
        await _sqfliteDatabase.query('person');
    for (var map in fetechData) {
      persons.add(Person.fromMap(map));
    }
    return persons;
  }

  Future<int> insertNewPerson(Person person) async {
    return await _sqfliteDatabase.insert('person', person);
  }

  Future<int> updatePerson(Person person, String id) async {
    return await _sqfliteDatabase.update('person', Person.toMap(person), id);
  }

  Future<int> deletePerson(String id) async {
    return await _sqfliteDatabase.delete('person', id);
  }

  Future<void> close() async {
    await _sqfliteDatabase.close();
  }
}
