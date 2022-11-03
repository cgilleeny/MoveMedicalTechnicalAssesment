class Photo {
  String city;
  DateTime timestamp;
  String ext;
  int seq;
  String paddedCitySeq = '';

  String get cityName {
    return '$city$paddedCitySeq.$ext';
  }

  Photo.fromList(List<String> parts, int seq) {
    // split the filename to get the file extension
    final filenameParts = parts[0].split('.');
    ext = filenameParts.length == 2 ? filenameParts[1] : 'Unknown';

    city = parts[1];
    timestamp = DateTime.parse(parts[2]);
    this.seq = seq;
  }
}

class PhotoDirectory {
  Map<String, List<Photo>> cityPhotos = {};

  PhotoDirectory(String metadata) {
    // split the directory string to a list of metadata per photo
    List<String> metaList = metadata.split('\n');

    // iterate through the list and generate list of Photo objects
    for (var i = 0; i < metaList.length; i++) {
      // parse the list items into filename, city & date
      final parts = metaList[i].split(', ');

      // something is wrong if it isn;t exactly 3 items
      if (parts.length == 3) {
        final photo = Photo.fromList(parts, i);

        // add Photo object to list of photos mapped by city
        cityPhotos[photo.city.toLowerCase()] = [
          photo,
          ...cityPhotos[photo.city.toLowerCase()] ?? []
        ];
      }
    }
  }

  String get namedByCity {
    List<Photo> allPhotos = [];

    // iterate through the city map
    cityPhotos.forEach((key, photos) {
      // sort each cities photos by date & time
      photos.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // calculate digit padding
      final digitPadding = photos.length.toString().length;
      var count = 1;
      for (var photo in photos) {
        // initialize the city seq value
        photo.paddedCitySeq = count.toString().padLeft(digitPadding, '0');
        count++;
      }
      // join this cities photos with the others
      allPhotos = [...photos, ...allPhotos];
    });

    // sort the photos using the original order
    allPhotos.sort((a, b) => a.seq.compareTo(b.seq));

    // iterate through the photo list and append the city name to the output string
    String output = '';
    for (var photo in allPhotos) {
      // so we don't have an extra new line at the  end
      if (output.isNotEmpty) output += '\n';
      output += photo.cityName;
    }
    return output;
  }
}

main() {
  String input =
      'DSC012333.jpg, Madrid, 2016-10-01 13:02:34\nDSC044322.jpg, Milan, 2015-03-05 10:11:22\nDSC130033.raw, Rio, 2018-06-02 17:01:30\nDSC044322.jpeg, Milan, 2015-03-04 14:55:01\nDSC130033.jpg, Rio, 2018-06-02 17:05:10\nDSC012335.jpg, Milan, 2015-03-05 10:11:24';
  print(PhotoDirectory(input).namedByCity);
}
