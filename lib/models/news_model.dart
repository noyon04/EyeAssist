// To parse this JSON data, do
//
//     final news = newsFromJson(jsonString);

import 'dart:convert';

News newsFromJson(String str) => News.fromJson(json.decode(str));

String newsToJson(News data) => json.encode(data.toJson());

class News {
    String status;
    int totalResults;
    List<Result> results;
    String nextPage;

    News({
        required this.status,
        required this.totalResults,
        required this.results,
        required this.nextPage,
    });

    factory News.fromJson(Map<String, dynamic> json) => News(
        status: json["status"],
        totalResults: json["totalResults"],
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        nextPage: json["nextPage"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "totalResults": totalResults,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "nextPage": nextPage,
    };
}

class Result {
    String articleId;
    String title;
    String link;
    List<String>? keywords;
    List<String>? creator;
    dynamic videoUrl;
    String description;
    String content;
    DateTime pubDate;
    String? imageUrl;
    String sourceId;
    int sourcePriority;
    List<Country> country;
    Language language;

    Result({
        required this.articleId,
        required this.title,
        required this.link,
        required this.keywords,
        required this.creator,
        required this.videoUrl,
        required this.description,
        required this.content,
        required this.pubDate,
        required this.imageUrl,
        required this.sourceId,
        required this.sourcePriority,
        required this.country,
        required this.language,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        articleId: json["article_id"] ?? "",
        title: json["title"] ?? "",
        link: json["link"] ?? "",
        keywords: (json["keywords"] as List?)?.cast<String>() ?? [],
        creator: (json["creator"] as List?)?.cast<String>() ?? [],
        videoUrl: json["video_url"],
        description: json["description"] ?? "",
        content: json["content"] ?? "",
        pubDate: DateTime.parse(json["pubDate"] ?? DateTime.now().toString()),
        imageUrl: json["image_url"],
        sourceId: json["source_id"] ?? "",
        sourcePriority: json["source_priority"] ?? 0,
        country: (json["country"] as List?)?.map((x) => countryValues.map[x]!).toList() ?? [],
        language: languageValues.map[json["language"]] ?? Language.ENGLISH,
    );

    Map<String, dynamic> toJson() => {
        "article_id": articleId,
        "title": title,
        "link": link,
        "keywords": keywords == null ? [] : List<dynamic>.from(keywords!.map((x) => x)),
        "creator": creator == null ? [] : List<dynamic>.from(creator!.map((x) => x)),
        "video_url": videoUrl,
        "description": description,
        "content": content,
        "pubDate": pubDate.toIso8601String(),
        "image_url": imageUrl,
        "source_id": sourceId,
        "source_priority": sourcePriority,
        "country": List<dynamic>.from(country.map((x) => countryValues.reverse[x])),
     
        "language": languageValues.reverse[language],
    };
}

enum Category {
    SPORTS,
    TOP
}

final categoryValues = EnumValues({
    "sports": Category.SPORTS,
    "top": Category.TOP
});

enum Country {
    UNITED_KINGDOM
}

final countryValues = EnumValues({
    "united kingdom": Country.UNITED_KINGDOM
});

enum Language {
    ENGLISH
}

final languageValues = EnumValues({
    "english": Language.ENGLISH
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
