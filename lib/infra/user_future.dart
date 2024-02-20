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