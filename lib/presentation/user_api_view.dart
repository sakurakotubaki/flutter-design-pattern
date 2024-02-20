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
