import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/giao_dich_model.dart';
import '../services/dich_vu_supabase.dart';
import 'man_hinh_them_giao_dich.dart';

/// Man hinh chinh Dashboard hien thi so du, thu chi va danh sach giao dich
class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  State<ManHinhChinh> createState() => _TrangThaiManHinhChinh();
}

class _TrangThaiManHinhChinh extends State<ManHinhChinh> {
  final _dichVuSupabase = DichVuSupabase();

  List<ModelGiaoDich> _danhSachGiaoDich = [];
  bool _dangTai = true;
  String _loaiLoc = 'tat_ca'; // 'tat_ca', 'thu_nhap', 'chi_tieu'

  @override
  void initState() {
    super.initState();
    _taiDanhSachGiaoDich();
  }

  /// Tai danh sach giao dich tu Supabase backend
  Future<void> _taiDanhSachGiaoDich() async {
    setState(() => _dangTai = true);
    try {
      final danhSach = await _dichVuSupabase.layDanhSachGiaoDich();
      if (mounted) {
        setState(() {
          _danhSachGiaoDich = danhSach;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _dangTai = false);
      }
    }
  }

  /// Xu ly xoa mot giao dich khi nguoi dung xac nhan
  Future<void> _xoaGiaoDich(String maDinhDanh) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (xacNhan == true) {
      try {
        await _dichVuSupabase.xoaGiaoDich(maDinhDanh);
        _taiDanhSachGiaoDich();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: ${e.toString()}')),
          );
        }
      }
    }
  }

  /// Lay bieu tuong Icon phu hop cho tung danh muc va loai giao dich
  IconData _layBieuTuongDanhMuc(String danhMuc, LoaiGiaoDich loai) {
    if (loai == LoaiGiaoDich.thuNhap) {
      switch (danhMuc) {
        case 'Lương':
          return Icons.payments;
        case 'Thưởng':
          return Icons.card_giftcard;
        case 'Đầu tư':
          return Icons.trending_up;
        case 'Bán hàng':
          return Icons.store;
        default:
          return Icons.account_balance_wallet;
      }
    } else {
      switch (danhMuc) {
        case 'Ăn uống':
          return Icons.restaurant;
        case 'Mua sắm':
          return Icons.shopping_bag;
        case 'Di chuyển':
          return Icons.directions_car;
        case 'Hóa đơn & Tiện ích':
          return Icons.receipt_long;
        case 'Giải trí':
          return Icons.sports_esports;
        case 'Sức khỏe':
          return Icons.medical_services;
        case 'Giáo dục':
          return Icons.school;
        default:
          return Icons.money_off;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dinhDangTien = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    double tongThuNhap = 0;
    double tongChiTieu = 0;

    for (var gd in _danhSachGiaoDich) {
      if (gd.loai == LoaiGiaoDich.thuNhap) {
        tongThuNhap += gd.soTien;
      } else {
        tongChiTieu += gd.soTien;
      }
    }

    final soDu = tongThuNhap - tongChiTieu;

    final danhSachDaLoc = _danhSachGiaoDich.where((gd) {
      if (_loaiLoc == 'thu_nhap') return gd.loai == LoaiGiaoDich.thuNhap;
      if (_loaiLoc == 'chi_tieu') return gd.loai == LoaiGiaoDich.chiTieu;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản Lý Chi Tiêu'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await _dichVuSupabase.dangXuat();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _taiDanhSachGiaoDich,
        child: Column(
          children: [
            // The tong quan Tai chinh
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Số dư khả dụng',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dinhDangTien.format(soDu),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Thu nhap
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.greenAccent,
                                child: Icon(Icons.arrow_downward, color: Colors.black87, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Thu nhập', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    FittedBox(
                                      child: Text(
                                        dinhDangTien.format(tongThuNhap),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Chi tieu
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.redAccent,
                                child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Chi tiêu', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    FittedBox(
                                      child: Text(
                                        dinhDangTien.format(tongChiTieu),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Cac Nut loc
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _loaiLoc == 'tat_ca',
                    onSelected: (duocChon) {
                      if (duocChon) setState(() => _loaiLoc = 'tat_ca');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Thu nhập'),
                    selected: _loaiLoc == 'thu_nhap',
                    selectedColor: Colors.green[100],
                    onSelected: (duocChon) {
                      if (duocChon) setState(() => _loaiLoc = 'thu_nhap');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Chi tiêu'),
                    selected: _loaiLoc == 'chi_tieu',
                    selectedColor: Colors.red[100],
                    onSelected: (duocChon) {
                      if (duocChon) setState(() => _loaiLoc = 'chi_tieu');
                    },
                  ),
                ],
              ),
            ),

            // Danh sach giao dich
            Expanded(
              child: _dangTai
                  ? const Center(child: CircularProgressIndicator())
                  : danhSachDaLoc.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có giao dịch nào.\nNhấn nút (+) để thêm mới!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: danhSachDaLoc.length,
                          itemBuilder: (context, chiSo) {
                            final gd = danhSachDaLoc[chiSo];
                            final laThuNhap = gd.loai == LoaiGiaoDich.thuNhap;
                            final mauSoTien = laThuNhap ? Colors.green : Colors.red;
                            final dauSoTien = laThuNhap ? '+' : '-';

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: laThuNhap ? Colors.green[50] : Colors.red[50],
                                  child: Icon(
                                    _layBieuTuongDanhMuc(gd.danhMuc, gd.loai),
                                    color: mauSoTien,
                                  ),
                                ),
                                title: Text(
                                  gd.tieuDe,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${gd.danhMuc} • ${DateFormat('dd/MM/yyyy').format(gd.ngay)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$dauSoTien${dinhDangTien.format(gd.soTien)}',
                                      style: TextStyle(
                                        color: mauSoTien,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                      onPressed: () {
                                        if (gd.maDinhDanh != null) {
                                          _xoaGiaoDich(gd.maDinhDanh!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  final ketQua = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ManHinhThemGiaoDich(giaoDichCanSua: gd),
                                    ),
                                  );
                                  if (ketQua == true) {
                                    _taiDanhSachGiaoDich();
                                  }
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final ketQua = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManHinhThemGiaoDich(),
            ),
          );
          if (ketQua == true) {
            _taiDanhSachGiaoDich();
          }
        },
      ),
    );
  }
}
