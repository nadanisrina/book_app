import 'dart:convert';

import 'package:book_app/models/book_detail_response.dart';
import 'package:book_app/models/book_list_response.dart';
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
    // print(widget.isbn);
    //https://pub.dev/packages/http
    //widget : untuk akses kelas diatasnya
    var url = Uri.parse('https://api.itbook.store/1.0/books/${widget.isbn}');
    var response = await http.get(url);
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBookDetail = jsonDecode(response.body);
      bookDetail = BookDetailResponse.fromJson(jsonBookDetail);
      //refresh
      setState(() {});
      fetchSimilarBookDetail(bookDetail!.title!);
    }

    // print(await http.read(Uri.parse('https://example.com/foobar.txt')));
  }

  //get similar data books
  BookListResponse? similarBooks;
  fetchSimilarBookDetail(String title) async {
    // print(widget.isbn);
    //https://pub.dev/packages/http
    //widget : untuk akses kelas diatasnya
    var url = Uri.parse('https://api.itbook.store/1.0/search/${title}');
    var response = await http.get(url);
    // print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBookDetail = jsonDecode(response.body);
      similarBooks = BookListResponse.fromJson(jsonBookDetail);
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
    double c_width = MediaQuery.of(context).size.width;
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        height: 150,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: (Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookDetail!.title!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                ),
                                Text(bookDetail!.authors!),
                                Row(
                                  children: List.generate(
                                      5,
                                      (index) => Icon(
                                            Icons.star,
                                            color: index <=
                                                    int.parse(
                                                        bookDetail!.rating!)
                                                ? Colors.yellow
                                                : Colors.grey,
                                          )),
                                ),
                                Text(bookDetail!.subtitle!),
                                Text(bookDetail!.price!),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: c_width,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(double.infinity, 50)),
                              onPressed: (() {}),
                              child: Text("BUY"),
                            ),
                          ),

                          // OutlinedButton(onPressed: onPressed, child: child),
                          // TextButton(onPressed: onPressed, child: child)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(bookDetail!.desc!),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text("ISBN" + bookDetail!.isbn13!),
                              Text(bookDetail!.pages! + "PAGES"),
                              Text(bookDetail!.publisher!),
                            ],
                          ),
                          Divider(),
                          //Similar book list
                          similarBooks == null
                              ? CircularProgressIndicator()
                              : Container(
                                  height: 170,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    //supaya bisa di scroll
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: similarBooks!.books!.length,
                                    itemBuilder: (context, index) {
                                      final current =
                                          similarBooks!.books![index];
                                      return Container(
                                        width: 80,
                                        child: Column(
                                          children: [
                                            Image.network(
                                              current.image!,
                                              height: 100,
                                            ),
                                            Text(
                                              current.title!,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
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
