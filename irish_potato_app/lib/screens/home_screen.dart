import 'package:flutter/material.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/screens/admin_approval_screen.dart';
import 'package:irish_potato_app/screens/agronomist_farmers_screen.dart';
import 'package:irish_potato_app/screens/farmer_advice_screen.dart';
import 'package:irish_potato_app/screens/farmer_chat_list_screen.dart';
import 'package:irish_potato_app/screens/agronomist_chat_list_screen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = FirestoreService().getCurrentUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Status bar spacer
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFF2E7D32),
          ),
          Expanded(
            child: FutureBuilder<UserProfile?>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final profile = snapshot.data;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome Back',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.displayName ?? 'User',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                if (profile != null)
                                  StreamBuilder<UserProfile?>(
                                    stream: FirestoreService().getUserProfileStream(profile.uid),
                                    builder: (context, snapshot) {
                                      final userProfile = snapshot.data;
                                      return CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white,
                                        backgroundImage: userProfile?.profileImageUrl != null
                                            ? NetworkImage(userProfile!.profileImageUrl!)
                                            : null,
                                        child: userProfile?.profileImageUrl == null
                                            ? Text(
                                                (user.displayName ?? 'U')[0].toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E7D32),
                                                ),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                              ],
                            ),
                            if (profile != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      profile.locationLabel,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  profile.role.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Role-specific actions
                            if (profile?.role == 'farmer') ...[
                              _QuickActionCard(
                                title: 'Chat with Agronomists',
                                subtitle: 'Connect with experts nearby',
                                icon: Icons.chat_bubble,
                                color: const Color(0xFF1976D2),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FarmerChatListScreen(profile: profile!),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _QuickActionCard(
                                title: 'Get Expert Advice',
                                subtitle: 'Request help from agronomists',
                                icon: Icons.support_agent,
                                color: const Color(0xFF6A4E99),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FarmerAdviceScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],

                            if (profile?.role == 'agronomist') ...[
                              if (profile!.approved) ...[
                                _QuickActionCard(
                                  title: 'Chat with Farmers',
                                  subtitle: 'Help farmers in your area',
                                  icon: Icons.chat_bubble,
                                  color: const Color(0xFF1976D2),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AgronomistChatListScreen(profile: profile),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                _QuickActionCard(
                                  title: 'Farmers Nearby',
                                  subtitle: 'View farmers needing help',
                                  icon: Icons.group,
                                  color: const Color(0xFF1C7A5B),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AgronomistFarmersScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.pending_actions,
                                          color: Colors.orange.shade700, size: 32),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Text(
                                          'Your account is pending admin approval',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],

                            if (profile?.role == 'admin') ...[
                              _QuickActionCard(
                                title: 'Approve Agronomists',
                                subtitle: 'Review pending requests',
                                icon: Icons.verified_user,
                                color: const Color(0xFFBF360C),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdminApprovalScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Disease Resources
                            const Text(
                              'Disease Resources',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _DiseaseSearchCard(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiseaseSearchCard extends StatefulWidget {
  @override
  State<_DiseaseSearchCard> createState() => _DiseaseSearchCardState();
}

class _DiseaseSearchCardState extends State<_DiseaseSearchCard> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchDisease(String query) async {
    if (query.trim().isEmpty) return;

    final searchQuery = Uri.encodeComponent('potato $query disease treatment');
    final url = 'https://www.google.com/search?q=$searchQuery';
    
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Disease Info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find treatment and news',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Type disease name (e.g., Early Blight)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                onPressed: () => _searchDisease(_searchController.text),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: _searchDisease,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickSearchChip(
                label: 'Early Blight',
                onTap: () => _searchDisease('Early Blight'),
              ),
              _QuickSearchChip(
                label: 'Late Blight',
                onTap: () => _searchDisease('Late Blight'),
              ),
              _QuickSearchChip(
                label: 'Bacterial Wilt',
                onTap: () => _searchDisease('Bacterial Wilt'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickSearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSearchChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
