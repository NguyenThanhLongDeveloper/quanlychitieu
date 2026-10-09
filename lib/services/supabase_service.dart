import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/transaction_model.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Authentication
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Transactions CRUD
  Future<List<TransactionModel>> getTransactions() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List)
        .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    final data = transaction.toMap();
    data['user_id'] = userId;

    await _client.from('transactions').insert(data);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;

    await _client
        .from('transactions')
        .update(transaction.toMap())
        .eq('id', transaction.id!);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }
}
