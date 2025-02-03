import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart'; // Import for date formatting and parsing
import 'package:kuwartrack/transaction_expense_card.dart';
import 'package:kuwartrack/expense_class.dart';


class Edit extends StatefulWidget {
  final Expenses expenses;
  final List<Expense> expense_list;
  final String user_id;

  const Edit({super.key, required this.expenses, required this.expense_list, required this.user_id});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  late Expenses general_expenses_data;
  late List<Expense> expense_list_category_data;
  late Expenses expenses_data_category;
  late Expense sample_data;
  late DateTime date;
  late String date_formatted;
  late double totalSpentCategory;
  Map<String, double> all_category_total_expenses = {};
  late double overallTotal;
  int transactions = 0;
  double todayBudget = 0;
  String percentage = '0';
  late String user_id_data;
  late String category_name;



  @override void initState() {
    // TODO: implement initState
    super.initState();

    expense_list_category_data = widget.expense_list;
    general_expenses_data = widget.expenses;
    expenses_data_category = Expenses(expense_list_category_data);
    if(expense_list_category_data.isNotEmpty){
      user_id_data = widget.user_id;
      sample_data = expense_list_category_data.first;
      category_name = sample_data.category;
      date = DateTime.parse(sample_data.date);
      date_formatted = DateFormat('MMMM dd, yyyy').format(date);
      all_category_total_expenses= general_expenses_data.getTotalExpensesForAllCategoriesInSpecificDate(date);
      overallTotal = all_category_total_expenses.values.fold(0, (accumulator, element) => accumulator + element);
      percentage = general_expenses_data.getCategoryPercentagesForCategoryOnSpecificDate(category_name, sample_data.date).toStringAsFixed(2);
      totalSpentCategory = expense_list_category_data.fold(0, (sum, expense) => sum + (double.tryParse(expense.money_spent) ?? 0));
    }

  }

