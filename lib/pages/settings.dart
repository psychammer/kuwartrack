import 'package:flutter/material.dart';
import 'package:kuwartrack/main.dart'; // Added to resolve MyApp
import 'home.dart';
import 'theme_settings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String get currentTheme {
    final themeMode = MyApp.of(context).themeMode; // using public getter
    switch (themeMode) {
      case ThemeMode.system:
        return 'Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'Default';
    }
  }

  // Updated _buildSettingItem to use dynamic text color
  Widget _buildSettingItem(IconData icon, String title, String value) {
    final Color textColor = MyApp.of(context).themeMode == ThemeMode.dark
        ? const Color(0xFFBB6CEB)
        : const Color(0xFF53197B);
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          if (title == 'Theme') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ThemeSettings()),
            );
          }
          if (title == 'About') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AboutPage()),
            );
          }
          if (title == 'Help') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          }
          // ... other onTap logic if needed ...
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = MyApp.of(context).themeMode == ThemeMode.dark
        ? const Color(0xFFBB6CEB)
        : const Color(0xFF53197B);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        // Remove hardcoded transparent color to let Theme override if needed
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  _buildSettingItem(Icons.palette, 'Theme', currentTheme),
                  _buildSettingItem(Icons.security, 'Security', 'Biometric'),
                  _buildSettingItem(Icons.notifications, 'Notification', 'On'),
                  _buildSettingItem(Icons.info, 'About', ''),
                  _buildSettingItem(Icons.help, 'Help', ''),
                ],
              ),
            ),
            // Logo section
            Container(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "You're using the Alpha version.\nThank you for testing this prototype.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modify the AboutPage class to complement dark mode
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context).themeMode == ThemeMode.dark;
    final Color textColor = isDark ? const Color(0xFFBB6CEB) : const Color(0xFF53197B);
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    // Use a distinct dark purple container color when in dark mode that complements the violet text
    final Color customContainerColor =
        isDark ? const Color(0xFF5E3A7E) : const Color.fromRGBO(83, 25, 123, 0.05);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Kuwartrack',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with updated container color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: customContainerColor,
              child: Column(
                children: [
                  Text(
                    'Hakbang Mo ay Laging Swak!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Financial Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Kuwartrack is a mobile expense tracker designed to empower users with better money management through real-time insights and simplified budgeting. Developed by BS Computer Science students from Polytechnic University of the Philippines, this app aims to bridge the gap between financial literacy and daily spending habits.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: textColor,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            // Mission
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: textColor,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      '"To simplify financial tracking and foster responsible budgeting habits for students, young professionals, and families through intuitive technology."',
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Features
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeature('Smart Expense Logging',
                      'Easily track expenses with automatic categorization', textColor),
                  _buildFeature('Real-Time Budget Alerts',
                      'Get instant notifications when approaching spending limits', textColor),
                  _buildFeature('Visual Financial Dashboard',
                      'Understand spending patterns through interactive charts', textColor),
                ],
              ),
            ),
            // The Team section with updated container color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: customContainerColor,
              child: Column(
                children: [
                  Text(
                    'Development Team',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTeamMember(
                          'Roljohn Frilles',
                          imageAsset: 'assets/images/Roljohn.jpg',
                          nameColor: isDark ? Colors.black : textColor,
                        ),
                        _buildTeamMember(
                          'Paul Angelo Macaraeg',
                          imageAsset: 'assets/images/Paul.jpg',
                          nameColor: isDark ? Colors.black : textColor,
                        ),
                        _buildTeamMember(
                          'Precious Grace Deborah Manucom',
                          imageAsset: 'assets/images/Precious.jpg',
                          nameColor: isDark ? Colors.black : textColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contact & Footer
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSection(
                    'Contact Us',
                    'Have questions or suggestions? We\'d love to hear from you!\n\n📧 Support: kuwartrack.support@gmail.com',
                    textColor,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Version 1.0.0 (Alpha Release)\n© 2025 Kuwartrack Team. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle,
              color: textColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildTeamMember with a 'nameColor' parameter to adjust text color based on dark mode.
  Widget _buildTeamMember(String name, {required String imageAsset, required Color nameColor}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              imageAsset,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: nameColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color textColor) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// Modify the HelpPage class so that text colors in the Help sections become Color(0xFFBB6CEB) in dark mode
class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context).themeMode == ThemeMode.dark;
    final Color helpTextColor =
        isDark ? const Color(0xFFBB6CEB) : const Color(0xFF53197B);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: helpTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help',
          style: TextStyle(color: helpTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Transactions Navigation Help',
                [
                  _buildHelpItem('Summary Overview',
                      'At the top, you\'ll find Day, Week, and Month summaries showing your total expenses for different time frames.', helpTextColor),
                  _buildHelpItem('Current Savings',
                      'View your accumulated savings over time in the Current Savings box.', helpTextColor),
                  _buildHelpItem('Budget Management',
                      'Use "Set Today\'s Budget" to establish your daily spending limit. The current budget is displayed prominently below.', helpTextColor),
                  _buildHelpItem('Calendar Navigation',
                      'Click the calendar icon to view expenses for specific dates. The selected date and overall spending will be displayed.', helpTextColor),
                  _buildHelpItem('Adding Expenses',
                      'Use the "Add Category" button to log new expenses and maintain your spending records.', helpTextColor),
                  _buildHelpItem('Expense Details',
                      'Each expense entry shows the category, number of transactions, total spent, and percentage of overall spending.', helpTextColor),
                ],
                helpTextColor,
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Home Navigation Help',
                [
                  _buildHelpItem('Time Period Selection',
                      'Toggle between This Week, Last Week, and Last Month to view different expense periods.', helpTextColor),
                  _buildHelpItem('Savings Overview',
                      'See your savings status: whether you\'ve saved money, exceeded budget, or broken even.', helpTextColor),
                  _buildHelpItem('Pie Chart Visualization',
                      'Visual representation of your spending distribution across different categories for the selected time period.', helpTextColor),
                  _buildHelpItem('Sorting Options',
                      'Sort expenses by:\n• Category (alphabetical order)\n• Percentage (spending proportion)\n• Choose Ascending or Descending order', helpTextColor),
                ],
                helpTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<ExpansionTile> items, Color helpTextColor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title == 'Transactions Navigation Help' ? Icons.attach_money : Icons.home,
                  size: 24,
                  color: helpTextColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: helpTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  ExpansionTile _buildHelpItem(String question, String answer, Color helpTextColor) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: helpTextColor,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}