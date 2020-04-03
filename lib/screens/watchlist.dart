import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';
import 'package:to_do/screens/addscreen.dart';
import 'package:unicorndial/unicorndial.dart';

/*
* Everything what has to do with the future movies of the user can be found here.
* programmer: Hosam Darwish
*/
class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<WatchlistScreen> {
  // Create the watch later screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWatchList(),
    );
  }

  // Build the whole list of watch later movies
  Widget _buildWatchList() {
    if (Repo.future.length == 0) {
      return new Scaffold(
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("U currently have 0 movies in your watchlist.",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: Repo.currentFont + 5.0,
                        textBaseline: TextBaseline.alphabetic)),
              )
            ],
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _pushAddMovieScreen();
            },
            tooltip: 'Add a movie to watch',
            child: Icon(Icons.add),
          ));
    } else {
      return new Scaffold(
        body: ListView.builder(
          itemBuilder: (context, index) {
            // itemBuilder will be automatically be called as many times as it takes for the
            // list to fill up its available space, which is most likely more than the
            // number of movie items we have. So, we need to check the index is OK.
            if (index < Repo.future.length) {
              return _buildWatchItem(Repo.future[index], index);
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
                    Movie.sortListAlphabetically(Repo.future);
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
                    Movie.sortListByEarliest(Repo.future);
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
            ],
          ),
        ),
      );
    }
  }

  // Send the user to the add movie screen
  void _pushAddMovieScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => AddMovieScreen(list: Repo.future, keyString: Repo.futureKey,)),
    );
  }

  // Build a single watch later movie for within a list
  Widget _buildWatchItem(Movie movie, int index) {
    return new ListTile(
      leading: Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Icon(Icons.watch_later),
      ),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: Repo.currentFont,
            color: Colors.purple,
            letterSpacing: 1.5),
      ),
      subtitle: new Text(DateFormat('d MMM. yyyy')
          .format(movie.getDate())
          .toString()
          .toLowerCase()),
      dense: false,
      trailing: Checkbox(
        value: false,
        onChanged: (bool checked) {
          // Als hij true is dan word de movie toegevoegd aan saved + prefs en verwijderd van de watchlist (maar alleen als hij is toegevoegd (try with resources)).
          sendToWatched(index, movie);
        },
      ),
    );
  }

// Send the movie to the watched list and remove from the watchlater list
  void sendToWatched(int index, Movie newMovie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      try {
        newMovie.setDate(DateTime.now());
        Repo.watched.add(newMovie);
        prefs.setString(Repo.movieKey, jsonEncode(Repo.watched));

        // Sort the list again
        Movie.sortListAlphabetically(Repo.watched);

        // Remove from the watchlist
        Repo.future.removeAt(index);
        prefs.setString(Repo.futureKey, jsonEncode(Repo.future));
      } catch (e) {}
    });
  }
}
