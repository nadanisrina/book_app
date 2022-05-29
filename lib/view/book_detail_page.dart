import 'dart:convert';

import 'package:book_app/models/book_detail_response.dart';
import 'package:book_app/view/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/widgets/framework.dart';

class DetailBookPage extends StatefulWidget {
  const DetailBookPage({Key? key, required this.isbn}) : super(key: key);
  final String isbn;

  @override
  State<DetailBookPage> createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  BookDetailResponse? bookDetail;

  fetchBookDetail() async {
    print(widget.isbn);
    //https://pub.dev/packages/http
    //widget : untuk akses kelas diatasnya
    var url = Uri.parse('https://api.itbook.store/1.0/books/${widget.isbn}');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBookDetail = jsonDecode(response.body);
      bookDetail = BookDetailResponse.fromJson(jsonBookDetail);
      //refresh
      setState(() {});
    }

    // print(await http.read(Uri.parse('https://example.com/foobar.txt')));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBookDetail();
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.75;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: bookDetail == null
          ?
          //must be centered
          Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImageViewScreen(imageUrl: bookDetail!.image!),
                          ),
                        );
                      },
                      child: Image.network(
                        bookDetail!.image!,
                        height: 100,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: c_width,
                      child: Column(
                        children: [
                          Text(bookDetail!.title!),
                          Text(bookDetail!.subtitle!),
                          Text(bookDetail!.authors!),
                          Text(bookDetail!.publisher!),
                          Text(bookDetail!.desc!),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
    );
  }
}
