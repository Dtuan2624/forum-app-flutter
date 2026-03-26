import 'package:flutter/material.dart';
import 'dart:math'; // Thư viện này để dùng hàm log tính toán

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Đã sửa thành CardThemeData để không bị lỗi compile
        cardTheme: const CardThemeData(elevation: 0),
        useMaterial3: true,
      ),
      home: const InterestCalculator(),
    );
  }
}

class InterestCalculator extends StatefulWidget {
  const InterestCalculator({super.key});

  @override
  State<InterestCalculator> createState() => _InterestCalculatorState();
}

class _InterestCalculatorState extends State<InterestCalculator> {
  // Controller để lấy dữ liệu từ các ô nhập
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  String _result = ""; // Biến lưu kết quả hiển thị

  // --- FUNCTION TÍNH TOÁN CHÍNH ---
  void _calculateInterest() {
    // 1. Lấy dữ liệu và ép kiểu
    double? rate = double.tryParse(_rateController.text);

    // 2. Kiểm tra điều kiện (lãi suất phải > 0 mới tính được thời gian gấp đôi)
    if (rate != null && rate > 0) {
      /* Công thức lãi kép chính xác:
         n = log(2) / log(1 + r)
      */
      double r = rate / 100; // Chuyển 8% thành 0.08
      double years = log(2) / log(1 + r);

      // 3. Cập nhật kết quả lên màn hình
      setState(() {
        _result = "${years.toStringAsFixed(1)} năm";
      });
    } else {
      setState(() {
        _result = "Nhập lãi > 0";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Máy tính lãi suất", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.grey[200],
        leading: const Icon(Icons.menu),
        actions: [
          const Icon(Icons.more_vert, color: Colors.black),
          const SizedBox(width: 10),
        ],
        // Đường kẻ đen dưới AppBar cho đúng style wireframe
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // Ô nhập số tiền
            _buildInputRow("Số tiền", _amountController),
            const SizedBox(height: 20),

            // Ô nhập lãi suất
            _buildInputRow("Lãi hàng năm", _rateController),
            const SizedBox(height: 30),

            // Dòng hiển thị kết quả "Số năm để tiền tăng gấp đôi"
            Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: Text(
                    "Số năm để tiền tăng gấp đôi",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Text(_result, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Nút Tính toán kiểu phác thảo (Wireframe) có đổ bóng
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _calculateInterest,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                    ],
                  ),
                  child: const Text(
                    "Tính toán",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget dùng chung cho các ô nhập liệu
  Widget _buildInputRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 45,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
