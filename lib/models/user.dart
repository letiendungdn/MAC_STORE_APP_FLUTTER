import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.password,
  });

  // Serialization:Convert User Object to a Map
  // Map: A Map is a collection of key-value pairs
  // why: Coverting to a map is an intermediate step that makes it easier to serialize
  // the object to formates like Json for storage or transmission

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "email": email,
      "state": state,
      "city": city,
      "locality": locality,
      "password": password,
    };
  }

  // Serialization:Convert Map to a Json String
  // This method directly encodes the data from the Map into a Json String

  // The json.encode() function converts a Dart object (such as Map or List)
  // into a Json String reprensentation, making it suitable for communitation
  // between different systems.
  String toJson() => json.encode(toMap());
  // Deserialization: Convert a Map to a User Object
  // purpose - 
}
