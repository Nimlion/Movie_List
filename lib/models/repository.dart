import 'package:to_do/models/movie.dart';

/*
* This is a local memory of the app and all its settings
* programmer: Hosam Darwish
*/
class Repo {
  static List<Movie> watched = [];
  static List<Movie> future = [];

  static double currentFont = normalFont;
  static final double smallFont = 12.0;
  static final double normalFont = 14.0;
  static final double largeFont = 16.0;
  static final double largerFont = 26.0;

  static final String movieKey = 'list';
  static final String futureKey = 'watchlist';
  static final String favoriteKey = 'saved';
  static final String darkKey = 'darktheme';
}
