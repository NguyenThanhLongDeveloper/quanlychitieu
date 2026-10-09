import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabaseService = SupabaseService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String _filterType = 'all'; // 'all', 'income', 'expense'

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final list = await _supabaseService.getTransactions();
      if (mounted) {
        setState(() {
          _transactions = list;
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTransaction(String id) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      try {
        await _supabaseService.deleteTransaction(id);
        _loadTransactions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: ${e.toString()}')),
          );
        }
      }
    }
  }

  IconData _getCategoryIcon(String category, TransactionType type) {
    if (type == TransactionType.income) {
      switch (category) {
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
      switch (category) {
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
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    final filteredTransactions = _transactions.where((tx) {
      if (_filterType == 'income') return tx.type == TransactionType.income;
      if (_filterType == 'expense') return tx.type == TransactionType.expense;
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
              await _supabaseService.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: Column(
          children: [
            // Summary Card Header
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
                    currencyFormatter.format(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Thu nhập
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
                                        currencyFormatter.format(totalIncome),
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
                      // Chi tiêu
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
                                        currencyFormatter.format(totalExpense),
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

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _filterType == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterType = 'all');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Thu nhập'),
                    selected: _filterType == 'income',
                    selectedColor: Colors.green[100],
                    onSelected: (selected) {
                      if (selected) setState(() => _filterType = 'income');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Chi tiêu'),
                    selected: _filterType == 'expense',
                    selectedColor: Colors.red[100],
                    onSelected: (selected) {
                      if (selected) setState(() => _filterType = 'expense');
                    },
                  ),
                ],
              ),
            ),

            // Transaction List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có giao dịch nào.\nNhấn nút (+) để thêm mới!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = filteredTransactions[index];
                            final isIncome = tx.type == TransactionType.income;
                            final amountColor = isIncome ? Colors.green : Colors.red;
                            final amountPrefix = isIncome ? '+' : '-';

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
                                  child: Icon(
                                    _getCategoryIcon(tx.category, tx.type),
                                    color: amountColor,
                                  ),
                                ),
                                title: Text(
                                  tx.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${tx.category} • ${DateFormat('dd/MM/yyyy').format(tx.date)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$amountPrefix${currencyFormatter.format(tx.amount)}',
                                      style: TextStyle(
                                        color: amountColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                      onPressed: () {
                                        if (tx.id != null) {
                                          _deleteTransaction(tx.id!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTransactionScreen(transactionToEdit: tx),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadTransactions();
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (result == true) {
            _loadTransactions();
          }
        },
      ),
    );
  }
}
