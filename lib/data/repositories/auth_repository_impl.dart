import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart' as entity;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource _remote;
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._remote, this._supabaseClient);

  @override
  Future<entity.User> signIn({
    required String email,
    required String password,
  }) async {
    return _remote.signIn(email: email, password: password);
  }

  @override
  Future<entity.User> signUp({
    required String email,
    required String password,
  }) async {
    return _remote.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _remote.signOut();
  }

  @override
  Future<entity.User?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return entity.User(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  @override
  Stream<entity.User?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return entity.User(
        id: user.id,
        email: user.email ?? '',
        createdAt: DateTime.parse(user.createdAt),
      );
    });
  }
}
