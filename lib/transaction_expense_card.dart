import 'package:flutter/material.dart';


class TransactionExpenseCard extends StatelessWidget {
  final String category;
  final String transactions;
  final String totalSpent;
  final String percentage;
  final Function() onTapEdit;

  TransactionExpenseCard({required this.category, required this.transactions, required this.totalSpent, required this.percentage, required this.onTapEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.purple[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Make the scroll horizontal
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the start
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Category and Percentage
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Truncate if too long
                        maxLines: 1, // Prevent wrapping to next line
                        softWrap: false, // Prevent wrapping
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          '${double.parse(percentage).toStringAsFixed(2)}%',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),

                // Transactions and Total Spent
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transactions:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$transactions'),
                      Text('Total Spent: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₱${double.parse(totalSpent).toStringAsFixed(2)}'),
                    ],
                  ),
                ),

                // Buttons (Edit/View)
                Column(
                  children: [
                    // View button
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () { /* Your edit action */ },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: InkWell(
                          onTap: onTapEdit,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFBBEDE), Color(0xFFFF82C4)],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: const Center(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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