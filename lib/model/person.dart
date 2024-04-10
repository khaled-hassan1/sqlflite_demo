class Person {
  String id, title, description;

  Person({
    required this.id,
    required this.title,
    required this.description,
  });

  static Map<String, dynamic> toMap(Person person) {
    return {
      'id': person.id.toString(),
      'title': person.title,
      'description': person.description,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
