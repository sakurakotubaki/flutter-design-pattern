import 'dart:convert';

import 'package:design_pattern/domain/user_api.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_api.g.dart';

@Riverpod(keepAlive: true)
UserAPIClient userApiClient(UserApiClientRef ref) {
  return UserAPIClient();
}

class UserAPIClient {
  final client = http.Client();

  Future<List<Profile>> getProfile () async {
    final response = await client.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final profile = data.map((json) => Profile.fromJson(json)).toList();
      // for文で、ネストしたクラスのデータを取得する
      for (var i = 0; i < profile.length; i++) {
        final address = data[i]['address'];
        profile[i] = profile[i].copyWith(
          address: Address.fromJson(address),
        );
      }
      return profile;
    } else {
      throw Exception('Failed to load profile');
    }
  }
}