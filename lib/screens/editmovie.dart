import 'dart:convert';

import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';
import 'package:to_do/models/state.dart';

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

  Movie initialMovie;
  Movie movie;
  TextEditingController _controller = new TextEditingController();

  _EditMovieState(this.watchedIndex);

  // Retrieve the indexes for both lists.
  @override
  void initState() {
    this.initialMovie = Repo.watched.elementAt(watchedIndex);
    this.movie = new Movie(
        this.initialMovie.getDate(),
        this.initialMovie.getTitle(),
        this.initialMovie.getStatus(),
        this.initialMovie.getRating());

    _controller.text = "${movie.getTitle()}";
    super.initState();
  }

  // Build the add page including appbar and textfield
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

// DUPLICATE
    String capitalize(String badText) {
      return badText[0].toUpperCase() + badText.substring(1);
    }

    return Scaffold(
        appBar: new AppBar(title: new Text('Edit ${movie.getTitle()}')),
        body: new Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Text("Enter the movie's name",
                    style: TextStyle(
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.deepPurple,
                        fontSize: Repo.currentFont + 5,
                        fontWeight: FontWeight.w900)),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 30, 10),
                child: new TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (val) {
                    movie.setTitle(val);
                  },
                  textCapitalization: TextCapitalization.words,
                  decoration: new InputDecoration(
                      hintText: 'Enter the movie\'s name',
                      contentPadding: const EdgeInsets.all(16.0)),
                  style: TextStyle(fontSize: Repo.currentFont + 2),
                ),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Text("Rate the movie",
                    style: TextStyle(
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.deepPurple,
                        fontSize: Repo.currentFont + 5,
                        fontWeight: FontWeight.w900)),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 25, 10),
                child: new Slider.adaptive(
                  value: movie.getRating(),
                  onChanged: (newValue) {
                    setState(() {
                      movie.setRating(newValue);
                    });
                  },
                  label: "${movie.getRating()}",
                  min: 0,
                  max: 10,
                  divisions: 20,
                ),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                child: Text("Store in",
                    style: TextStyle(
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.deepPurple,
                        fontSize: Repo.currentFont + 5,
                        fontWeight: FontWeight.w900)),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                child: new DropdownButton<MovieStatus>(
                  items: (MovieStatus.values.map((MovieStatus status) {
                    return new DropdownMenuItem<MovieStatus>(
                      value: status,
                      child: new Text(capitalize(status
                          .toString()
                          // Remove the type in front of the enum
                          .substring(status.toString().indexOf('.') + 1))),
                    );
                  })).toList(),
                  onChanged: (value) {
                    movie.setStatus(value);
                  },
                  value: movie.getStatus(),
                  elevation: 2,
                  style: TextStyle(
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.deepPurple,
                    fontSize: Repo.currentFont + 3,
                  ),
                  isDense: false,
                  iconSize: 40.0,
                ),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 30, 25, 0),
                child: new RaisedButton.icon(
                  onPressed: () {
                    _editMovie(movie);
                    Navigator.pop(context); // Close the add todo screen
                  },
                  color: brightness == Brightness.dark
                      ? Colors.teal
                      : Colors.deepPurple,
                  icon: new Icon(
                    Icons.check,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.purpleAccent,
                  ),
                  label: new Text("Save",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Repo.currentFont + 2)),
                ),
              ),
            ],
          ),
        ));
  }

  // Edit the title of the movie from the list of movies
  void _editMovie(Movie editedMovie) async {
    var brightness = MediaQuery.of(context).platformBrightness;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // The unedited movie
    Movie original = Repo.watched.elementAt(watchedIndex);

    // Only add the task if the user actually entered something
    // and if the movie doesn't already exist
    if (editedMovie.getTitle().length > 1 &&
        editedMovie.getTitle().trim() != "") {
      if (original == editedMovie &&
          original.getRating() == editedMovie.getRating() &&
          original.getStatus() == editedMovie.getStatus()) {
        // Show a notification if the movie title is the same
        showSimpleNotification(
          Text("The movie title hasn't changed."),
          background: Colors.redAccent,
        );
      } else if (Movie.movieExistsInWatched(
              watchedIndex, editedMovie.getTitle().toLowerCase()) ==
          true) {
        // Show a notification if the movie already exists
        showSimpleNotification(
          Text("This movie already exists."),
          background: Colors.redAccent,
        );
      } else {
        // Add the movie to the list and rerender the list (through setState)
        setState(() {
          Repo.watched[watchedIndex] = editedMovie;

          // Save the list again
          prefs.setString(Repo.movieKey, jsonEncode(Repo.watched));

          // Sort the list again
          Movie.sortListAlphabetically(Repo.watched);

          showSimpleNotification(
            Text("Movie succesfully edited."),
            background: brightness == Brightness.dark
                ? Colors.tealAccent
                : Colors.deepPurpleAccent,
          );
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
