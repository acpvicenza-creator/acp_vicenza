import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_member_screen.dart';
import 'about_acp_screen.dart';
import 'contact_screen.dart';
import 'admin_login_screen.dart';
import 'announcements_screen.dart';
import 'prayer_times_screen.dart';
import '../widgets/death_alert_banner_widget.dart'; // 👈 Death Alert Banner Import
import '../services/force_update_service.dart';     // 👈 Force Update Service Import
import '../widgets/app_drawer.dart';                 // 👈 Navigation Drawer Import

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 🚀 App Start hote hi Force Update check chalega
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateService.checkForUpdate(context);
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      // ANNOUNCEMENTS TAB
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
      );
    } else if (index == 3) {
      // EVENTS TAB
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      // 🔐 NAVIGATION DRAWER CONNECTED HERE
      drawer: const AppDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- TOP APP BAR WITH WORKING DRAWER BUTTON ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 👈 3-LINES HAMBURGER MENU BUTTON (OPENS DRAWER)
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: darkGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.menu, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: darkGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Stack(
                          children: [
                            Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔴 JANAZAH EMERGENCY ALERT BANNER (Live Display)
              const DeathAlertBannerWidget(),

              // --- LOGO & TITLE SECTION ---
              Image.asset(
                'assets/images/acp_logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance,
                  size: 90,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ACP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: darkGreen,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                'MANAGEMENT SYSTEM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('— ', style: TextStyle(color: Colors.amber)),
                  Text('&', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber)),
                  Text(' —', style: TextStyle(color: Colors.amber)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'DEATH COMMITTEE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Serving the community with\ncare, dignity and trust.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 16),

              // --- MAIN CARDS LIST ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildColorCard(
                      context,
                      title: 'ADMIN LOGIN',
                      subtitle: 'Login to admin panel',
                      icon: Icons.shield_outlined,
                      iconBgColor: const Color(0xFF0C5A32),
                      titleColor: const Color(0xFF0C5A32),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                      },
                    ),
                    _buildColorCard(
                      context,
                      title: 'MEMBER LOGIN',
                      subtitle: 'Login to your account',
                      icon: Icons.person,
                      iconBgColor: const Color(0xFF0052CC),
                      titleColor: const Color(0xFF0052CC),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                    ),
                    _buildColorCard(
                      context,
                      title: 'NEW REGISTRATION',
                      subtitle: 'Register yourself or your family',
                      icon: Icons.person_add_alt_1,
                      iconBgColor: const Color(0xFF6A1B9A),
                      titleColor: const Color(0xFF6A1B9A),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterMemberScreen()));
                      },
                    ),
                    // 🕌 PRAYER TIMES CARD
                    _buildColorCard(
                      context,
                      title: 'PRAYER TIMES',
                      subtitle: 'Daily Namaz timings for Vicenza',
                      icon: Icons.mosque,
                      iconBgColor: const Color(0xFF00695C),
                      titleColor: const Color(0xFF00695C),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen()));
                      },
                    ),
                    _buildColorCard(
                      context,
                      title: 'ANNOUNCEMENTS & NEWS',
                      subtitle: 'View community alerts & updates',
                      icon: Icons.campaign,
                      iconBgColor: const Color(0xFFD84315),
                      titleColor: const Color(0xFFD84315),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                      },
                    ),
                    _buildColorCard(
                      context,
                      title: 'ABOUT ACP',
                      subtitle: 'Learn more about ACP',
                      icon: Icons.chat_bubble_outline,
                      iconBgColor: const Color(0xFFE65100),
                      titleColor: const Color(0xFFE65100),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAcpScreen()));
                      },
                    ),
                    _buildColorCard(
                      context,
                      title: 'CONTACT',
                      subtitle: 'Get in touch with us',
                      icon: Icons.phone,
                      iconBgColor: const Color(0xFF00897B),
                      titleColor: const Color(0xFF00897B),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                      },
                    ),

                    const SizedBox(height: 12),

                    // --- CALL US & EMAIL US BANNER ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: darkGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Call Us', style: TextStyle(color: Colors.amber, fontSize: 10)),
                                    Text('3280452178', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(height: 30, width: 1, color: Colors.white24),
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('Email Us', style: TextStyle(color: Colors.amber, fontSize: 10)),
                                      Text('acpvicenza@gmail.com', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- 4 FEATURES GRID ---
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(Icons.groups, 'Community', 'We are here\nfor you'),
                          _buildFeatureItem(Icons.verified_user_outlined, 'Trust & Security', 'Your data is safe\nwith us'),
                          _buildFeatureItem(Icons.volunteer_activism, 'Support', 'Always here to\nsupport you'),
                          _buildFeatureItem(Icons.favorite_border, 'Care & Respect', 'We care with\ndignity'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // --- BOTTOM NAVIGATION BAR WITH ANNOUNCEMENTS & EVENTS ---
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: darkGreen,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Members'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Announcements'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconBgColor,
        required Color titleColor,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: titleColor,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 12,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F2EC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF043927), size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}