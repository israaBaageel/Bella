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
                  String name = userUploadedFiles[index]["name"];
                  String ext = userUploadedFiles[index]["extension"];
                  String publicId = userUploadedFiles[index]["id"];
                  String fileUrl = userUploadedFiles[index]["url"];

                  return GestureDetector(
                    // onLongPress: () {
                    //   showDialog(
                    //     context: context,
                    //     builder:
                    //         (context) => AlertDialog(
                    //           title: const Text("Delete file"),
                    //           content: const Text(
                    //             "Are you sure you want to delete?",
                    //           ),
                    //           actions: [
                    //             TextButton(
                    //               onPressed: () {
                    //                 Navigator.pop(context);
                    //               },
                    //               child: Text(
                    //                 "No",
                    //                 style: TextStyle(color: Colors.black),
                    //               ),
                    //             ),
                    //             TextButton(
                    //               onPressed: () async {
                    //                 final bool deleteResult = await AppDatabaseService()
                    //                     .deleteFile(
                    //                       snapshot.data!.docs[index].id,
                    //                       publicId,
                    //                     );
                    //                 if (deleteResult) {
                    //                   ScaffoldMessenger.of(
                    //                     context,
                    //                   ).showSnackBar(
                    //                     const SnackBar(
                    //                       content: Text("File deleted"),
                    //                     ),
                    //                   );
                    //                 } else {
                    //                   ScaffoldMessenger.of(
                    //                     context,
                    //                   ).showSnackBar(
                    //                     const SnackBar(
                    //                       content: Text(
                    //                         "Error in deleting file.",
                    //                       ),
                    //                     ),
                    //                   );
                    //                 }
                    //                 Navigator.pop(context);
                    //               },
                    //               child: Text(
                    //                 "Yes",
                    //                 style: TextStyle(color: Colors.black),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //   );
                    // },
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  ext == "png" || ext == "jpg" || ext == "jpeg"
                                      ? Icons.image
                                      : Icons.movie,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
