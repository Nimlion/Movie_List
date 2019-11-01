import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';

/*
* Everything what has to do with searching through the list.
* programmer: Hosam Darwish
*/
class SearchScreen extends StatefulWidget {
  // Declare a field that holds the searchable list.
  final List<Movie> iterableList;

  // In the constructor, require a list.
  SearchScreen({Key key, @required this.iterableList}) : super(key: key);

  @override
  _SearchState createState() => _SearchState(iterableList);
}

class _SearchState extends State<SearchScreen> {
  // Declare a field that holds the searchable list.
  List<Movie> initialList;
  List<Movie> searchedList = new List<Movie>();
  String _searchText = "";
  bool typing = false;
  TextEditingController _searchController = new TextEditingController();

  _SearchState(this.initialList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(color: Colors.white, fontSize: Repo.currentFont + 5),
          onChanged: (text) {
            _searchText = text;
            if (_searchText != "") {
              setState(() {
                if (_searchText != "") {
                  searchedList.clear();
                  initialList.forEach((movie) {
                    if (movie.getTitle().toLowerCase().contains(_searchText)) {
                      print("SEARCHED SEARCHED SEARCHED SEARCHED");
                      searchedList.add(movie);
                    }
                  });
                }
              });
            } else {
              print("NOT SEARCHED, NOT SEARCHED, NOT SEARCHED");
              setState(() {
                _searchText = "";
                searchedList.clear();
              });
            }
          },
          decoration: InputDecoration(
              hintText: 'Search',
              focusColor: Colors.white,
              hoverColor: Colors.white,
              fillColor: Colors.white,
              hintStyle: TextStyle(
                  color: Colors.white, fontSize: Repo.currentFont + 5)),
          controller: _searchController,
        ),
      ),
      body: _buildMovieList(),
    );
  }

  Widget _buildMovieList() {
    if (searchedList.length == 0) {
      return new Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Please type something above.",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: Repo.currentFont + 10,
                  textBaseline: TextBaseline.alphabetic))
        ],
      ));
    } else {
      return new Scaffold(
        body: ListView.builder(
          itemBuilder: (context, index) {
            // itemBuilder will be automatically be called as many times as it takes for the
            // list to fill up its available space, which is most likely more than the
            // number of watched movie the user has. So, we need to check the index is OK.
            if (index < searchedList.length) {
              return _buildMovieItem(searchedList[index], index);
            }
          },
        ),
      );
    }
  }

  // Build a single movie item
  Widget _buildMovieItem(Movie movie, int index) {
    // Create a listtile with icon, title and date
    return new ListTile(
      leading: Icon(Icons.movie),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: Repo.currentFont,
            color: Colors.deepOrange),
      ),
      subtitle: new Text(DateFormat('d MMM. yyyy')
          .format(movie.getDate())
          .toString()
          .toLowerCase()),
      onTap: () => {},
      onLongPress: () => {},
      dense: false,
    );
  }
}
