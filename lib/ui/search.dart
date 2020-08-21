import 'dart:convert';
import 'dart:math';
import 'package:flutter_search_flickr/bloc/flickrbloc.dart';
import 'package:flutter_search_flickr/const.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:flutter_search_flickr/models/flickrmodel.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  _SearchState(){
    print('init');
  }

  List<String> tabBarTitle = [
    'Flickr Results',
  ];

  int selectedTab = 0;

  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController1 = ScrollController();

  var data;

  Future<void> getFilteredList() async {}

  Widget _flickrMessage() {
    return Center(
      child: Text('Flickr Results will appear here!'),
    );
  }

  Widget flickrResultsWidget() {
    return StreamBuilder(
        stream: flickrBloc.flickrController.stream,
        builder: (
            BuildContext buildContext,
            AsyncSnapshot<List<FlickrBlocModel>> snapshot
            ) {
          print('debug --> snapshot: $snapshot');

          if (snapshot == null) {
            return _flickrMessage();
          }
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(
            child: _flickrMessage(),
          )
              : _flickrResults(snapshot: snapshot);
        });
  }

  Widget _cardWidget(AsyncSnapshot<List<FlickrBlocModel>> snapshot, int index) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      Opacity(
        opacity: .9,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage('${snapshot.data[index].picture}')),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    blurRadius: 2, offset: Offset(1, 0.5), spreadRadius: 0.5)
              ]),
          margin: EdgeInsets.only(left: 5, bottom: 10, top: 10),
          alignment: Alignment.center,
        ),
      ),
      Container(
        alignment: Alignment.center,
        child: Text(
          '${snapshot.data[index].title}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.white,
          ),
          textAlign: TextAlign.start,
        ),
      )
    ]);
  }

  Widget _flickrResults({AsyncSnapshot<List<FlickrBlocModel>> snapshot}) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy > 0) {
          if (_scrollController.offset < 0) {
            _scrollController.jumpTo(0);
            _scrollController1.jumpTo(0);
          }
          _scrollController.jumpTo(_scrollController.offset - details.delta.dy);
          _scrollController1.jumpTo(_scrollController1.offset - details.delta.dy);
        } else if (details.delta.dy < 0) {
          print('We are swiping down');
          double maxScroll = _scrollController.position.maxScrollExtent;
          double currentScroll = _scrollController.position.pixels;
          double maxScroll1 = _scrollController1.position.maxScrollExtent;
          double currentScroll1 = _scrollController1.position.pixels;

          /// lets say that we reached 99% of the screen
          double delta = 230; // or something else.. you have to do the math yourself
          if (maxScroll - currentScroll <= delta) {
            print('reached the end ?');

            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
          if (maxScroll1 - currentScroll1 <= delta) {
            print('reached the end ?');
            _scrollController1.jumpTo(_scrollController1.position.maxScrollExtent);
          }

          _scrollController.jumpTo(_scrollController.offset - details.delta.dy);
          _scrollController1.jumpTo(_scrollController1.offset - details.delta.dy);
        }
      },
      child: Container(
        color: Colors.black54, //background
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index.isEven) {
                    return Container(
                        height: 200, child: _cardWidget(snapshot, index));
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController1,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index.isOdd) {
                    return Container(
                        height: 300, child: _cardWidget(snapshot, index));
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void _searchUser(String searchQuery) {
    fetchRandomUsers(searchQuery);

    List<FlickrBlocModel> searchResult = [];
    flickrBloc.flickrController.sink.add(null);
    print('total results = ${totalResults.length}');
    if (searchQuery.isEmpty) {
      flickrBloc.flickrController.sink.add(totalResults);
      return;
    }
    totalResults.forEach((user) {
      if (user.tags.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        searchResult.add(user);
      }
    });
    print('searched users length = ${searchResult.length}'); //
    flickrBloc.flickrController.sink.add(searchResult);
  }

  Future<void> fetchRandomUsers(String searchQuery) async {
    String searchParam = searchQuery;
    FLICKR_URL = "https://api.flickr.com/services/feeds/photos_public.gne?tagmode=any&format=json&nojsoncallback=1&tags=<$searchParam>";

    http.Response response = await http.get(FLICKR_URL);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      final Iterable list = body["items"];
      totalResults = list.map((model) => FlickrBlocModel.fromJson(model)).toList();
      flickrBloc.flickrController.sink.add(totalResults);
    }
  }

  int random;
  List<FlickrBlocModel> totalResults = [];
  Random rng = Random();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (text) => _searchUser(text),
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search',
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 3.1, color: Colors.black54),
                        borderRadius: BorderRadius.circular(30))),
              ),
            ),
            Container(
              height: 50,
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: tabBarTitle.length,
                itemBuilder: (BuildContext context, int x) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = x;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.white
                              )
                          )
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${tabBarTitle[x]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
                child: flickrResultsWidget()
            )
          ],
        ),
      ),
    );
  }
}
