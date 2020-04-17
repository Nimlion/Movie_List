import 'dart:convert';

import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do/models/movie.dart';
import 'package:to_do/models/repository.dart';
import 'package:to_do/models/state.dart';
import 'package:to_do/screens/addscreen.dart';
import 'package:to_do/screens/editmovie.dart';
import 'package:to_do/screens/favorite.dart';
import 'package:to_do/screens/search.dart';
import 'package:to_do/screens/watchlist.dart';
import 'package:unicorndial/unicorndial.dart';

/*
* Everything what has to do with the watched movies of the user can be found here.
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
                brightness: Brightness.light,
                fontFamily: 'Alexandria'),
            darkTheme: ThemeData(
              primarySwatch: Colors.deepOrange,
              primaryColor: Colors.black,
              brightness: Brightness.dark,
            ),
            home: DefaultTabController(length: 3, child: new MovieList())));
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
    _loadPrefs();

    super.initState();
  }

  // Loading all the movie lists on startup
  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // Loop over all the added movies and add them to the List of movies
      if (prefs.getString(Repo.movieKey) != null) {
        json
            .decode(prefs.getString(Repo.movieKey))
            .forEach((map) => Repo.watched.add(Movie.fromJson(map)));
      }

      // Loop over all the favorited movies and add them to the List of favorite movies
      if (prefs.getString(Repo.futureKey) != null) {
        json
            .decode(prefs.getString(Repo.futureKey))
            .forEach((map) => Repo.future.add(Movie.fromJson(map)));
      }

      // Print all watched movies
      // print("saved: ");
      // for (Movie film in Repo.watched) {
      //   print("titel: " +
      //       film.getTitle() +
      //       " datum: " +
      //       film.getDate().toString() +
      //       " status: " +
      //       film.getStatus().toString());
      // }
      // print("movies: " + Repo.future.toString());

      // Sort the saved list alphabetically
      Movie.sortListByEarliest(Repo.future);

      // Sort the movie list alphabetically
      Movie.sortListAlphabetically(Repo.watched);
    });
  }

  // Build the homepage including appbar and list of watched movies
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Movie Gems',
          style: TextStyle(fontFamily: 'MotionPicture', fontSize: 35.0),
        ),
        centerTitle: true,
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.favorite)),
            Tab(icon: Icon(Icons.watch_later)),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text('Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'MotionPicture',
                        fontSize: Repo.currentFont + 20,
                        color: Colors.white)),
              ),
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? Colors.teal
                    : Colors.deepPurple,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
              child: Text(
                "Fontsize:",
                style: TextStyle(
                    fontSize: Repo.currentFont + 6,
                    fontWeight: FontWeight.bold,
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : Colors.deepPurple),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.local_florist,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepOrange,
              ),
              title: Text(
                'Grandma Fontsize',
                style: TextStyle(
                    fontSize: Repo.currentFont,
                    color: Repo.currentFont == Repo.largerFont
                        ? Colors.deepOrange
                        : brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  Repo.currentFont = Repo.largerFont;
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.local_pizza,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepOrange,
              ),
              title: Text(
                'Fat Fontsize',
                style: TextStyle(
                    fontSize: Repo.currentFont,
                    color: Repo.currentFont == Repo.largeFont
                        ? Colors.deepOrange
                        : brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  Repo.currentFont = Repo.largeFont;
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.offline_bolt,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepOrange,
              ),
              title: Text(
                'Boring Fontsize',
                style: TextStyle(
                    fontSize: Repo.currentFont,
                    color: Repo.currentFont == Repo.normalFont
                        ? Colors.deepOrange
                        : brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  Repo.currentFont = Repo.normalFont;
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.search,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepOrange,
              ),
              title: Text(
                'Asian Fontsize',
                style: TextStyle(
                    fontSize: Repo.currentFont,
                    color: Repo.currentFont == Repo.smallFont
                        ? Colors.deepOrange
                        : brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  Repo.currentFont = Repo.smallFont;
                });
              },
            ),
          ],
        ),
      ),
      body: TabBarView(children: [
        _buildMovieList(),
        FavoriteScreen(),
        WatchlistScreen(),
      ]),
    );
  }

  // Remove a movie from the list of watched movies
  void _removeMovieFromList(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove the movie from the favorite list and from the watched list and rerender the list
    setState(() {
      Repo.watched.removeAt(index);
      prefs.setString(Repo.movieKey, json.encode(Repo.watched));
    });
  }

  void _promptEditMovie(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Edit ${Repo.watched[index].getTitle()} ?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Cancel'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Edit'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pushEditScreen(index);
                    })
              ]);
        });
  }

  // Show a prompt to the user to confirm he wants to delete a movie he watched
  void _promptRemoveMovie(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete ${Repo.watched[index].getTitle()} ?'),
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
    if (Repo.watched == null || Repo.watched.length == 0) {
      return new Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                      "U currently 0 movies in this list add them down below.",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: Repo.currentFont + 5.0,
                          textBaseline: TextBaseline.alphabetic))),
            ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _pushAddMovieScreen(Repo.watched);
          },
          tooltip: 'Add a movie',
          child: Icon(Icons.add),
        ),
      );
    } else {
      return new Scaffold(
        body: ListView.builder(
          itemBuilder: (context, index) {
            // itemBuilder will be automatically be called as many times as it takes for the
            // list to fill up its available space, which is most likely more than the
            // number of watched movie the user has. So, we need to check the index is OK.
            if (index < Repo.watched.length) {
              return _buildMovieItem(Repo.watched[index], index);
            } else {
              return null;
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 12.0),
          child: UnicornDialer(
            parentHeroTag: 'homeFAB',
            hasBackground: false,
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.sort),
            childButtons: <UnicornButton>[
              UnicornButton(
                  currentButton: FloatingActionButton(
                heroTag: 'homeGemFAB',
                mini: true,
                child: Icon(Icons.dns),
                onPressed: () {
                  print("Movie.retrieveGems(Repo.watched).length");
                  print(Movie.retrieveGems(Repo.watched).length);
                },
              )),
              UnicornButton(
                  currentButton: FloatingActionButton(
                heroTag: 'homeAZFAB',
                mini: true,
                child: Icon(Icons.sort_by_alpha),
                onPressed: () {
                  setState(() {
                    Movie.sortListAlphabetically(Repo.watched);
                  });
                },
              )),
              UnicornButton(
                  currentButton: FloatingActionButton(
                heroTag: 'homeLatestFAB',
                mini: true,
                child: Icon(Icons.date_range),
                onPressed: () {
                  setState(() {
                    Movie.sortListByLatest(Repo.watched);
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
                    _pushAddMovieScreen(Repo.watched);
                  },
                  icon: new Icon(Icons.add, size: 30),
                  label: new Text("Add",
                      style: TextStyle(fontSize: Repo.currentFont))),
              FlatButton.icon(
                  onPressed: () {
                    _pushSearchScreen(Repo.watched);
                  },
                  icon: new Icon(Icons.search, size: 30),
                  label: new Text("Search",
                      style: TextStyle(fontSize: Repo.currentFont))),
              // FlatButton.icon(onPressed: () {}, icon: new Icon(Icons.sort, size: 30), label: new Text("Sort", style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      );
    }
  }

  // Build a single movie item
  Widget _buildMovieItem(Movie movie, int index) {
    // check if the movie is saved
    final bool liked = movie.getStatus() == MovieStatus.favorite;
    final bool gem = movie.getStatus() == MovieStatus.gem;

    Widget _icon;
    if (liked) {
      _icon = new Icon(Icons.favorite, color: Colors.red);
    } else if (gem) {
      _icon =
          new Icon(Icons.local_activity, color: Color.fromRGBO(255, 215, 0, 1));
    } else {
      _icon = new Icon(Icons.favorite_border);
    }

    // Create a list tile with icon, title, date and wether the movie is saved or not
    return new ListTile(
      leading: Padding(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Icon(Icons.movie),
      ),
      title: new Text(
        movie.getTitle(),
        style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: Repo.currentFont,
            color: Colors.deepOrange),
      ),
      subtitle: new Text(DateFormat('d MMM. yyyy')
              .format(movie.getDate())
              .toString()
              .toLowerCase() +
          " - " +
          movie.getRating().toString()),
      trailing: IconButton(
          icon: _icon,
          onPressed: () {
            _saveFavoriteMovie(movie, index);
          }),
      onTap: () => _promptEditMovie(index),
      onLongPress: () => _promptRemoveMovie(index),
      dense: false,
    );
  }

  // Send the user to the add movie screen
  void _pushEditScreen(int index) {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder: (context) => EditScreen(movieIndex: index)),
    );
  }

  // Send the user to the add movie screen
  void _pushSearchScreen(List<Movie> searchList) {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder: (context) => SearchScreen(iterableList: searchList)),
    );
  }

  // Send the user to the add movie screen
  void _pushAddMovieScreen(List<Movie> incompleteList) {
    // Push this page onto the stack
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder: (context) =>
              AddMovieScreen(list: incompleteList, keyString: Repo.movieKey)),
    );
  }

  // favorite a movie from the watched list
  void _saveFavoriteMovie(Movie favMovie, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadySaved =
        Repo.watched[index].getStatus() == MovieStatus.favorite;
    final bool isAGem = Repo.watched[index].getStatus() == MovieStatus.gem;

    setState(() {
      // If the movie is not in the favorite list yet, add the movie. Else remove the movie from the favorite list
      if (alreadySaved) {
        Repo.watched[index].setStatus(MovieStatus.normal);
      } else if (isAGem) {
        Repo.watched[index].setStatus(MovieStatus.favorite);
      } else {
        Repo.watched[index].setStatus(MovieStatus.gem);
      }
      prefs.setString(Repo.movieKey, jsonEncode(Repo.watched));
    });
  }
}
