import 'package:supabase_flutter/supabase_flutter.dart';

/// Lop cau hinh va khoi tao ket noi toi Supabase backend
class CauHinhSupabase {
  /// Duong dan URL den du an Supabase
  static const String urlSupabase = 'https://qpmwtlwqbugykskvzcra.supabase.co';

  /// Chia khoa khoi tao khoi dau cong khai (Publishable Key / Anon Key)
  static const String khoaCongKhaiSupabase =
      'sb_publishable_yF9MWW66DdAX7XmBZ8uNRg_quAGvSNC';

  /// Web Client ID tu Google Cloud Console phuc vu chuc nang dang nhap Bang Google
  static const String idClientGoogleWeb =
      '614662946817-o8chpptsf0f3efbrrq8fla3hmbfahr6u.apps.googleusercontent.com';

  /// Ham khoi tao dich vu Supabase khi ung dung bat dau chay
  static Future<void> khoiTao() async {
    await Supabase.initialize(
      url: urlSupabase,
      publishableKey: khoaCongKhaiSupabase,
    );
  }

  /// Tra ve doi tuong Khach Hang Supabase Client de thao tac API
  static SupabaseClient get khachHang => Supabase.instance.client;
}
