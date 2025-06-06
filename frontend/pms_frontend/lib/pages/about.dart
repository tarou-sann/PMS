import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widget/navbar.dart';
import '../widget/enddrawer.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: ThemeColor.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Navbar(),
      ),
      endDrawer: const EndDraw(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColor.white2,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "About Us",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
                const SizedBox(height: 40),
                
                // System Description
                const Text(
                  "Project Management System",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "We are a team compose of three third-year CS students working on a comprehensive production management system for Straw Innovations Ltd. We're delighted to see this idea come to life since we share a passion for technology and issue solving. Our solution strives to streamline production processes, increase efficiency, and deliver important insights targeted to Straw Innovations' individual needs. We hope to develop a solution that supports the company's growth and sustainability goals by leveraging our understanding of software engineering, machine learning, and data management.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 40),
                
                // Team Members Section
                const Text(
                  "Our Team",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.secondaryColor,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTeamMember(
                      "Dylan Yoshiya L. Arevalo",
                      "Leader/Lead Developer",
                      "lib/assets/images/dylan.jpg",
                    ),
                    _buildTeamMember(
                      "Randi Phyliz Gail A. Abelar",
                      "Member/Assistant Developer",
                      "lib/assets/images/randi.jpg",
                    ),
                    _buildTeamMember(
                      "Rainier Franz A. Dejoras",
                      "Member/Assistant Developer",
                      "lib/assets/images/rainier.jpg",
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

  Widget _buildTeamMember(String name, String role, String imagePath) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(75),
            child: Image.asset(
              imagePath,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColor.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}