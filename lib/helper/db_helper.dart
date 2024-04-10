import 'package:sqlite_demo/db.dart';
import 'package:sqlite_demo/model/person.dart';

class DBHelper extends SqfliteDatabase {
  Future<List<Person>> getAllPersons() async {
    List<Person> persons = [];
    String sql = "SELECT * FROM person";
    List<Map<String, dynamic>> map = await query(sql);
    for (var i = 0; i < map.length; i++) {
      persons.add(Person.fromMap(map[i]));
    }
    return persons;
  }

  Future<int> insertNewPerson(Person person) async {
    String sql = "INSERT INTO person (title, description) VALUES (?, ?)";
    int result = await insert(sql, [person.title, person.description]);
    return result;
  }
}
