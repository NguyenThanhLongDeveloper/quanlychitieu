import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _supabaseService = SupabaseService();

  TransactionType _type = TransactionType.expense;
  String _category = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final Map<TransactionType, List<String>> _categoriesMap = {
    TransactionType.expense: [
      'Ăn uống',
      'Mua sắm',
      'Di chuyển',
      'Hóa đơn & Tiện ích',
      'Giải trí',
      'Sức khỏe',
      'Giáo dục',
      'Khác',
    ],
    TransactionType.income: [
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
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      _type = tx.type;
      _category = tx.category;
      _selectedDate = tx.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _supabaseService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại.')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    final transaction = TransactionModel(
      id: widget.transactionToEdit?.id,
      userId: userId,
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    setState(() => _isLoading = true);

    try {
      if (widget.transactionToEdit == null) {
        await _supabaseService.addTransaction(transaction);
      } else {
        await _supabaseService.updateTransaction(transaction);
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = _categoriesMap[_type]!;
    if (!availableCategories.contains(_category)) {
      _category = availableCategories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'Thêm giao dịch' : 'Sửa giao dịch'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented control: Chi tiêu vs Thu nhập
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Chi tiêu'),
                      icon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Thu nhập'),
                      icon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                      _category = _categoriesMap[_type]!.first;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề (VD: Bữa sáng, Lương tháng 5)',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),

                // Số tiền
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tiền (VNĐ)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Số tiền không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Danh mục
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: availableCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _category = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Ngày giao dịch
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.calendar_today, color: Colors.teal),
                  title: const Text('Ngày giao dịch'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                // Ghi chú
                TextFormField(
                  controller: _noteController,
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

                // Nút Lưu
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
