/// Dinh nghia loai giao dich: Thu nhap hoac Chi tieu
enum LoaiGiaoDich {
  thuNhap,
  chiTieu,
}

/// Lop mo hinh bieu dien thong tin mot giao dich chi tieu hoac thu nhap
class ModelGiaoDich {
  /// Ma dinh danh duy nhat cua giao dich (UUID)
  final String? maDinhDanh;

  /// Ma dinh danh nguoi dung so huu giao dich nay
  final String maNguoiDung;

  /// Tieu de hoac ten giao dich
  final String tieuDe;

  /// So tien giao dich (VND)
  final double soTien;

  /// Loai giao dich (Thu nhap hay Chi tieu)
  final LoaiGiaoDich loai;

  /// Danh muc giao dich (An uong, Mua sam, Luong, ...)
  final String danhMuc;

  /// Ngay thuc hien giao dich
  final DateTime ngay;

  /// Ghi chu them cho giao dich
  final String? ghiChu;

  /// Thoi gian tao ban ghi tren he thong
  final DateTime? ngayTao;

  ModelGiaoDich({
    this.maDinhDanh,
    required this.maNguoiDung,
    required this.tieuDe,
    required this.soTien,
    required this.loai,
    required this.danhMuc,
    required this.ngay,
    this.ghiChu,
    this.ngayTao,
  });

  /// Chuyen doi du lieu Map tu Supabase Database sang doi tuong ModelGiaoDich
  factory ModelGiaoDich.tuMap(Map<String, dynamic> map) {
    return ModelGiaoDich(
      maDinhDanh: map['id'] as String?,
      maNguoiDung: map['user_id'] as String? ?? '',
      tieuDe: map['title'] as String? ?? '',
      soTien: (map['amount'] as num?)?.toDouble() ?? 0.0,
      loai: map['type'] == 'income'
          ? LoaiGiaoDich.thuNhap
          : LoaiGiaoDich.chiTieu,
      danhMuc: map['category'] as String? ?? 'Khac',
      ngay: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      ghiChu: map['note'] as String?,
      ngayTao: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Chuyen doi doi tuong ModelGiaoDich sang dang Map de luu vao Supabase Database
  Map<String, dynamic> sangMap() {
    return {
      if (maDinhDanh != null) 'id': maDinhDanh,
      'user_id': maNguoiDung,
      'title': tieuDe,
      'amount': soTien,
      'type': loai == LoaiGiaoDich.thuNhap ? 'income' : 'expense',
      'category': danhMuc,
      'date': ngay.toIso8601String(),
      'note': ghiChu,
    };
  }
}
