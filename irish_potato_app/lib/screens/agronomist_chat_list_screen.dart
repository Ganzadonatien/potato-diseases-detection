import 'package:flutter/material.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/screens/chat_screen.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class AgronomistChatListScreen extends StatelessWidget {
  final UserProfile profile;

  const AgronomistChatListScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Chat with Farmers'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: FirestoreService().getAllUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final farmers = snapshot.data!
              .where((u) =>
                  u.role == 'farmer' &&
                  (u.province == profile.province ||
                      u.district == profile.district ||
                      u.sector == profile.sector))
              .toList();

          if (farmers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No farmers available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No farmers found in your area',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: farmers.length,
            itemBuilder: (context, index) {
              final farmer = farmers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF2E7D32),
                    backgroundImage: farmer.profileImageUrl != null
                        ? NetworkImage(farmer.profileImageUrl!)
                        : null,
                    child: farmer.profileImageUrl == null
                        ? Text(
                            farmer.fullName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    farmer.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farmer.locationLabel,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF2E7D32)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          currentUser: profile,
                          otherUser: farmer,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
