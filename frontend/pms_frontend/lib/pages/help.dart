import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widget/enddrawer.dart';
import '../widget/navbar.dart';

class HelpModule extends StatelessWidget {
  const HelpModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDrawer(),
      body: const HelpContent(),
    );
  }
}

class HelpContent extends StatefulWidget {
  const HelpContent({super.key});

  @override
  State<HelpContent> createState() => _HelpContentState();
}

class _HelpContentState extends State<HelpContent> {
  String selectedTopic = 'Registration'; // Default selected topic

  // Define help topics and their content
  final Map<String, List<Map<String, String>>> helpContent = {
    'Registration': [
      {
        'question': 'How do I register new users in the system?',
        'answer':
            'Navigate to the Registration page from the main menu and select "User Registration". Fill in the required fields: Username, Password, Confirm Password, Security Question, Security Answer, and select admin privileges if needed. Only existing admin users can register new users. Click Register to create the account.'
      },
      {
        'question': 'What are the requirements for user registration?',
        'answer':
            'User registration requires: a unique Username, a secure Password, Password confirmation, a Security Question for account recovery, the corresponding Security Answer, and admin privilege selection (Yes/No). All fields are mandatory.'
      },
      {
        'question': 'How do I register new rice varieties?',
        'answer':
            'Go to Registration from the main menu and select "Rice Variety Registration". Enter the variety name and select the quality grade (either "Shatter" or "Non-Shattering"). Click Register to add the rice variety to your system catalog.'
      },
      {
        'question': 'How do I register new machinery?',
        'answer':
            'Navigate to Registration and select "Machinery Registration". Enter the machine name, hour meter reading (0 for new machines), select mobility (Yes for mobile, No for static), and set harvest status (Yes if machine can harvest, No if it cannot). The "Repairs Needed" status is automatically managed when repair orders are created. Click Register to add the machine to your inventory.'
      },
    ],
    'Machine Management': [
      {
        'question': 'How do I view all registered machines?',
        'answer':
            'Go to Machine Management and select "Machines". You will see a list of all registered machines showing their ID, name, mobility status (Mobile/Static), and harvest status (Active/Inactive). Use the refresh button to update the list.'
      },
      {
        'question': 'How do I edit machine information?',
        'answer':
            'In Machine Management, go to "Maintenance" and select "Edit Machine Details". Find the machine you want to edit and click the edit icon. You can update the machine name, mobility (Yes/No), and harvest status (Yes/No). Save changes to update the machine information.'
      },
      {
        'question': 'How do I delete a machine?',
        'answer':
            'In Machine Management → Maintenance → Edit Machine Details, locate the machine and click the delete icon. Confirm the deletion when prompted. Note: This will also delete all related repair records for that machine.'
      },
      {
        'question': 'How do I report machine repairs?',
        'answer':
            'Go to Machine Management and select "Repairs". Choose the machinery from the dropdown, describe the issue, select the parts concerned (Engine, Transmission, Straw Dispensing System, Chassis, Control System, Tracks, Electrical, Lubrication Systems, General, or Others), and submit the repair request.'
      },
      {
        'question': 'How do I check repair status?',
        'answer':
            'Navigate to Machine Management → Repairs → Repair Status to view all repair requests. You can see the machine name, reported issues, parts concerned, and current status of each repair request.'
      },
    ],
    'Production Tracking': [
      {
        'question': 'How do I record rice production data?',
        'answer':
            'Go to Production Tracking and click "Add Record". Select the rice variety from the dropdown, enter the farmer name, choose the municipality, input hectares farmed, quantity harvested in kilograms, and select the harvest date. Click Add to save the production record.'
      },
      {
        'question': 'What information is required for production records?',
        'answer':
            'Production records require: Rice Variety (from registered varieties), Farmer Name, Municipality (from predefined list), Hectares (decimal numbers allowed), Quantity Harvested (in kilograms), and Harvest Date. All fields are mandatory.'
      },
      {
        'question': 'How do I view production history?',
        'answer':
            'Access the Production Tracking page to view all recorded harvests. The table shows ID, Rice Variety, Farmer Name, Municipality, Hectares, Quantity, Yield per Hectare (automatically calculated), and Harvest Date. Use the refresh button to update the list.'
      },
      {
        'question': 'How is yield per hectare calculated?',
        'answer':
            'Yield per hectare is automatically calculated by the system using the formula: Quantity Harvested (kg) ÷ Hectares. This metric helps evaluate production efficiency across different fields and farmers.'
      },
      {
  'question': 'How do I assign machines for daily use?',
  'answer':
      'In Machine Management → Machines → Currently Used Machines, click "Assign Machine". Select an available machine (must be mobile and able to harvest), enter the rentee name, current hour meter reading, and optional notes. Only unassigned machines are available for selection.'
      },
      {
        'question': 'How do I return an assigned machine?',
        'answer':
            'In Currently Used Machines, find the active assignment and click the return icon. Enter the final hour meter reading and any return notes. The machine\'s hour meter will be updated automatically and the machine becomes available for new assignments.'
      },
      {
        'question': 'Which machines can be assigned for daily use?',
        'answer':
            'Only machines that have both "Is Mobile?" and "Can Harvest?" set to "Yes" can be assigned for daily use. Machines that are already assigned, need repairs, or are not mobile/harvestable are not available for assignment.'
      },
    ],
    'Forecasting': [
      {
        'question': 'How does the forecasting system work?',
        'answer':
            'The forecasting module analyzes your historical production data to predict future yields. It uses SARIMA (Seasonal Autoregressive Integrated Moving Average) algorithm to calculate total yield, average production, and provides accuracy metrics based on past performance data.'
      },
      {
        'question': 'What metrics does forecasting provide?',
        'answer':
            'Forecasting provides: Total Yield predictions, Total Records analyzed, Average Production estimates, and Accuracy percentage. The system validates predictions against historical data to ensure reliability.'
      },
      {
        'question': 'How accurate are the forecasting predictions?',
        'answer':
            'The system typically provides forecasting accuracy of around 95% based on historical data validation. Accuracy improves with more complete and consistent production data input over time.'
      },
    ],
    'Search & Reports': [
      {
        'question': 'What can I search for in the system?',
        'answer':
            'The search functionality allows you to find: Rice varieties and parts needed. Choose an item you want to find in the drop-down list.'
      },
      {
        'question': 'What types of reports are available?',
        'answer':
            'Available reports include: Production Reports (harvest summaries and statistics), Machine Status Reports (showing active/inactive and mobile/static machines), Production Tracking Reports, and Machine Maintenance Reports. Reports can be generated as PDFs.'
      },
      {
        'question': 'How do I generate a Machine Status Report?',
        'answer':
            'Navigate to Reports and select "Machine Status Report". The report shows total machines, active vs inactive counts, mobile vs static counts, and detailed machine information. Click the print/export button to generate a PDF.'
      },
    ],
    'System Maintenance': [
      {
        'question': 'How do I edit rice varieties?',
        'answer':
            'Go to Machine Management → Maintenance → Edit Rice Variety. Find the rice variety you want to edit and click the edit icon. You can update the variety name and quality grade (Shatter/Non-Shattering). Save changes to update the variety information.'
      },
      {
        'question': 'How do I backup system data?',
        'answer':
            'Navigate to Machine Management → Maintenance → Back Up to access the backup functionality. The system can create backups of all your data including machinery, rice varieties, users, and production records. Follow the backup process to secure your data.'
      },
      {
        'question': 'How do I manage user logs and activity?',
        'answer':
            'Access user activity logs through the User Logs section. This shows all user activities including registrations, data modifications, and system access. This helps track system usage and maintain security.'
      },
      {
        'question': 'What should I do if I encounter system errors?',
        'answer':
            'If you encounter errors, try refreshing the page first. For persistent issues, check your internet connection and try again. Contact your system administrator if problems continue, providing details about the error message and what you were doing when it occurred.'
      },
      {
        'question': 'How do I change my security settings?',
        'answer':
            'Administrators can update user security settings through the Maintenance > Edit Users section. You can change security questions, security answers, and passwords. When editing a user, fill in the new password fields only if you want to change the password - leave them blank to keep the current password. All password changes require confirmation and must be at least 8 characters long.'
      },
      {
        'question': 'How do I change a user\'s password?',
        'answer':
            'To change a user\'s password: 1) Go to Maintenance > Edit Users, 2) Click the edit icon next to the user, 3) Enter a new password in the "New Password" field, 4) Confirm the password in the "Confirm New Password" field, 5) Click Update. Leave the password fields blank if you don\'t want to change the password. The new password must be at least 8 characters long.'
      },
    ],
    'Password & Security': [
      {
        'question': 'How do I recover my password?',
        'answer':
            'Use the "Forgot Password" option on the login page. You will be prompted to answer your security question. Upon providing the correct answer, you can reset your password. Contact your administrator if you cannot remember your security question answer.'
      },
      {
        'question': 'How do I change my security settings?',
        'answer':
            'Access your user profile to update your password and security question. You will need to provide your current password to make changes. Choose a strong password and a memorable security question for account recovery.'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Page Title
          const Text(
            "Help",
            style: TextStyle(
              color: ThemeColor.secondaryColor,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),

          // Main Content Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Sidebar - Navigation
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: ThemeColor.white2,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: helpContent.keys.map((topic) {
                        return _buildSidebarItem(topic);
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Right Content Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeColor.white2,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildContentArea(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String topic) {
    final isSelected = selectedTopic == topic;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? ThemeColor.secondaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? ThemeColor.secondaryColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(
          topic,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? ThemeColor.secondaryColor : ThemeColor.primaryColor,
          ),
        ),
        onTap: () {
          setState(() {
            selectedTopic = topic;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildContentArea() {
    final content = helpContent[selectedTopic] ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ThemeColor.secondaryColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),

          // FAQ Items
          ...content.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildFAQItem(index + 1, item['question'] ?? '', item['answer'] ?? '');
          }),

          // If no content available
          if (content.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  "No help content available for this topic.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(int number, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question with number
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: ThemeColor.secondaryColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ThemeColor.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Answer
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
