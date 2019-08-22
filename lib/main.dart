import 'dart:convert';

import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';
import 'package:to_do/screens/addmovie.dart';
import 'package:to_do/screens/favorite.dart';

/*
* Everything what has to do with the favorite movies of the user can be found here.
* programmer: Hosam Darwish
*/

// Run a new app
void main() => runApp(new MovieListApp());

// Create a new app
class MovieListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
            title: 'My Movie List',
            theme: ThemeData(
                primarySwatch: Colors.deepOrange,
                primaryColor: Colors.deepPurple,
                fontFamily: 'Raleway'),
            home: new MovieList()));
  }
}

// Create a new state that listens to the users actions
class MovieList extends StatefulWidget {
  MovieList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  createState() => new MovieState();
}

// Start new State for the movie page
class MovieState extends State<MovieList> {
  @override
  void initState() {
    _loadList();

    super.initState();
  }

  // Loading all the movie lists on startup
  _loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // Loop over all the added movies and add them to the List of movies
      if (prefs.getString(Repo.movieKey) != null) {
        json
            .decode(prefs.getString(Repo.movieKey))
            .forEach((map) => Repo.movieItems.add(Movie.fromJson(map)));
      }

      // Loop over all the favorited movies and add them to the List of favorite movies
      if (prefs.getString(Repo.favoriteKey) != null) {
        json
            .decode(prefs.getString(Repo.favoriteKey))
            .forEach((map) => Repo.saved.add(Movie.fromJson(map)));
      }

      // Sort the saved list alphabetically
      Movie.sortListAlphabetically(Repo.saved);

      // Sort the movie list alphabetically
      Movie.sortListAlphabetically(Repo.movieItems);
    });
  }

  // Build the homepage including appbar and list of watched movies
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('My Movie List'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildMovieList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddMovieScreen,
          tooltip: 'Add movie',
          child: new Icon(Icons.add)),
    );
  }

  // Remove a movie from the list of watched movies
  void _removeMovieFromList(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove the movie from the favorite list and from the watched list and rerender the list
    setState(() {
      Movie movieText = Repo.movieItems.elementAt(index);

      _removeFavoriteMovie(movieText);
      prefs.setString(Repo.favoriteKey, json.encode(Repo.saved));
      Repo.movieItems.removeAt(index);
      prefs.setString(Repo.movieKey, json.encode(Repo.movieItems));
    });
  }

  // Show a prompt to the user to confirm he wants to delete a movie he watched
  void _promptRemoveMovie(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title:
                  new Text('Delete ${Repo.movieItems[index].getTitle()} ?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Cancel'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Delete'),
                    onPressed: () {
                      _removeMovieFromList(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // Build the entire list of watched movies
  Widget _buildMovieList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of watched movie the user has. So, we need to check the index is OK.
        if (index < Repo.movieItems.length) {
          return _buildMovieItem(Repo.movieItems[index], index);
        }
      },
    );
  }

  // Build a single movie item
  Widget _buildMovieItem(Movie movie, int index) {
    // check if the movie is saved
    final bool alreadySaved = Repo.saved.contains(movie);

    // Create a listtile with icon, title, date and wether the movie is saved or not
    return new ListTile(
      leading: Icon(Icons.movie),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: Repo.normalFont,
            color: Colors.deepOrange),
      ),
      subtitle:
          new Text(DateFormat('dd-MM-yyyy').format(movie.getDate()).toString()),
      trailing: IconButton(
          icon: new Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onPressed: () {
            _saveFavoriteMovie(movie);
          }),
      onTap: () => _promptRemoveMovie(index),
      dense: false,
    );
  }

  // Send the user to the add movie screen
  void _pushAddMovieScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => AddScreen()),
    );
  }

  // Send the user to the saved movies screen
  void _pushSaved() {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => FavoriteScreen()),
    );
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
