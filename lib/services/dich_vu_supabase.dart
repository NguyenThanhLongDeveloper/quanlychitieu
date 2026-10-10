import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/cau_hinh_supabase.dart';
import '../models/giao_dich_model.dart';

/// Lop xu ly tat ca cac thao tac API va xac thuc voi Supabase
class DichVuSupabase {
  final SupabaseClient _khachHang = CauHinhSupabase.khachHang;

  /// Lay thong tin nguoi dung hien tai dang dang nhap
  User? get nguoiDungHienTai => _khachHang.auth.currentUser;

  /// Luong theo doi thay doi trang thai xac thuc nguoi dung (Dang nhap / Dang xuat)
  Stream<AuthState> get luongTrangThaiXacThuc => _khachHang.auth.onAuthStateChange;

  /// Dang ky tai khoan moi bang Email va Mat khau
  Future<AuthResponse> dangKy({
    required String email,
    required String matKhau,
  }) async {
    return await _khachHang.auth.signUp(
      email: email,
      password: matKhau,
    );
  }

  /// Dang nhap tai khoan bang Email va Mat khau
  Future<AuthResponse> dangNhap({
    required String email,
    required String matKhau,
  }) async {
    return await _khachHang.auth.signInWithPassword(
      email: email,
      password: matKhau,
    );
  }

  /// Dang nhap truc tiep bang tai khoan Google (Gmail)
  Future<bool> dangNhapBangGoogle() async {
    try {
      final idClientWeb = CauHinhSupabase.idClientGoogleWeb;
      final GoogleSignIn boDangNhapGoogle = GoogleSignIn(
        serverClientId: idClientWeb.isNotEmpty ? idClientWeb : null,
      );

      final nguoiDungGoogle = await boDangNhapGoogle.signIn();
      if (nguoiDungGoogle == null) {
        // Nguoi dung bam huy dang nhap
        return false;
      }

      final xacThucGoogle = await nguoiDungGoogle.authentication;
      final chuoiMappAccessToken = xacThucGoogle.accessToken;
      final chuoiIdToken = xacThucGoogle.idToken;

      if (chuoiIdToken == null) {
        throw Exception('Khong nhan duoc Google ID Token.');
      }

      await _khachHang.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: chuoiIdToken,
        accessToken: chuoiMappAccessToken,
      );

      return true;
    } catch (e) {
      // Truong hop chuyen huong sang trinh duyet OAuth
      return await _khachHang.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.quanlychitieu://login-callback/',
      );
    }
  }

  /// Dang xuat khoi he thong
  Future<void> dangXuat() async {
    try {
      final GoogleSignIn boDangNhapGoogle = GoogleSignIn();
      if (await boDangNhapGoogle.isSignedIn()) {
        await boDangNhapGoogle.signOut();
      }
    } catch (_) {}
    await _khachHang.auth.signOut();
  }

  /// Lay danh sach tat ca giao dich cua nguoi dung hien tai
  Future<List<ModelGiaoDich>> layDanhSachGiaoDich() async {
    final maNguoiDung = nguoiDungHienTai?.id;
    if (maNguoiDung == null) return [];

    final phanHoi = await _khachHang
        .from('transactions')
        .select()
        .eq('user_id', maNguoiDung)
        .order('date', ascending: false);

    return (phanHoi as List)
        .map((e) => ModelGiaoDich.tuMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Them mot giao dich moi vao co so du lieu
  Future<void> themGiaoDich(ModelGiaoDich giaoDich) async {
    final maNguoiDung = nguoiDungHienTai?.id;
    if (maNguoiDung == null) throw Exception('Nguoi dung chua dang nhap');

    final duLieu = giaoDich.sangMap();
    duLieu['user_id'] = maNguoiDung;

    await _khachHang.from('transactions').insert(duLieu);
  }

  /// Cap nhat thong tin mot giao dich da co
  Future<void> capNhatGiaoDich(ModelGiaoDich giaoDich) async {
    if (giaoDich.maDinhDanh == null) return;

    await _khachHang
        .from('transactions')
        .update(giaoDich.sangMap())
        .eq('id', giaoDich.maDinhDanh!);
  }

  /// Xoa mot giao dich khoi co so du lieu theo ma dinh danh
  Future<void> xoaGiaoDich(String maDinhDanh) async {
    await _khachHang.from('transactions').delete().eq('id', maDinhDanh);
  }
}
