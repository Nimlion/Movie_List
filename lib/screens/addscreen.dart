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
class AddMovieScreen extends StatefulWidget {
  // Declare a field that holds the to be edited movie.
  final List<Movie> list;
  final String keyString;

  // In the constructor, require a list.
  AddMovieScreen({Key key, @required this.list, @required this.keyString})
      : super(key: key);

  @override
  _AddMovieState createState() => _AddMovieState(list, keyString);
}

class _AddMovieState extends State<AddMovieScreen> {
  // Declare a field that holds the to be edited movie.
  final List<Movie> _list;
  final String _keyString;

  String _titleValue = '';
  String _dateValue = '';
  double _rating = 0;
  MovieStatus _status = MovieStatus.normal;

  _AddMovieState(this._list, this._keyString);

  // Build the add page including appbar and textfield
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

    String capitalize(String badText) {
      return badText[0].toUpperCase() + badText.substring(1);
    }

    return Scaffold(
        appBar: new AppBar(title: new Text('Add a movie')),
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
                  autofocus: true,
                  onChanged: (val) {
                    _titleValue = val;
                  },
                  onSubmitted: (val) {
                    _titleValue = val;
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
                  value: _rating,
                  onChanged: (newValue) {
                    setState(() => _rating = newValue);
                  },
                  label: "$_rating",
                  min: 0,
                  max: 10,
                  divisions: 20,
                  activeColor: brightness == Brightness.dark
                      ? Colors.tealAccent
                      : Colors.deepOrange,
                  inactiveColor: brightness == Brightness.dark
                      ? Colors.teal
                      : Colors.orange,
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
                    setState(() {
                      _status = value;
                    });
                  },
                  value: _status,
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
                padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Text("Select when the movie was watched",
                    style: TextStyle(
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.deepPurple,
                        fontSize: Repo.currentFont + 5,
                        fontWeight: FontWeight.w900)),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 15, 25, 10),
                child: new RaisedButton(
                  onPressed: _selectDate,
                  color: brightness == Brightness.dark
                      ? Colors.teal
                      : Colors.white,
                  child: new Text(
                    'Pick a date',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Repo.currentFont + 2,
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.deepPurple),
                  ),
                ),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(25, 30, 25, 0),
                child: new RaisedButton.icon(
                  onPressed: () {
                    _addMovie(_titleValue, _dateValue, _status, _rating, _list);
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
                  label: new Text("Add movie",
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

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    if (picked != null) setState(() => _dateValue = picked.toString());
  }

  // Add a new movie to the list of movies
  void _addMovie(String movieTitle, String movieDate, MovieStatus status,
      double rating, List<Movie> list) async {
    var brightness = MediaQuery.of(context).platformBrightness;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime movieDateTime;

    try {
      movieDate = movieDate.replaceAll('-', '');
      movieDate = movieDate.replaceAll(' ', '');
      movieDate = movieDate.replaceAll(':', '');
      movieDate = movieDate.substring(0, 8) + 'T' + movieDate.substring(8);
      movieDateTime = DateTime.parse(movieDate);
    } catch (identifier) {
      movieDateTime = DateTime.now();
    }

    // Only add the task if the user actually entered something
    // and if the movie doesn't already exist
    if (movieTitle.length > 1 && movieTitle.trim() != "") {
      if (Movie.movieExistsInToWatch(movieTitle.toLowerCase()) == true ||
          Movie.movieExistsInWatched(-1, movieTitle.toLowerCase()) == true) {
        // Show a notification if the movie already exists
        showSimpleNotification(
          Text("This movie already exists."),
          background: Colors.redAccent,
        );
      } else {
        // Add the movie to the list and rerender the list (through setState)
        setState(() {
          try {
            Movie toAddMovie =
                new Movie(movieDateTime, movieTitle, status, rating);
            list.add(toAddMovie);

            // Sort the list again
            Movie.sortListByLatest(list);

            prefs.setString(_keyString, jsonEncode(list));

            showSimpleNotification(
              Text("Movie succesfully added."),
              background: brightness == Brightness.dark
                        ? Colors.tealAccent
                        : Colors.deepPurpleAccent,
            );
          } catch (identifier) {
            showSimpleNotification(
              Text("Error: " + identifier.toString()),
              background: Colors.redAccent,
            );
          }
        });
      }
    } else {
      // Show a notification if the movie title is invalid
      showSimpleNotification(
        Text("Please enter a correct name."),
        background: Colors.redAccent,
      );
    }

    print("saved: ");
    for (Movie film in Repo.future) {
      print("titel: " +
          film.getTitle() +
          " datum: " +
          film.getDate().toString() +
          " status: " +
          film.getStatus().toString());
    }
    print("movies: " + Repo.future.toString());

    print("saved: ");
    for (Movie film in Repo.watched) {
      print("titel: " +
          film.getTitle() +
          " datum: " +
          film.getDate().toString() +
          " status: " +
          film.getStatus().toString());
    }
    print("movies: " + Repo.future.toString());
  }
}
