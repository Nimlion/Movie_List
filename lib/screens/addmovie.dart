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
class AddScreen extends StatefulWidget {
  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddScreen> {
  // Build the add page including appbar and textfield
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text('Add a new movie')),
        body: new TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (val) {
            _addMovie(val);
            Navigator.pop(context); // Close the add todo screen
          },
          decoration: new InputDecoration(
              hintText: 'Enter the movie\'s name',
              contentPadding: const EdgeInsets.all(16.0)),
        ));
  }

  // Add a new movie to the list of movies
  void _addMovie(String newMovie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Only add the task if the user actually entered something
    // and if the movie doesn't already exist
    if (newMovie.length > 1 && newMovie.trim() != "") {
      if (Movie.movieDoesExist(newMovie.toLowerCase()) == true) {
        // Show a notification if the movie already exists
        showSimpleNotification(
          Text("This movie already exists."),
          background: Colors.redAccent,
        );
      } else {
        // Add the movie to the list and rerender the list (through setState)
        setState(() {
          Movie toAddMovie = new Movie(DateTime.now(), newMovie);
          Repo.movieItems.add(toAddMovie);
          prefs.setString(Repo.movieKey, jsonEncode(Repo.movieItems));
          // Sort the list again
          Movie.sortListAlphabetically(Repo.movieItems);
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
