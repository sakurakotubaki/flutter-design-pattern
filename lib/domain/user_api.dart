import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user_api.freezed.dart';
part 'user_api.g.dart';

// APIからuser情報を取得する
@freezed
class Profile with _$Profile {
  const factory Profile({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String username,// apiの小文字なので、こちらも小文字にする
    @Default('') String email,
    Address? address,// 単一のオブジェクトなので、Address?型にする
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json)
      => _$ProfileFromJson(json);
}

// ネストしたクラスを作成して、address {} の中身を取得する
@freezed
class Address with _$Address {
  const factory Address({
    @Default('') String street,
    @Default('') String suite,
    @Default('') String city,
    @Default('') String zipcode,
  }) = _Address;

  factory Address.fromJson(Map<String, Object?> json)
      => _$AddressFromJson(json);
}