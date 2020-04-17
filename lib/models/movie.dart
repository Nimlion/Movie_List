import 'package:to_do/models/repository.dart';
import 'package:to_do/models/state.dart';

/*
* Here is everything about a movie
* programmer: Hosam Darwish
*/
class Movie {
  // Each movie has a title and a date from when it was added
  String _title;
  DateTime _addedDate;
  MovieStatus _status;
  double _rating;

  // To create a movie a date and title must be given
  Movie(DateTime date, String name, MovieStatus status, double rating) {
    this._addedDate = date;
    this._title = name;
    this._status = status;
    this._rating = rating;
  }

  // Check if a movie is identical to one another
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie &&
          runtimeType == other.runtimeType &&
          _title == other._title;

  // Get the identification code of a movie
  @override
  int get hashCode => _title.hashCode;

  // Translate a string from json to a object of movie
  factory Movie.fromJson(Map<String, dynamic> json) {
    return new Movie(
        DateTime.parse(json['date']),
        json['title'],
        getStatusFromString(json['status']),
        json['rating'] == "null" ? 0 : double.parse(json['rating']));
  }

  // Translate a object of movie to a string in json
  toJson() {
    return {
      'title': _title,
      'date': _addedDate.toString(),
      'status': _status.toString(),
      'rating': _rating.toString(),
    };
  }

  // Get the title of the movie
  String getTitle() {
    return this._title;
  }

  // Get the title of the movie
  MovieStatus getStatus() {
    return this._status;
  }

  // Get the date of the movie
  DateTime getDate() {
    return this._addedDate;
  }

  // Get the rating of the movie
  double getRating() {
    return this._rating;
  }

  // Set the title of the movie
  void setTitle(String newTitle) {
    this._title = newTitle;
  }

  // Set the title of the movie
  void setStatus(MovieStatus newStatus) {
    this._status = newStatus;
  }

  // Set the date of the movie
  void setDate(DateTime newDate) {
    this._addedDate = newDate;
  }

  // Set the date of the movie
  void setRating(double newRating) {
    this._rating = newRating;
  }

  // Check if the movie already exists in the list of watched movies
  static bool movieExistsInWatched(int current, String movie) {
    for (var i = 0; i < Repo.watched.length; i++) {
      if (i != current && Repo.watched[i].getTitle().toLowerCase() == movie) {
        return true;
      }
    }
    return false;
  }

  // Check if the movie already exists in the list of to watch movies
  static bool movieExistsInToWatch(String movie) {
    for (Movie object in Repo.future) {
      if (object.getTitle().toLowerCase() == movie) {
        return true;
      }
    }
    return false;
  }

  // Sort a list of movies alphabetically
  static void sortListAlphabetically(List<Movie> list) async {
    list.sort((a, b) {
      return a.getTitle().compareTo(b.getTitle());
    });
  }

  // Sort a list of movies by the latest date
  static void sortListByLatest(List<Movie> list) async {
    list.sort((a, b) {
      return b.getDate().compareTo(a.getDate());
    });
  }

  // Sort a list of movies by the latest date
  static void sortListByEarliest(List<Movie> list) async {
    list.sort((a, b) {
      return a.getDate().compareTo(b.getDate());
    });
  }

  // Sort a list of movies by the latest date
  static void sortListByHighestRating(List<Movie> list) async {
    list.sort((a, b) {
      return a.getRating().compareTo(b.getRating());
    });
  }

  // Sort a list of movies by the latest date
  static void sortListByLowestRating(List<Movie> list) async {
    list.sort((a, b) {
      return b.getRating().compareTo(a.getRating());
    });
  }

  // Sort a list of movies by the latest date
  static List<Movie> retrieveGems(List<Movie> list) {
    return list.where((movie) => movie.getStatus() == MovieStatus.gem).toList();
  }
}
