class FlickrBlocModel {
  final String tags;
  final String link;
  final String title;
  final String picture;
  final String description;
  final String published;
  final String author;

  FlickrBlocModel.fromJson(Map<String, dynamic> json)
      : tags = json['tags'],
        link = json['link'],
        title = json['title'],
        picture = json['media']['m'],
        description = json['description'],
        published = json['published'],
        author = json['author'];
}