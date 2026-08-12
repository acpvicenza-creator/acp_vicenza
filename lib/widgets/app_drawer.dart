import 'package:flutter/material.dart';
import '../screens/donations_tracker_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF043927);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. DRAWER HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryGreen),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/images/acp_logo.png',
                height: 40,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.mosque, color: primaryGreen, size: 30),
              ),
            ),
            accountName: const Text(
              'ACP Vicenza',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('Comunita Pakistana Di Vicenza'),
          ),

          // 2. THEME & APPEARANCE SECTION
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text(
              'Theme & Appearance',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),

          // DARK MODE TOGGLE SWITCH (Fixed activeThumbColor)
          SwitchListTile(
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: primaryGreen,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between Light & Dark Theme'),
            value: _isDarkMode,
            activeThumbColor: primaryGreen,
            onChanged: (bool val) {
              setState(() {
                _isDarkMode = val;
              });
            },
          ),

          const Divider(),

          // 3. NAVIGATION ITEMS & WELFARE FUND
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 5, bottom: 5),
            child: Text(
              'Quick Links',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.volunteer_activism, color: primaryGreen),
            title: const Text('Sadaqah & Welfare Fund'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonationsTrackerScreen()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings_outlined, color: primaryGreen),
            title: const Text('App Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}