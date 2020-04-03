/*
* Here are all the statuses decided which a movie can have
* programmer: Hosam Darwish
*/

// All movie statuses
enum MovieStatus { normal, favorite, gem }

MovieStatus getStatusFromString(String statusAsString) {
  for (MovieStatus element in MovieStatus.values) {
     if (element.toString() == statusAsString) {
        return element;
     }
  }
  return null;
}