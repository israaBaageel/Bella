import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test/pages/FilterableGrid.dart';
import 'package:test/pages/item_detail_page.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/util/catigories.dart';
import 'package:test/services/database_service.dart';
import 'package:test/pages/preview_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(leading: null),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 150,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<DocumentSnapshot>(//===============Get user name
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error');
                        } else if (snapshot.hasData && snapshot.data!.exists) {
                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final userName = userData['name'] ?? 'User';
                          return Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          );
                        } else {
                          return const Text('User');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 30,
                maxHeight: 30,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text(
                          'MY CLOSET'.tr(),
                          style: GoogleFonts.aboreto(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(child: FilterableGrid()),//=================
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class AllItemGrid extends StatelessWidget {//=====================
  final String categoryFilter;
  const AllItemGrid({super.key, required this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final baseQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('clothingItems');

    final query = categoryFilter == 'All'
        ? baseQuery
        : baseQuery.where('category', isEqualTo: categoryFilter.toLowerCase());

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userUploadedFiles = snapshot.data!.docs;
          if (userUploadedFiles.isEmpty) {
            return Center(child: Text("No files uploaded"));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: userUploadedFiles.length,
              itemBuilder: (context, index) {
                final docId = userUploadedFiles[index].id;
                final data =
                    userUploadedFiles[index].data() as Map<String, dynamic>;
                final fileUrl = data["url"];
                final isImage = fileUrl.endsWith(".png") ||
                    fileUrl.endsWith(".jpg") ||
                    fileUrl.endsWith(".jpeg");

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailPage(
                          docId: docId,
                          itemData: data,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.grey.shade200,
                    child: isImage
                        ? Image.network(fileUrl, fit: BoxFit.cover)
                        : Icon(Icons.movie),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

