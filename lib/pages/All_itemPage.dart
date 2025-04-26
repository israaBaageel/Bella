import 'package:flutter/material.dart';
import 'package:test/pages/preview_image.dart';
import 'package:test/services/database_service.dart';

class AllItemPage extends StatelessWidget {
  const AllItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Items")),
      body: StreamBuilder(
        stream: AppDatabaseService().readUploadedFiles(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List userUploadedFiles = snapshot.data!.docs;
            if (userUploadedFiles.isEmpty) {
              return Center(child: Text("No files uploaded"));
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns in the grid
                  childAspectRatio: 1, // Aspect ratio for each grid item
                  crossAxisSpacing: 8, // Spacing between columns
                  mainAxisSpacing: 8, // Spacing between rows
                ),
                itemCount: userUploadedFiles.length,
                itemBuilder: (context, index) {
                  var data =
                      userUploadedFiles[index].data() as Map<String, dynamic>;

                  String ext = data["extension"] ?? "jpg";
                  String publicId = data["id"] ?? "";
                  String fileUrl = data["url"] ?? "";

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
                            child:
                                ext == "png" || ext == "jpg" || ext == "jpeg"
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
      ),
    );
  }
}
