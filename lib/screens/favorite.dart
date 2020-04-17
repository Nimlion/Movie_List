import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';
import 'package:to_do/screens/addscreen.dart';
import 'package:to_do/screens/search.dart';
import 'package:to_do/models/state.dart';
import 'package:unicorndial/unicorndial.dart';

/*
* Everything what has to do with the favorite movies of the user can be found here.
* programmer: Hosam Darwish
*/
class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<FavoriteScreen> {
  List<Movie> favoritesList = Repo.watched.where((movie) => movie.getStatus() == MovieStatus.favorite).toList();

  // Create the favorite screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFavoritesList(),
    );
  }

  // Send the user to the add movie screen
  void _pushAddMovieScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder: (context) =>
              AddMovieScreen(list: favoritesList, keyString: Repo.movieKey)),
    );
  }

  // Send the user to the add movie screen
  void _pushSearchScreen(List<Movie> searchList) {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder: (context) => SearchScreen(iterableList: searchList)),
    );
  }

  // Build the whole list of favorite movies
  Widget _buildFavoritesList() {
    if (favoritesList.length == 0) {
      return new Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10),
              child: Text("U currently have 0 favorites.",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: Repo.currentFont + 5.0,
                      textBaseline: TextBaseline.alphabetic))),
        ],
      ));
    } else {
      return Scaffold(
        body: new ListView.builder(
          itemBuilder: (context, index) {
            // itemBuilder will be automatically be called as many times as it takes for the
            // list to fill up its available space, which is most likely more than the
            // number of movie items we have. So, we need to check the index is OK.
            if (index < favoritesList.length) {
              return _buildFavoriteItem(favoritesList[index], index);
            } else {
              return null;
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 12.0),
          child: UnicornDialer(
            parentHeroTag: 'favoriteFAB',
            hasBackground: false,
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.sort),
            childButtons: <UnicornButton>[
              UnicornButton(
                  currentButton: FloatingActionButton(
                heroTag: 'favAZFAB',
                mini: true,
                child: Icon(Icons.sort_by_alpha),
                onPressed: () {
                  setState(() {
                    Movie.sortListAlphabetically(favoritesList);
                  });
                },
              )),
              UnicornButton(
                  currentButton: FloatingActionButton(
                heroTag: 'favLatestFAB',
                mini: true,
                child: Icon(Icons.date_range),
                onPressed: () {
                  setState(() {
                    Movie.sortListByLatest(favoritesList);
                  });
                },
              )),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton.icon(
                  onPressed: () {
                    _pushAddMovieScreen();
                  },
                  icon: new Icon(Icons.add, size: 30),
                  label: new Text("Add", style: TextStyle(fontSize: 16))),
              FlatButton.icon(
                  onPressed: () {
                    _pushSearchScreen(favoritesList);
                  },
                  icon: new Icon(Icons.search, size: 30),
                  label: new Text("Search", style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      );
    }
  }

  // Build a single favorite movie for within a list
  Widget _buildFavoriteItem(Movie movie, int index) {
    final bool alreadySaved = favoritesList.contains(movie);

    return new ListTile(
      leading: IconButton(
        icon: new Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onPressed: () => setState(() {
          _saveFavoriteMovie(movie, index);
        }),
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      ),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: Repo.currentFont,
            color: Color(0xFFb5525c),
            fontStyle: FontStyle.italic,
            letterSpacing: 1),
      ),
      dense: false,
    );
  }

  // Save or remove a movie from the favorite list
  void _saveFavoriteMovie(Movie favMovie, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadySaved = favoritesList[index].getStatus() == MovieStatus.favorite;

    setState(() {
      // If the movie is not in the favorite list yet, add the movie. Else remove the movie from the favorite list
      if (alreadySaved) {
        favoritesList[index].setStatus(MovieStatus.normal);
      } else {
        favoritesList[index].setStatus(MovieStatus.favorite);
      }
      prefs.setString(Repo.movieKey, jsonEncode(Repo.watched));
    });

    // Sort the favorite list
    Movie.sortListAlphabetically(favoritesList);
  }
}
