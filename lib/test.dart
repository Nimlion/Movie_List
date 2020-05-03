// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlay_support/overlay_support.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(new MovieListApp());

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

class MovieList extends StatefulWidget {
  MovieList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  createState() => new MovieState();
}

class Movie {
  String _title;
  DateTime _addedDate;

  Movie(DateTime date, String name) {
    this._addedDate = date;
    this._title = name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie &&
          runtimeType == other.runtimeType &&
          _title == other._title;

  @override
  int get hashCode => _title.hashCode;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return new Movie(DateTime.parse(json['date']), json['title']);
  }

  toJson() {
    return {
      'title': _title,
      'date': _addedDate.toString(),
    };
  }

  String getTitle() {
    return this._title;
  }

  DateTime getDate() {
    return this._addedDate;
  }
}

class MovieState extends State<MovieList> {
  final _normalFont = 14.0;
  List<Movie> _movieItems = [];
  List<Movie> _saved = [];
  final String movieKey = 'list';
  final String favoriteKey = 'saved';

  @override
  void initState() {
    _loadList();

    super.initState();
  }

  // Loading counter value on start
  _loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getString(movieKey) != null) {
        json
            .decode(prefs.getString(movieKey))
            .forEach((map) => _movieItems.add(Movie.fromJson(map)));
      }

      if (prefs.getString(favoriteKey) != null) {
        json
            .decode(prefs.getString(favoriteKey))
            .forEach((map) => _saved.add(Movie.fromJson(map)));
      }

      // print("saved: ");
      // for (Movie film in _saved) {
      //   print("titel: " +
      //       film.getTitle() +
      //       " datum: " +
      //       film.getDate().toString());
      // }
      // print("movies: " + _movieItems.toString());

      sortListAlphabetically();
    });
  }

  void sortListAlphabetically() async {
    _movieItems.sort((a, b) {
      return a.getTitle().compareTo(b.getTitle());
    });
  }

  void sortListByLatest() async {
    _movieItems.sort((a, b) {
      return a.getDate().compareTo(b.getDate());
    });
  }

  bool movieDoesExist(String movie) {
    for (Movie object in _movieItems) {
      if (object.getTitle().toLowerCase() == movie) {
        return true;
      }
    }
    return false;
  }

  void _addMovie(String newMovie) async {
    var brightness = MediaQuery.of(context).platformBrightness;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Only add the task if the user actually entered something
    // and if the movie doesn't already exist
    if (newMovie.length > 1 && newMovie.trim() != "") {
      if (movieDoesExist(newMovie.toLowerCase()) == true) {
        showSimpleNotification(
          Text("This movie already exists."),
          background: brightness == Brightness.dark
              ? Colors.tealAccent
              : Colors.deepPurpleAccent,
        );
      } else {
        // Putting our code inside "setState" tells the app that our state has changed, and
        // it will automatically re-render the list
        setState(() {
          Movie toAddMovie = new Movie(DateTime.now(), newMovie);
          _movieItems.add(toAddMovie);
          prefs.setString(movieKey, jsonEncode(_movieItems));
          sortListAlphabetically();
        });
      }
    } else {
      showSimpleNotification(
        Text("Please enter a correct name."),
        background: brightness == Brightness.dark
            ? Colors.tealAccent
            : Colors.deepPurpleAccent,
      );
    }
  }

  void _saveFavoriteMovie(Movie favMovie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadySaved = _saved.contains(favMovie);

    setState(() {
      if (alreadySaved) {
        _saved.remove(favMovie);
      } else {
        _saved.add(favMovie);
      }
      prefs.setString(favoriteKey, jsonEncode(_saved));
    });
  }

  void _removeFavoriteMovie(Movie badMovie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _saved.remove(badMovie);
      prefs.setString(favoriteKey, json.encode(_saved));
    });
  }

  void _removeFromSavedMovieList(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Movie film = _saved.elementAt(index);
      int movieIndex = _movieItems.indexOf(film);

      _removeFavoriteMovie(film);
      prefs.setString(favoriteKey, json.encode(_saved));
      _movieItems.removeAt(movieIndex);
      prefs.setString(movieKey, json.encode(_movieItems));
    });
  }

  void _removeMovieFromList(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Movie movieText = _movieItems.elementAt(index);

      _removeFavoriteMovie(movieText);
      prefs.setString(favoriteKey, json.encode(_saved));
      _movieItems.removeAt(index);
      prefs.setString(movieKey, json.encode(_movieItems));
    });
  }

  void _promptRemoveMovie(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete "${_movieItems[index].getTitle()}" ?'),
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

  void _promptRemoveFavoriteMovie(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete "${_saved[index].getTitle()}" ?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Cancel'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Delete'),
                    onPressed: () {
                      _removeFromSavedMovieList(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // Build the whole list of todo items
  Widget _buildMovieList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of todo items we have. So, we need to check the index is OK.
        if (index < _movieItems.length) {
          return _buildMovieItem(_movieItems[index], index);
        } else {
          return null;
        }
      },
    );
  }

  // Build the whole list of todo items
  Widget _buildFavoritesList() {
    if (_saved.length == 0) {
      return new Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("U currently have 0 favorites",
              style: new TextStyle(
                fontSize: _normalFont,
              ))
        ],
      ));
    } else {
      return new ListView.builder(
        itemBuilder: (context, index) {
          // itemBuilder will be automatically be called as many times as it takes for the
          // list to fill up its available space, which is most likely more than the
          // number of movie items we have. So, we need to check the index is OK.
          if (index < _saved.length) {
            return _buildFavoriteItem(_saved[index], index);
          } else {
            return null;
          }
        },
      );
    }
  }

  // Build a single todo item
  Widget _buildMovieItem(Movie movie, int index) {
    final bool alreadySaved = _saved.contains(movie);

    // final bool alreadySaved = (indexOfMovie == -1) ? true : false;

    return new ListTile(
      leading: Icon(Icons.movie),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: _normalFont,
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

  // Build a single favorite movie
  Widget _buildFavoriteItem(Movie movie, int index) {
    final bool alreadySaved = _saved.contains(movie);

    return new ListTile(
      leading: Icon(Icons.movie),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(fontFamily: 'Raleway', fontSize: _normalFont),
      ),
      trailing: IconButton(
          icon: new Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onPressed: () {
            _saveFavoriteMovie(movie);
          }),
      onTap: () => _promptRemoveFavoriteMovie(index),
      dense: false,
    );
  }

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

  void _pushSaved() {
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well as adding
        // a back button to close it
        new MaterialPageRoute(builder: (context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('My Favorites'),
        ),
        body: _buildFavoritesList(),
      );
    }));
  }

  void _pushAddMovieScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well as adding
        // a back button to close it
        new MaterialPageRoute(builder: (context) {
      return new Scaffold(
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
    }));
  }
}
