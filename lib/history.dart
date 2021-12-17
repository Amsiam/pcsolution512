import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcsolution512/api/pdf_api.dart';

class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("invoice")
                .orderBy("datetime", descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return const Text("Data Not Found");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              var data = snapshot.requireData;
              return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (ctx, i) {
                  var download = FirebaseStorage.instance
                      .ref("invoice")
                      .child(data.docs[i].id)
                      .getDownloadURL();
                  return ListTile(
                    leading: Text("${i + 1}"),
                    title: Text("${data.docs[i].id}"),
                    subtitle: Text(
                      "${data.docs[i]['name']}",
                    ),
                    onTap: () async {
                      final dir = await getExternalStorageDirectory();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(" Opening Invoice")));
                      try {
                        final file =
                            File('${dir!.path}/${data.docs[i].id}.pdf');
                        if (await file.exists()) {
                          await PdfApi.openFile(file);
                        } else {
                          var d = await download;
                          var httpClient = HttpClient();
                          var request = await httpClient.getUrl(Uri.parse(d));
                          var response = await request.close();
                          var bytes = await consolidateHttpClientResponseBytes(
                              response);
                          final dir = (await getExternalStorageDirectory());

                          File file =
                              File('${dir!.path}/${data.docs[i].id}.pdf');
                          await file.writeAsBytes(bytes);
                          if (await file.exists()) {
                            await PdfApi.openFile(file);
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Can't Open")));
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Can't Open")));
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
