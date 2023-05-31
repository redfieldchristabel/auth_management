import 'dart:convert';

import 'package:auth_management/auth_management.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'example_user.g.dart';

@JsonSerializable()
@collection
class ExampleUser extends BaseUser {
  ExampleUser(
      {required super.id, required super.username, required super.email});

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory ExampleUser.fromJson(Map<String, dynamic> json) =>
      _$ExampleUserFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$ExampleUserToJson(this);

  String toJsonRaw() => json.encode(toJson());

  factory ExampleUser.fromJsonRaw(String source) =>
      ExampleUser.fromJson(json.decode(source));
}

@riverpod
ExampleUser? exampleUser(ExampleUserRef ref) {
  return ref.watch(userNotifierProvider) as ExampleUser?;
}
