import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/giao_dich_model.dart';
import '../services/dich_vu_supabase.dart';

/// Man hinh bieu mau de Thêm moi hoac Chinh sua giao dich
class ManHinhThemGiaoDich extends StatefulWidget {
  final ModelGiaoDich? giaoDichCanSua;

  const ManHinhThemGiaoDich({super.key, this.giaoDichCanSua});

  @override
  State<ManHinhThemGiaoDich> createState() => _TrangThaiManHinhThemGiaoDich();
}

class _TrangThaiManHinhThemGiaoDich extends State<ManHinhThemGiaoDich> {
  final _khoaBieuMau = GlobalKey<FormState>();
  final _boDieuKhienTieuDe = TextEditingController();
  final _boDieuKhienSoTien = TextEditingController();
  final _boDieuKhienGhiChu = TextEditingController();
  final _dichVuSupabase = DichVuSupabase();

  LoaiGiaoDich _loaiGiaoDich = LoaiGiaoDich.chiTieu;
  String _danhMuc = 'Ăn uống';
  DateTime _ngayChon = DateTime.now();
  bool _dangTai = false;

  /// Danh sach danh muc phan chia theo loai giao dich
  final Map<LoaiGiaoDich, List<String>> _banDoDanhMuc = {
    LoaiGiaoDich.chiTieu: [
      'Ăn uống',
      'Mua sắm',
      'Di chuyển',
      'Hóa đơn & Tiện ích',
      'Giải trí',
      'Sức khỏe',
      'Giáo dục',
      'Khác',
    ],
    LoaiGiaoDich.thuNhap: [
      'Lương',
      'Thưởng',
      'Đầu tư',
      'Bán hàng',
      'Quà tặng',
      'Khác',
    ],
  };

  @override
  void initState() {
    super.initState();
    // Neu truyen vaogiaoDichCanSua thi dien thong tin cu de chinh sua
    if (widget.giaoDichCanSua != null) {
      final gd = widget.giaoDichCanSua!;
      _boDieuKhienTieuDe.text = gd.tieuDe;
      _boDieuKhienSoTien.text = gd.soTien.toStringAsFixed(0);
      _boDieuKhienGhiChu.text = gd.ghiChu ?? '';
      _loaiGiaoDich = gd.loai;
      _danhMuc = gd.danhMuc;
      _ngayChon = gd.ngay;
    }
  }

  @override
  void dispose() {
    _boDieuKhienTieuDe.dispose();
    _boDieuKhienSoTien.dispose();
    _boDieuKhienGhiChu.dispose();
    super.dispose();
  }

  /// Hiển thị hop thoai chon ngay
  Future<void> _chonNgay() async {
    final ngayDuocChon = await showDatePicker(
      context: context,
      initialDate: _ngayChon,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (ngayDuocChon != null) {
      setState(() {
        _ngayChon = ngayDuocChon;
      });
    }
  }

  /// Xu ly luu thông tin giao dịch vao co so du lieu
  Future<void> _luuGiaoDich() async {
    if (!_khoaBieuMau.currentState!.validate()) return;

    final maNguoiDung = _dichVuSupabase.nguoiDungHienTai?.id;
    if (maNguoiDung == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại.')),
      );
      return;
    }

    final soTienThuc = double.tryParse(_boDieuKhienSoTien.text.trim()) ?? 0.0;

    final doiTuongGiaoDich = ModelGiaoDich(
      maDinhDanh: widget.giaoDichCanSua?.maDinhDanh,
      maNguoiDung: maNguoiDung,
      tieuDe: _boDieuKhienTieuDe.text.trim(),
      soTien: soTienThuc,
      loai: _loaiGiaoDich,
      danhMuc: _danhMuc,
      ngay: _ngayChon,
      ghiChu: _boDieuKhienGhiChu.text.trim().isEmpty ? null : _boDieuKhienGhiChu.text.trim(),
    );

    setState(() => _dangTai = true);

    try {
      if (widget.giaoDichCanSua == null) {
        await _dichVuSupabase.themGiaoDich(doiTuongGiaoDich);
      } else {
        await _dichVuSupabase.capNhatGiaoDich(doiTuongGiaoDich);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu giao dịch: ${e.toString()}')),
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
    final danhSachDanhMucHienTai = _banDoDanhMuc[_loaiGiaoDich]!;
    if (!danhSachDanhMucHienTai.contains(_danhMuc)) {
      _danhMuc = danhSachDanhMucHienTai.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.giaoDichCanSua == null ? 'Thêm giao dịch' : 'Sửa giao dịch'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _khoaBieuMau,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nut chon loai: Chi tieu vs Thu nhap
                SegmentedButton<LoaiGiaoDich>(
                  segments: const [
                    ButtonSegment(
                      value: LoaiGiaoDich.chiTieu,
                      label: Text('Chi tiêu'),
                      icon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    ButtonSegment(
                      value: LoaiGiaoDich.thuNhap,
                      label: Text('Thu nhập'),
                      icon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  ],
                  selected: {_loaiGiaoDich},
                  onSelectionChanged: (Set<LoaiGiaoDich> luaChonMoi) {
                    setState(() {
                      _loaiGiaoDich = luaChonMoi.first;
                      _danhMuc = _banDoDanhMuc[_loaiGiaoDich]!.first;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Tieu de giao dich
                TextFormField(
                  controller: _boDieuKhienTieuDe,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề (VD: Bữa sáng, Lương tháng 5)',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (giaTri) =>
                      giaTri == null || giaTri.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),

                // So tien giao dich
                TextFormField(
                  controller: _boDieuKhienSoTien,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tiền (VNĐ)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (giaTri) {
                    if (giaTri == null || giaTri.trim().isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    if (double.tryParse(giaTri) == null) {
                      return 'Số tiền không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Danh muc giao dich
                DropdownButtonFormField<String>(
                  initialValue: _danhMuc,
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: danhSachDanhMucHienTai.map((danhMucItem) {
                    return DropdownMenuItem(
                      value: danhMucItem,
                      child: Text(danhMucItem),
                    );
                  }).toList(),
                  onChanged: (giaTriMoi) {
                    if (giaTriMoi != null) {
                      setState(() => _danhMuc = giaTriMoi);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Ngay giao dich
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.calendar_today, color: Colors.teal),
                  title: const Text('Ngày giao dịch'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_ngayChon)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _chonNgay,
                ),
                const SizedBox(height: 16),

                // Ghi chu them
                TextFormField(
                  controller: _boDieuKhienGhiChu,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú (Tùy chọn)',
                    prefixIcon: const Icon(Icons.notes),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nut Luu giao dich
                ElevatedButton(
                  onPressed: _dangTai ? null : _luuGiaoDich,
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
                      : const Text(
                          'Lưu giao dịch',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
