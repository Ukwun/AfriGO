import 'package:json_annotation/json_annotation.dart';

part 'user_data_model.g.dart';

@JsonSerializable()
class UserData {
  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;

  UserData({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
