import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../auth/auth_page.dart';
import '../chat/chat_list_page.dart';
import '../student/student_profile_page.dart';
import 'placeholder_pages.dart';
// 🔊 NEW: Make sure this file exists
import '../calls/incoming_call_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  StreamSubscription<QuerySnapshot>? _callSubscription;
  bool _isHandlingCall = false;

  @override
void initState() {
  super.initState();

  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid != null) {
    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {

      if (snapshot.docs.isNotEmpty && !_isHandlingCall) {
        _isHandlingCall = true;

        final callDoc = snapshot.docs.first;
        final callId = callDoc.id;
        final chatId = callDoc['chatId'];

        final callType = callDoc.data().containsKey('type')
            ? callDoc['type']
            : 'voice';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncomingCallPage(
              callId: callId,
              chatId: chatId,
              callType: callType, // 🔥 PASS TYPE
            ),
          ),
        ).then((_) {
          _isHandlingCall = false;
        });
      }
    });
  }
}

  @override
  void dispose() {
    _callSubscription?.cancel(); // 🔥 Prevent memory leak
    super.dispose();
  }





  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0F2642);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---------------- 1. MAIN SCROLLABLE CONTENT ----------------
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 110),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(context),
                    const SizedBox(height: 24),
                    _buildMenuGrid(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader('60s Mentor Reels', showViewAll: false),
                    const SizedBox(height: 16),
                    _buildMentorReelsList(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Upcoming Sessions',
                        showViewAll: false),
                    const SizedBox(height: 16),
                    _buildUpcomingSessionCard(),
                  ],
                ),
              ),
            ),
          ),

          // ---------------- 2. FIXED BOTTOM NAV BAR ----------------
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(context, darkBlue),
          ),

          // Note: The previous StreamBuilder for calls was removed
          // because the logic is now handled in initState.
        ],
      ),
    );
  }

  // ---------------- UI WIDGETS ----------------

  Widget _buildTopHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const StudentProfilePage()),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blueAccent.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good Morning',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18));
                }
                if (snapshot.hasError) {
                  return const Text('Student',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18));
                }
                final data =
                    snapshot.data?.data() as Map<String, dynamic>?;
                final name = data?['name'] ?? 'Student';
                return Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87));
              },
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.monetization_on,
                  color: Colors.orange, size: 16),
              SizedBox(width: 4),
              Text('0 XP',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _logout(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.language,
        'label': 'Mentor Verse',
        'color': const Color(0xFF1E3A8A),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MentorVersePage()))
      },
      {
        'icon': Icons.psychology,
        'label': 'AI Tutor',
        'color': Colors.green,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AiTutorPage()))
      },
      {
        'icon': Icons.handshake,
        'label': 'My Chat',
        'color': Colors.blue,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ChatListPage()))
      },
      {
        'icon': Icons.work_outline,
        'label': 'Job Hub',
        'color': Colors.orange,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JobHubPage()))
      },
      {
        'icon': Icons.lock_open,
        'label': 'Unlock',
        'color': Colors.purple,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UnlockPage()))
      },
      {
        'icon': Icons.help_outline,
        'label': 'Ask',
        'color': Colors.pink,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AskPage()))
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Jobs',
        'color': Colors.teal,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const JobsPage()))
      },
      {
        'icon': Icons.local_offer_outlined,
        'label': 'Tags',
        'color': Colors.deepOrange,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TagsPage()))
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: item['onTap'] as VoidCallback,
          child: Column(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(item['icon'] as IconData,
                    color: item['color'] as Color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(item['label'] as String,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title,
      {bool showViewAll = true, String actionText = 'See All'}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (title == '60s Mentor Reels')
              const Icon(Icons.play_circle_fill,
                  color: Colors.blue, size: 20),
            if (title == 'Upcoming Sessions')
              const Icon(Icons.calendar_month,
                  color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
        if (showViewAll)
          Text(actionText,
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
      ],
    );
  }

  Widget _buildMentorReelsList() {
    return Container(
      width: double.infinity,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300)),
      child: const Text("No reels posted yet",
          style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildUpcomingSessionCard() {
    return Container(
      width: double.infinity,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: const Text("You have no upcoming sessions",
          style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, Color darkBlue) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home (Active)
          GestureDetector(
            onTap: () {},
            child: const _NavBarItem(
                icon: Icons.home_rounded, label: 'Home', isActive: true),
          ),

          // 2. Explore (Future)
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const FutureUpdatePage(title: "Explore"))),
            child: const _NavBarItem(
                icon: Icons.explore, label: 'Explore', isActive: false),
          ),

          // 3. Add (Center Button - Future)
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const FutureUpdatePage(title: "Create"))),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: darkBlue.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),

          // 4. Events (Future)
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const FutureUpdatePage(title: "Events"))),
            child: const _NavBarItem(
                icon: Icons.calendar_today_rounded,
                label: 'Events',
                isActive: false),
          ),

          // 5. Community (Future)
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const FutureUpdatePage(title: "Community"))),
            child: const _NavBarItem(
                icon: Icons.people_alt_rounded,
                label: 'Community',
                isActive: false),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavBarItem(
      {required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: isActive ? Colors.blue : Colors.grey.shade400,
            size: 28),
        const SizedBox(height: 4),
        if (isActive)
          Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                  color: Colors.blue, shape: BoxShape.circle))
      ],
    );
  }
}