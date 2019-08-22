import 'package:to_do/models/movie.dart';

/*
* This is a local memory of the app and all its settings
* programmer: Hosam Darwish
*/
class Repo {
  static List<Movie> movieItems = [];
  static List<Movie> saved = [];
  static final double normalFont = 14.0;
  static final String movieKey = 'list';
  static final String favoriteKey = 'saved';
}