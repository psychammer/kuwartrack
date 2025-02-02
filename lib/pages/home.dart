import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart'; // Import for date formatting and parsing
import 'package:kuwartrack/expense_card.dart';
import 'package:kuwartrack/expense_class.dart';
import 'package:kuwartrack/pages/transaction.dart';
import 'package:kuwartrack/pages/edit.dart';
import 'package:kuwartrack/pages/settings.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};
  late Expenses expenses;
  late List<Expense> expense_list;
  Map<String, double> category_total_expenses = {};
  bool isLoading = true;
  late double overallTotal;
  Map<String, double> pie_percentages = {};
  int _selectedIndexDate = 0;
  int transactions = 0;
  bool asc_or_desc = true; // ascending by default
  bool sort_by_type = true; // by default percentage
  int _selectedNavigationIndex = 1; // home
  double savings = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch user ID and trigger data fetching
      data = ModalRoute.of(context)?.settings?.arguments as Map;
      if (data.containsKey('user_id')) {
        fetchExpenses(data['user_id']);
        fetchBudgetData();
      }
    });
  }

  void _onPeriodChanged(int index) {
    setState(() {
      _selectedIndexDate = index;
      switch(_selectedIndexDate){
        case 0:
          pie_percentages = expenses.getCategoryPercentagesThisWeek();
          category_total_expenses = expenses.getTotalExpensesForAllCategoriesInCurrentWeek();
          category_total_expenses = asc_or_desc?sortedAsc(category_total_expenses, sort_by_type):sortedDesc(category_total_expenses, sort_by_type);
          overallTotal =  category_total_expenses.values.fold(0, (accumulator, element) => accumulator + element);
          break;
        case 1:
          pie_percentages = expenses.getCategoryPercentagesLastWeek();
          category_total_expenses = expenses.getTotalExpensesForAllCategoriesInLastWeek();
          category_total_expenses = asc_or_desc?sortedAsc(category_total_expenses, sort_by_type):sortedDesc(category_total_expenses, sort_by_type);
          overallTotal =  category_total_expenses.values.fold(0, (accumulator, element) => accumulator + element);
          break;
        case 2:
          pie_percentages = expenses.getCategoryPercentagesLastMonth();
          category_total_expenses = expenses.getTotalExpensesForAllCategoriesInLastMonth();
          category_total_expenses = asc_or_desc?sortedAsc(category_total_expenses, sort_by_type):sortedDesc(category_total_expenses, sort_by_type);
          overallTotal =  category_total_expenses.values.fold(0, (accumulator, element) => accumulator + element);
          break;
        default:
          pie_percentages = expenses.getCategoryPercentagesThisWeek(); break;
      }
    });
  }

  // initial render
  Future<void> fetchExpenses(String userId) async {
    try {
      setState(() {
        isLoading = true;
      });
      List<Expense> fetchedExpenses = await get_data(userId);
      setState(() {
        expense_list = fetchedExpenses;
        expenses = Expenses(fetchedExpenses);
        print("heresay " + expense_list.toString());
        category_total_expenses = expenses.getTotalExpensesForAllCategoriesInCurrentWeek();
        // print("here?" + expense_list.length.toString());
        // get the total money spent for this week
        overallTotal =  category_total_expenses.values.fold(0, (accumulator, element) => accumulator + element);
        pie_percentages = expenses.getCategoryPercentagesThisWeek();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        expenses = Expenses([]);
        isLoading = false;
      });
      // Handle error gracefully
      print('Error fetching data: $e');
    }
  }

  // Navigation onTapped
  void _onNavigationTapped(int index) {
    if (!mounted) return;
    
    setState(() {
      _selectedNavigationIndex = index;
    });

    switch (index) {
      case 0: // Transaction page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Transaction(
              expenses: expenses,
              user_id: data['user_id'] ?? 'admin'
            )
          )
        );
        break;
      
      case 1: // Home page - stay here
        break;
      
      case 2: // Settings page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Settings()
          )
        );
        break;
    }
  }

  Future<void> fetchBudgetData() async {
    final url = Uri.parse('https://e585-130-105-115-165.ngrok-free.app/expenses/get_budget?userId=${data['user_id']}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double todayBudget = data['today_budget'];
      double totalSavings = data['total_savings'];

      print("Today's Budget: $todayBudget");
      print("Total Savings: $totalSavings");

      setState(() {
        savings = totalSavings;
      });
    } else {
      print("Error fetching budget data: ${response.body}");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while waiting for data
          : SafeArea(
        child: Column(
          children: [

            // Logo and logout button
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                    children: [
                      Expanded( // Takes up available space
                        child: Padding(
                          padding:  const EdgeInsets.only(left: 80.0),
                          child: Center( // Centers the logo within the expanded space
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 120,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Color(0xFF53197B)),
                        onPressed: () {
                          Navigator.pop(context); // Navigator.pushReplacement, Navigator.push()
                        },
                        iconSize: 50,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),


            // Pie chart with period toggle buttons
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    MyToggleButtonExample(onPeriodChanged: _onPeriodChanged),
                    SizedBox(height: 20),
                    Text(
                      savings > 0
                          ? 'You have saved \₱${savings} today!'
                          : savings < 0
                          ? 'You have exceeded over \₱${savings} today!'
                          : 'You have not saved anything today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: savings < 0
                            ? Colors.red
                            : savings == 0
                            ? Colors.black
                            : Colors.green,
                      ),
                    ),
                    Expanded(
                      child: PieChart(
                        dataMap: pie_percentages.isNotEmpty ? pie_percentages : {"No record yet": 0},
                      ),
                    ),
                  ],
                ),
              ),
            ),


            // Bottom Card
            Container(
              height: 260,
              margin: EdgeInsets.only(bottom:0), // Keep your bottom margin
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFAE60CC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sort by widgets
                        sort_by_type?
                        ElevatedButton.icon(
                          onPressed: () {setState(() {
                            sort_by_type = !sort_by_type;
                            category_total_expenses = sortedDesc(category_total_expenses, sort_by_type);
                          });},
                          icon: Icon(Icons.sort),
                          label: Text('Sort by percentage'),
                        ):
                        ElevatedButton.icon(
                          onPressed: () {setState(() {
                            sort_by_type = !sort_by_type;
                            category_total_expenses = sortedAsc(category_total_expenses, sort_by_type);
                          });},
                          icon: Icon(Icons.sort),
                          label: Text('Sort by category'),
                        ),
                        // Sort Ascending or Descending Widgets
                        asc_or_desc?
                        ElevatedButton.icon(
                          onPressed: () {setState(() {
                            asc_or_desc = !asc_or_desc;
                            category_total_expenses = sortedDesc(category_total_expenses, sort_by_type);
                          });},
                          icon: Icon(Icons.arrow_upward),
                          label: Text('Ascending'),
                        ):
                        ElevatedButton.icon(
                          onPressed: () {setState(() {
                            asc_or_desc = !asc_or_desc;
                            category_total_expenses = sortedAsc(category_total_expenses, sort_by_type);
                          });},
                          icon: Icon(Icons.arrow_downward),
                          label: Text('Descending'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Expense list widgets
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                        category_total_expenses.entries.map((entry) {
                          String category = entry.key;
                          double totalSpent = entry.value;
                          if(_selectedIndexDate==1){
                            transactions = expenses.getTotalTransactionsForAllCategoriesLastWeek(entry.key);
                          }
                          else if(_selectedIndexDate==2){
                            transactions = expenses.getTotalTransactionsForAllCategoriesLastMonth(entry.key);
                          }
                          else{
                            transactions = expenses.getTotalTransactionsForAllCategoriesThisWeek(entry.key);
                          }
                          double percentage = (overallTotal > 0) ? (totalSpent / overallTotal) * 100 : 0; // Calculate percentage

                          return ExpenseCard(
                            category: category,
                            transactions: transactions.toString(),
                            totalSpent: totalSpent.toString(),
                            percentage: percentage.toString(),
                          );
                        }).toList(),




                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.attach_money, size: 50), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 50), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings, size: 50), label: ''),
        ],
        currentIndex: _selectedNavigationIndex,
        onTap: _onNavigationTapped,
        backgroundColor: Color(0xFFF68F6D), // Set the background color
        selectedItemColor: Colors.white, // Color for the selected item
        unselectedItemColor: Colors.black, // Color for unselected items
      ),
    );
  }
}






