  // Get data request
  Future<List<Expense>> get_data(String user_id) async {
    final url = Uri.parse("https://206e-110-235-154-222.ngrok-free.app/api/auth/post_data");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": user_id}),
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body) != null) {
        // Decoding the JSON response
        final decodedResponse = jsonDecode(response.body) as List<dynamic>;
        final expenses = decodedResponse.map((expense) => Expense(
          expense[0] as String,
          expense[1] as String,
          expense[2] as String,
          expense[3] as String,
        )).toList();
        return expenses;
      } else {
        // Handle the case where the response is null
        return [];
      }
    } else {
      // Handle the case where the request fails
      throw Exception('Failed to get data');
    }
  }

  Future<void> fetchExpenses(String userId) async {
    try {
      List<Expense> fetchedExpenses = await get_data(userId);
      setState(() {
        general_expenses_data = Expenses(fetchedExpenses);
        expense_list_category_data = general_expenses_data.getExpensesByCategoryAndDate(category_name, sample_data.date);
        sample_data = expense_list_category_data.first;
        all_category_total_expenses= general_expenses_data.getTotalExpensesForAllCategoriesInSpecificDate(date);
        overallTotal = all_category_total_expenses.values.fold(0, (accumulator, element) => accumulator + element);
        percentage = general_expenses_data.getCategoryPercentagesForCategoryOnSpecificDate(category_name, sample_data.date).toStringAsFixed(2);
        totalSpentCategory = expense_list_category_data.fold(0, (sum, expense) => sum + (double.tryParse(expense.money_spent) ?? 0));
      });
    } catch (e) {
      setState(() {
        general_expenses_data = Expenses([]);
        expense_list_category_data = [];
        all_category_total_expenses= {};
        overallTotal = 0;
        percentage = '0';
        totalSpentCategory = 0;
      });
      print("error recovery");
      // Handle error gracefully
      print('Error fetching data: $e');
    }
  }



  void _updateExpense(Expense expense, String newTransaction, String newAmount) async {
    final url = Uri.parse("https://206e-110-235-154-222.ngrok-free.app/expenses/update");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "category": expense.category,
        "transaction": newTransaction,
        "spent": newAmount,
        "date": expense.date,
        "userId": user_id_data
      }),
    );

    if (response.statusCode == 200) {
      fetchExpenses(user_id_data);
      print("Expense updated successfully");
    } else {
      print("Failed to update expense: ${response.body}");
    }
  }

  void _showEditDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final transactionController = TextEditingController(text: expense.transaction);
        final amountController = TextEditingController(text: expense.money_spent);

        return AlertDialog(
          title: Text("Edit Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: transactionController,
                decoration: InputDecoration(labelText: "Transaction"),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newTransaction = transactionController.text;
                String newAmount = amountController.text;

                _updateExpense(expense, newTransaction, newAmount);

                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(String category, String transaction, String date, String userId) async {
    final url = Uri.parse("https://206e-110-235-154-222.ngrok-free.app/expenses/delete");

    // Prepare the data to be sent in the request body
    final data = {
      'category': category,
      'transaction': transaction,
      'date': date,
      'userId': userId,
    };

    try {
      final response = await http.delete(
        url,
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        fetchExpenses(user_id_data);
        print("Expense deleted successfully");
        // Optionally, trigger a setState or update the UI
      } else {
        print("Failed to delete expense: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  void _addExpense(Expense expense, BuildContext context) async {
    final url = Uri.parse("https://206e-110-235-154-222.ngrok-free.app/expenses/add");

    final data = {
      'category': expense.category,
      'transaction': expense.transaction,
      'spent': expense.money_spent,
      'date': expense.date,
      'userId': user_id_data,
    };

    // Save a local reference to the context
    final scaffoldContext = context;

    try {
      final response = await http.post(
        url,
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        fetchExpenses(user_id_data);
        print("Expense added successfully");
      } else {
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            const SnackBar(content: Text("Failed to add expense. Please try another name for your transaction.")),
          );
        }
        print("Failed to add expense: ${response.statusCode}");
      }
    } catch (e) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
      print("Error: $e");
    }
  }
  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final transactionController = TextEditingController();
        final amountController = TextEditingController();

        return AlertDialog(
          title: const Text("Add Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: transactionController,
                decoration: const InputDecoration(labelText: "Transaction"),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final expense = Expense(
                  category_name,
                  transactionController.text,
                  amountController.text,
                  sample_data.date,
                );

                Navigator.of(dialogContext).pop(); // Close the dialog **before** async call
                _addExpense(expense, context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }




  void _editCategoryname(String oldCategory, String newCategory, String date, String userId) async {
    final url = Uri.parse("https://206e-110-235-154-222.ngrok-free.app/expenses/edit-category-name");

    final data = {
      'oldCategory': oldCategory,
      'newCategory': newCategory,
      'date': date,
      'userId': userId,
    };

    try {
      final response = await http.put(
        url,
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        category_name = newCategory;
        fetchExpenses(user_id_data);
        print("Category updated successfully");
      } else {
        print("Failed to update category: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  void _showEditCategoryNameDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final categoryController = TextEditingController(text: expense.category);

        return AlertDialog(
          title: Text("Edit Category Name:\n${expense.category}" ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: "Enter category name: "),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newCategoryName = categoryController.text;

                _editCategoryname(expense.category, newCategoryName, sample_data.date, user_id_data);

                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Add this for scrolling
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF53197B)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            iconSize: 50,
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: Center(
                              child: Column(
                                children: [
                                  Text('Date: ', style: TextStyle(fontSize: 20)),
                                  expense_list_category_data.isNotEmpty
                                      ? Text(date_formatted, style: TextStyle(fontSize: 22))
                                      : Text(''),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox())
                      ],
                    ),

                    // Flexible container that adapts to content
                    Container(
                      margin: EdgeInsets.only(bottom: 0, top: 50, left: 10, right: 10),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFAE60CC),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: Colors.purple[100],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Date: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text(date_formatted)
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text('Overall Spent: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text('₱${overallTotal}')
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          // SingleChildScrollView for transactions list
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                color: Colors.purple[100],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    // Category and Transaction Summary
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(category_name, style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text(percentage + "%", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Transactions: " + expense_list_category_data.length.toString()),
                                              Text("Total Spent: ₱" + totalSpentCategory.toString()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),


                                    // Add expense and Edit Name
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Add Expense button
                                          SizedBox(
                                            width: 90,
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
                                                onTap: ()=>{_showAddExpenseDialog(context)},
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
                                                        'Add\nExpense',
                                                        textAlign: TextAlign.center, // Center the text within the container
                                                        style: TextStyle(color: Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Edit Name button
                                          SizedBox(
                                            width: 90,
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
                                                  onTap: ()=>{_showEditCategoryNameDialog(context, sample_data)},
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
                                                        'Edit\nName',
                                                        textAlign: TextAlign.center, // Center the text within the container
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
                                    ),






                                    // Specific Transactions List with Separator
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: expense_list_category_data.length,
                                      itemBuilder: (context, index) {
                                        final expense = expense_list_category_data[index];
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Divider(
                                                color: Colors.black,
                                                thickness: 2,
                                              ),
                                            ),
                                            Row( // The Row you want to add
                                              children: [
                                                Expanded( // Important: Use Expanded to prevent Row from taking infinite width
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 20),
                                                    child: ListTile(
                                                      title: Text(expense.transaction, style: TextStyle(fontWeight: FontWeight.bold)),
                                                      subtitle: Text("Spent: ₱${expense.money_spent}"),
                                                    ),
                                                  ),
                                                ),
                                                // Add other widgets to the Row here if needed
                                                // EDIT
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 20.0),
                                                  child: GestureDetector( // Add GestureDetector for tap functionality
                                                    onTap: () {
                                                      _showEditDialog(context, expense);
                                                      // Handle image tap (e.g., edit)
                                                    },
                                                    child: Image.asset( // Or Image.network if you're loading from the internet
                                                      'assets/images/edit.png', // Replace with your image path
                                                      height: 45, // Adjust height as needed
                                                      width: 45,   // Adjust width as needed
                                                      fit: BoxFit.contain, // Or BoxFit.cover, BoxFit.fill, etc. as needed
                                                    ),
                                                  ),
                                                ),
                                                // DELETE
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 20.0),
                                                  child: GestureDetector( // Add GestureDetector for tap functionality
                                                    onTap: () {
                                                      _deleteExpense(sample_data.category, expense.transaction, expense.date, user_id_data);
                                                      // Handle image tap (e.g., edit)
                                                    },
                                                    child: Image.asset( // Or Image.network if you're loading from the internet
                                                      'assets/images/delete.png', // Replace with your image path
                                                      height: 45, // Adjust height as needed
                                                      width: 45,   // Adjust width as needed
                                                      fit: BoxFit.contain, // Or BoxFit.cover, BoxFit.fill, etc. as needed
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}









void _showDuplicateExpenseDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Duplicate Expense"),
        content: const Text("This expense already exists. Please enter a different transaction."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}




