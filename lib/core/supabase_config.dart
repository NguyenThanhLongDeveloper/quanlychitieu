import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Thay thế bằng URL và Anon Key từ dự án Supabase của bạn
  // Bạn có thể tìm thấy các thông số này trong phần Settings > API của Supabase Dashboard
  static const String supabaseUrl = 'https://qpmwtlwqbugykskvzcra.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_yF9MWW66DdAX7XmBZ8uNRg_quAGvSNC';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
