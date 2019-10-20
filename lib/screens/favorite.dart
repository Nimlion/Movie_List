import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:to_do/screens/addmovie.dart';

/*
* Everything what has to do with the favorite movies of the user can be found here.
* programmer: Hosam Darwish
*/
class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<FavoriteScreen> {
  // Create the favorite screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFavoritesList(),
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
                  Movie.sortListAlphabetically(Repo.saved);
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
                  Movie.sortListByLatest(Repo.saved);
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
                onPressed: () {},
                icon: new Icon(Icons.search, size: 30),
                label: new Text("Search", style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  // Send the user to the add movie screen
  void _pushAddMovieScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => AddScreen()),
    );
  }

  // Build the whole list of favorite movies
  Widget _buildFavoritesList() {
    if (Repo.saved.length == 0) {
      return new Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("U currently have 0 favorites.",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: Repo.largerFont,
                  textBaseline: TextBaseline.alphabetic))
        ],
      ));
    } else {
      return new ListView.builder(
        itemBuilder: (context, index) {
          // itemBuilder will be automatically be called as many times as it takes for the
          // list to fill up its available space, which is most likely more than the
          // number of movie items we have. So, we need to check the index is OK.
          if (index < Repo.saved.length) {
            return _buildFavoriteItem(Repo.saved[index], index);
          }
        },
      );
    }
  }

  // Build a single favorite movie for within a list
  Widget _buildFavoriteItem(Movie movie, int index) {
    final bool alreadySaved = Repo.saved.contains(movie);

    return new ListTile(
      leading: IconButton(
        icon: new Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onPressed: () => setState(() {
          _saveFavoriteMovie(movie);
        }),
        padding: EdgeInsets.all(0),
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
  void _saveFavoriteMovie(Movie favMovie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadySaved = Repo.saved.contains(favMovie);

    setState(() {
      // If the movie is not in the favorite list yet, add the movie. Else remove the movie from the favorite list
      if (alreadySaved) {
        Repo.saved.remove(favMovie);
      } else {
        Repo.saved.add(favMovie);
      }
      prefs.setString(Repo.favoriteKey, jsonEncode(Repo.saved));
    });

    // Sort the favorite list
    Movie.sortListAlphabetically(Repo.saved);
  }
}
