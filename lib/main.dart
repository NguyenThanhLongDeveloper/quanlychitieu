import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/cau_hinh_supabase.dart';
import 'screens/man_hinh_chinh.dart';
import 'screens/man_hinh_dang_nhap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CauHinhSupabase.khoiTao();
  runApp(const UngDungQuanLyChiTieu());
}

/// Lop ung dung chinh Quan Ly Chi Tieu
class UngDungQuanLyChiTieu extends StatelessWidget {
  const UngDungQuanLyChiTieu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final phienLamViec =
              snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
          if (phienLamViec != null) {
            return const ManHinhChinh();
          } else {
            return const ManHinhDangNhap();
          }
        },
      ),
    );
  }
}
