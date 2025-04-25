import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test/util/bubble_cat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/util/catigories.dart';
import 'package:test/services/database_service.dart';
import 'package:test/pages/preview_image.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: null,  // إزالة السهم في الـ AppBar
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 150,
              automaticallyImplyLeading: false, // إزالة السهم من SliverAppBar
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 50, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sarah.k',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: const SizedBox(height: 50),
            // ),
            
            // كلمة "MY CLOSET" ثابتة مع التصنيفات
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

            // التصنيفات الثابتة مع النص
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 120,
                maxHeight: 120,
                child: Container(
                  color: Colors.white,
                  child: const Catigories(),
                ),
              ),
            ),
            
            // Pictures Grid from AllItemsPage integrated here
            const SliverFillRemaining(
              child: AllItemGrid(),
            ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class AllItemGrid extends StatelessWidget {
  const AllItemGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AppDatabaseService().readUploadedFiles(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List userUploadedFiles = snapshot.data!.docs;
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
                String name = userUploadedFiles[index]["name"];
                String ext = userUploadedFiles[index]["extension"];
                String publicId = userUploadedFiles[index]["id"];
                String fileUrl = userUploadedFiles[index]["url"];

                return GestureDetector(
                  onTap: () {
                    if (ext == "png" || ext == "jpg" || ext == "jpeg") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewImage(url: fileUrl),
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ext == "png" || ext == "jpg" || ext == "jpeg"
                              ? Image.network(
                                  fileUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.movie),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
