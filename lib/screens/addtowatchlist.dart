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
class AddWatchlistScreen extends StatefulWidget {
  @override
  _AddWatchListState createState() => _AddWatchListState();
}

class _AddWatchListState extends State<AddWatchlistScreen> {
  String _titleValue = '';
  String _dateValue = '';

  // Build the add page including appbar and textfield
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

    return Scaffold(
        appBar: new AppBar(title: new Text('Add a upcoming movie')),
        body: new Container(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
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
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                  child: new RaisedButton(
                    onPressed: _selectDate,
                    color: brightness == Brightness.dark ? Colors.teal : Colors.white,
                    child: new Text(
                      'Select Date',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Repo.largeFont,
                          color: brightness == Brightness.dark ? Colors.white : Colors.deepPurple),
                    ),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(25, 50, 25, 15),
                  child: new RaisedButton.icon(
                    onPressed: () {
                      _addMovie(_titleValue, _dateValue);
                      Navigator.pop(context); // Close the add todo screen
                    },
                    color: brightness == Brightness.dark ? Colors.teal : Colors.deepPurple,
                    icon: new Icon(
                      Icons.check,
                      color: brightness == Brightness.dark ? Colors.white : Colors.purpleAccent,
                    ),
                    label: new Text("Add to watchlist",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Repo.largeFont)),
                  ),
                ),
              ],
            ),
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
  void _addMovie(String movieTitle, String movieDate) async {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Only add the task if the user actually entered something
    // and if the movie doesn't already exist
    if (movieTitle.length > 1 && movieTitle.trim() != "") {
      if (Movie.movieDoesExist(movieTitle.toLowerCase()) == true) {
        // Show a notification if the movie already exists
        showSimpleNotification(
          Text("This movie already exists."),
          background: Colors.redAccent,
        );
      } else {
        // Add the movie to the list and rerender the list (through setState)
        setState(() {
          try {
            Movie toAddMovie = new Movie(movieDateTime, movieTitle);
            Repo.future.add(toAddMovie);
            prefs.setString(Repo.futureKey, jsonEncode(Repo.future));
            // Sort the list again
            Movie.sortListByLatest(Repo.future);
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
  }
}
