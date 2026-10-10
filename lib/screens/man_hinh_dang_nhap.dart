import 'package:flutter/material.dart';
import '../services/dich_vu_supabase.dart';

/// Man hinh xu ly Dang nhap va Dang ky tai khoan nguoi dung
class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  State<ManHinhDangNhap> createState() => _TrangThaiManHinhDangNhap();
}

class _TrangThaiManHinhDangNhap extends State<ManHinhDangNhap> {
  final _boDieuKhienEmail = TextEditingController();
  final _boDieuKhienMatKhau = TextEditingController();
  final _dichVuSupabase = DichVuSupabase();

  bool _laDangNhap = true;
  bool _dangTai = false;

  @override
  void dispose() {
    _boDieuKhienEmail.dispose();
    _boDieuKhienMatKhau.dispose();
    super.dispose();
  }

  /// Xu ly gui bieu mau Dang nhap / Dang ky bang Email va Mat khau
  Future<void> _xuLyGui() async {
    final chuoiEmail = _boDieuKhienEmail.text.trim();
    final chuoiMatKhau = _boDieuKhienMatKhau.text.trim();

    if (chuoiEmail.isEmpty || chuoiMatKhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ email và mật khẩu')),
      );
      return;
    }

    setState(() => _dangTai = true);

    try {
      if (_laDangNhap) {
        await _dichVuSupabase.dangNhap(email: chuoiEmail, matKhau: chuoiMatKhau);
      } else {
        await _dichVuSupabase.dangKy(email: chuoiEmail, matKhau: chuoiMatKhau);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng kiểm tra email xác nhận nếu cần.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _dangTai = false);
      }
    }
  }

  /// Xu ly dang nhap nhanh bang tai khoan Google
  Future<void> _dangNhapGoogle() async {
    setState(() => _dangTai = true);
    try {
      await _dichVuSupabase.dangNhapBangGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng nhập Google: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _dangTai = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 80,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                Text(
                  _laDangNhap ? 'Đăng Nhập' : 'Tạo Tài Khoản',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _laDangNhap
                      ? 'Chào mừng bạn quay lại ứng dụng Quản lý chi tiêu'
                      : 'Bắt đầu quản lý tài chính cá nhân hiệu quả',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _boDieuKhienEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _boDieuKhienMatKhau,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _dangTai ? null : _xuLyGui,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _dangTai
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _laDangNhap ? 'Đăng nhập' : 'Đăng ký',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _laDangNhap = !_laDangNhap;
                    });
                  },
                  child: Text(
                    _laDangNhap
                        ? 'Chưa có tài khoản? Đăng ký ngay'
                        : 'Đã có tài khoản? Đăng nhập',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'HOẶC',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _dangTai ? null : _dangNhapGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                    height: 22,
                    width: 22,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                  ),
                  label: const Text(
                    'Đăng nhập bằng Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
