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
        'question': 'How to register users?',
        'answer':
            'To register new users, navigate to the Registration page from the main menu. Fill in the required information including username, password, and security details. Click the Register button to create the new user account.'
      },
      {
        'question': 'What information is required for user registration?',
        'answer':
            'User registration requires: Username, Password, Confirm Password, Security Question, Security Answer, and Admin privileges selection.'
      },
      {
        'question': 'How to register rice varieties?',
        'answer':
            'Go to Registration > Rice Variety. Enter the variety name, select quality grade, and set production and expiration dates. Submit the form to add the new rice variety to the system.'
      },
    ],
    'Machine Management': [
      {
        'question': 'How to add new machinery?',
        'answer':
            'Navigate to Machine Management and click "Add New Machine". Enter the machine name, type, and other relevant details. Save to add the machinery to your inventory.'
      },
      {
        'question': 'How to edit machine information?',
        'answer':
            'In the Machine Management section, find the machine you want to edit and click the edit icon. Update the necessary information and save changes.'
      },
      {
        'question': 'How to delete a machine?',
        'answer':
            'From the Machine Management page, locate the machine and click the delete button. Confirm the deletion when prompted.'
      },
    ],
    'Production Tracking': [
      {
        'question': 'How to track rice production?',
        'answer':
            'Use the Production Tracking module to record harvest data including hectares farmed, quantity harvested, rice variety, and harvest date.'
      },
      {
        'question': 'How to view production history?',
        'answer':
            'Access production history through the Production Tracking page where you can see all recorded harvests with details and statistics.'
      },
    ],
    'Forecasting': [
      {
        'question': 'How does forecasting work?',
        'answer':
            'The forecasting module uses historical data to predict future rice production trends and help with planning and resource allocation.'
      },
      {
        'question': 'How to generate forecasting reports?',
        'answer':
            'Navigate to the Forecasting section and select your parameters. The system will generate predictions based on historical production data.'
      },
    ],
    'Search': [
      {
        'question': 'How to search for information?',
        'answer':
            'Use the Search functionality to quickly find users, machines, production records, or any other data in the system by entering relevant keywords.'
      },
      {
        'question': 'What can I search for?',
        'answer':
            'You can search for users, machinery, rice varieties, production records, maintenance logs, and other system data.'
      },
    ],
    'Reports': [
      {
        'question': 'How to generate reports?',
        'answer':
            'Access the Reports section to generate various reports including production summaries, machine usage, and user activity reports.'
      },
      {
        'question': 'What types of reports are available?',
        'answer':
            'Available reports include: Production Reports, Machine Maintenance Reports, User Activity Reports, and Custom Reports.'
      },
    ],
    'Maintenance': [
      {
        'question': 'How to report machine issues?',
        'answer':
            'Use the Maintenance module to report machine problems. Describe the issue and submit the repair request.'
      },
      {
        'question': 'How to track repair status?',
        'answer': 'Check the Maintenance section to view the status of reported issues and track repair progress.'
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
