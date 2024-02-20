# design_pattern
JsonPlaceholderから、APIのデータを取得するためのモデルを定義する。

こちらのJSONの構造に合わせる。

https://jsonplaceholder.typicode.com/users

ネストしたクラスになっているが、Addressは単一のオブジェクトなので、List<Address>にはしない。する場合は、[{}, {}, {}]といった感じで多次元配列になっている場合でしかしない。

```dart
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
```

REST APIと通信するクラスを定義する。Iteratorパターンで、for文を使って、ネストしたクラスからAPIのデータを取得する。`address`というkeyを指定して、繰り返し処理をしてデータを取得する。

```dart
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
```

FutureProviderを使用して非同期にデータを取得して、View側に状態を通知する。FutureBuilderを使うより短く処理が欠けるのでコードの記述量は減る。
```dart
import 'package:design_pattern/applicatoin/user_api.dart';
import 'package:design_pattern/domain/user_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_future.g.dart';

@riverpod
Future<List<Profile>> userFuture(UserFutureRef ref) async {
  try {
    return await ref.read(userApiClientProvider).getProfile();
  } on Exception catch (e) {
    throw Exception('api request error: $e');
  }
}
```

View側でデータを表示するには、`AsyncValue`のデータを`when`文を使用して、分岐処理を書いて表示する。
```dart
import 'package:design_pattern/infra/user_future.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserApiView extends ConsumerWidget {
  const UserApiView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userApiClientRef = ref.watch(userFutureProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpodでネストデータ取得'),
      ),
      body: userApiClientRef.when(
        data: (profile) {
          return ListView.builder(
            itemCount: profile.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(profile[index].address?.street ?? ''),
                subtitle: Text(profile[index].address?.city ?? ''),
              );
            },
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}
```

`main.dart`でimportして、ビルドすればAPIのデータを取得できます。
```dart
import 'package:design_pattern/presentation/user_api_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child:  MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserApiView(),
    );
  }
}
```