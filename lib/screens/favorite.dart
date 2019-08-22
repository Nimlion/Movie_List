import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';

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
      appBar: new AppBar(
        title: new Text('My Movie List'),
      ),
      body: _buildFavoritesList(),
    );
  }

  // Build the whole list of favorite movies
  Widget _buildFavoritesList() {
    if (Repo.saved.length == 0) {
      return new Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("U currently have 0 favorites",
              style: new TextStyle(
                fontSize: Repo.normalFont,
              ))
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
      leading: Icon(Icons.movie),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(fontFamily: 'Raleway', fontSize: Repo.normalFont),
      ),
      trailing: IconButton(
          icon: new Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onPressed: () => setState(() {
                _saveFavoriteMovie(movie);
              })),
      onTap: () => setState(() {
        _promptRemoveFavoriteMovie(index);
      }),
      dense: false,
    );
  }

  // Show a promp to the user whether the movie can be deleted
  void _promptRemoveFavoriteMovie(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete ${Repo.saved[index].getTitle()} ?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Cancel'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Delete'),
                    onPressed: () {
                      setState(() {
                        _removeFromSavedMovieList(index);
                        Navigator.of(context).pop();
                      });
                    })
              ]);
        });
  }

  // Remove a movie from the favorite screen
  void _removeFromSavedMovieList(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Movie film = Repo.saved.elementAt(index);
      int movieIndex = Repo.movieItems.indexOf(film);

      _removeFavoriteMovie(film);
      prefs.setString(Repo.favoriteKey, json.encode(Repo.saved));
      Repo.movieItems.removeAt(movieIndex);
      prefs.setString(Repo.movieKey, json.encode(Repo.movieItems));
    });
  }

  // Remove a movie from the favorite list
  void _removeFavoriteMovie(Movie badMovie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove and rerender the favorite list
    setState(() {
      Repo.saved.remove(badMovie);
      prefs.setString(Repo.favoriteKey, json.encode(Repo.saved));
    });
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
