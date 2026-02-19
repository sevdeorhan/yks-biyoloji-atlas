import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as entity;
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseDataSourceProvider = Provider<SupabaseDataSource>((ref) {
  return SupabaseDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    ref.watch(supabaseDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
});

final authStateProvider = StreamProvider<entity.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<entity.User?>((ref) async {
  return ref.watch(authRepositoryProvider).getCurrentUser();
});
