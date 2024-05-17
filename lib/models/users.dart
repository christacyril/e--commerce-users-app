import 'package:json_annotation/json_annotation.dart';
part 'users.g.dart';


@JsonSerializable()
class Users{
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "number")
  int? number;



  Users({
    this.id,
    this.name,
    this.number,
});

  factory Users.fromJson(Map<String, dynamic>json) => _$UsersFromJson(json);

  Map<String, dynamic> toJson() => _$UsersToJson(this);


}