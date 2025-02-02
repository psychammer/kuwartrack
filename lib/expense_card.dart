import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String category;
  final String transactions;
  final String totalSpent;
  final String percentage;

  ExpenseCard({required this.category, required this.transactions, required this.totalSpent, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? Colors.black : Colors.purple[100]!;
    final Color primaryTextColor = isDark ? const Color(0xFFAE60CC) : Colors.black;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded( 
              child: Text(
                category,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                overflow: TextOverflow.ellipsis, // Truncate if too long
                maxLines: 1, // Keep it in a single line
                softWrap: false, // Prevents wrapping to the next line
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('Transactions: $transactions', style: TextStyle(color: primaryTextColor)),
                          Text('Total Spent: ₱${double.parse(totalSpent).toStringAsFixed(2)}', style: TextStyle(color: primaryTextColor))]),
            ),
            Expanded(
              child: Padding(padding: EdgeInsets.only(left: 20),child: Text('${double.parse(percentage).toStringAsFixed(2)}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor))),
            )
        ]),
      ),
    );
  }
}

// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// ,
// ,
// Align(
// alignment: Alignment.centerRight,
// child: ,
// ),
// ],
// )