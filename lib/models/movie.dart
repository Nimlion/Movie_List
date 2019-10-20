import 'package:to_do/models/repository.dart';

/*
* Here is everything about a movie
* programmer: Hosam Darwish
*/
class Movie {
  // Each movie has a title and a date from when it was added
  String _title;
  DateTime _addedDate;

  // To create a movie a date and title must be given
  Movie(DateTime date, String name) {
    this._addedDate = date;
    this._title = name;
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
    return new Movie(DateTime.parse(json['date']), json['title']);
  }

  // Translate a object of movie to a string in json
  toJson() {
    return {
      'title': _title,
      'date': _addedDate.toString(),
    };
  }

  // Get the title of the movie
  String getTitle() {
    return this._title;
  }

  // Get the date of the movie
  DateTime getDate() {
    return this._addedDate;
  }

  // Set the date of the movie
  void setTitle(String newTitle) {
    this._title = newTitle;
  }

  // Check if the movie already exists in the list of movies
  static bool movieDoesExist(String movie) {
    for (Movie object in Repo.watched) {
      if (object.getTitle().toLowerCase() == movie) {
        return true;
      }
    }
    return false;
  }

  // Sort a list of movies alphabetically
  static void sortListAlphabetically(List<Movie> lijst) async {
    lijst.sort((a, b) {
      return a.getTitle().compareTo(b.getTitle());
    });
  }

  // Sort a list of movies by the latest date
  static void sortListByLatest(List<Movie> lijst) async {
    lijst.sort((a, b) {
      return b.getDate().compareTo(a.getDate());
    });
  }

  // Sort a list of movies by the latest date
  static void sortListByEarliest(List<Movie> lijst) async {
    lijst.sort((a, b) {
      return a.getDate().compareTo(b.getDate());
    });
  }
}