// Get data request
Future<List<Expense>> get_data(String user_id) async {
  final url = Uri.parse("https://e585-130-105-115-165.ngrok-free.app/api/auth/post_data");
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


// Toggle Buttons
class MyToggleButtonExample extends StatefulWidget {
  final Function(int) onPeriodChanged; // Define the callback

  const MyToggleButtonExample({super.key, required this.onPeriodChanged});

  @override
  State<MyToggleButtonExample> createState() => _MyToggleButtonExampleState();
}

class _MyToggleButtonExampleState extends State<MyToggleButtonExample> {
  int _selectedIndex = 0; // Initialize with the first button selected
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(20),
      selectedColor: Colors.white,
      fillColor: Colors.purple,
      color: Colors.grey, // Color of unselected buttons
      isSelected: _getIsSelectedList(), // Use a method to generate the list
      children: const [ // Use const for children that don't change
        Padding(padding: EdgeInsets.all(8), child: Text('This Week')),
        Padding(padding: EdgeInsets.all(8), child: Text('Last Week')),
        Padding(padding: EdgeInsets.all(8), child: Text('Last Month')),
      ],
      onPressed: (int index) {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
        // Do something based on the selected index:
        switch (index) {
          case 0:
            print("This Week selected");
            // Load data for this week
            break;
          case 1:
            print("Last Week selected");
            // Load data for last week
            break;
          case 2:
            print("Last Month selected");
            // Load data for last month
            break;
        }
        widget.onPeriodChanged(index);
      },
    );
  }

  List<bool> _getIsSelectedList() {
    return List.generate(3, (index) => index == _selectedIndex);
  }
}

//  sort by ascending function
Map<String, double> sortedAsc(Map<String, double> inputExpenses, bool sortByType) {
  var sortedEntries;
  // Convert the map entries to a list and sort by keys
  if(sortByType==true){ // sort by percentage
    sortedEntries = inputExpenses.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
  }
  else{ // sort by category
    sortedEntries = inputExpenses.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
  }

  // Convert back to a Map and return
  return Map.fromEntries(sortedEntries);
}
//  sort by descending function
Map<String, double> sortedDesc(Map<String, double> inputExpenses, bool sortByType) {
  var sortedEntries;
  // Convert the map entries to a list and sort by keys
  if(sortByType==true){ // sort by percentage
    sortedEntries = inputExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }
  else{ // sort by category
    sortedEntries = inputExpenses.entries.toList()
      ..sort((a, b) => b.key.toLowerCase().compareTo(a.key.toLowerCase()));
  }

  // Convert back to a Map and return
  return Map.fromEntries(sortedEntries);
}
