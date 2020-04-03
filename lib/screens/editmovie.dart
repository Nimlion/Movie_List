import 'dart:convert';

import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';

/*
* Everything what has to do with the adding of movies can be found here.
* programmer: Hosam Darwish
*/
class EditScreen extends StatefulWidget {
  // Declare a field that holds the to be edited movie.
  final int movieIndex;

  // In the constructor, require the postion of the to be edited movie.
  EditScreen({Key key, @required this.movieIndex}) : super(key: key);

  @override
  _EditMovieState createState() => _EditMovieState(movieIndex);
}

class _EditMovieState extends State<EditScreen> {
  // Declare a field that holds the to be edited movie.
  final int watchedIndex;

  int savedIndex;
  Movie movie;
  TextEditingController _controller = new TextEditingController();

  _EditMovieState(this.watchedIndex);

  // Retrieve the indexes for both lists.
  @override
  void initState() {
    this.movie = Repo.watched.elementAt(watchedIndex);
    this.savedIndex = Repo.saved.indexOf(movie);

    _controller.text = "${movie.getTitle()}";
    super.initState();
  }

  // Build the add page including appbar and textfield
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text('Edit ${movie.getTitle()}')),
        body: Padding(
          padding: EdgeInsets.fromLTRB(25, 50, 25, 0),
          child: new TextField(
            controller: _controller,
            autofocus: true,
            style: TextStyle(fontSize: Repo.currentFont + 6, wordSpacing: 2),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.send,
            onSubmitted: (val) {
              _editMovie(val);
              // Close this edit screen
              Navigator.pop(context);
            },
            decoration: new InputDecoration(
                labelText: 'Enter the new movie title',
                contentPadding: const EdgeInsets.all(12.0)),
          ),
        ));
  }

  // Edit the title of the movie from the list of movies
  void _editMovie(String newTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Only add the task if the user actually entered something
    // and if the movie doesn't already exist
    if (newTitle.length > 1 && newTitle.trim() != "") {
      if (this.movie.getTitle() == newTitle) {
        // Show a notification if the movie title is the same
        showSimpleNotification(
          Text("The movie title hasn't changed."),
          background: Colors.redAccent,
        );
      } else if (Movie.movieExistsInWatched(newTitle.toLowerCase()) == true) {
        // Show a notification if the movie already exists
        showSimpleNotification(
          Text("This movie already exists."),
          background: Colors.redAccent,
        );
      } else {
        // Add the movie to the list and rerender the list (through setState)
        setState(() {
          if (savedIndex != -1) {
            Repo.saved[savedIndex].setTitle(newTitle);
          }
          Repo.watched[watchedIndex].setTitle(newTitle);

          // Save the list again
          prefs.setString(Repo.movieKey, jsonEncode(Repo.watched));
          prefs.setString(Repo.favoriteKey, jsonEncode(Repo.saved));

          // Sort the list again
          Movie.sortListAlphabetically(Repo.watched);
          Movie.sortListAlphabetically(Repo.saved);
        });
      }
    } else {
      // Show a notification if the movie title is invalid
      showSimpleNotification(
        Text("Please enter a correct name."),
        background: Colors.redAccent,
      );
    }
  }
}
