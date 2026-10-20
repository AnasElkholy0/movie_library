// Fetches movies from The Movie Database (TMDB), downloads their posters into
// assets/posters/ and regenerates lib/movie.dart.
//
// Usage (from the project root):
//   Windows PowerShell:  $env:TMDB_API_KEY="your_v3_key"; dart run tool/fetch_tmdb.dart
//   macOS / Linux:       TMDB_API_KEY=your_v3_key dart run tool/fetch_tmdb.dart
//
// Optional: use a TMDB list instead of the "top rated" chart:
//   dart run tool/fetch_tmdb.dart --list <TMDB_LIST_ID>
//
// This product uses the TMDB API but is not endorsed or certified by TMDB.
import 'dart:convert';
import 'dart:io';

const String apiBase = 'https://api.themoviedb.org/3';
const String imageBase = 'https://image.tmdb.org/t/p/w500';
const int movieCount = 50;

Future<void> main(List<String> args) async {
  final String? apiKey = Platform.environment['TMDB_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Missing TMDB_API_KEY environment variable (v3 API key).');
    exit(1);
  }

  String? listId;
  final int listFlag = args.indexOf('--list');
  if (listFlag != -1 && listFlag + 1 < args.length) {
    listId = args[listFlag + 1];
  }

  final HttpClient client = HttpClient();
  try {
    final Map<int, String> genreNames = await _fetchGenres(client, apiKey);

    final List<Map<String, dynamic>> candidates = listId == null
        ? await _fetchTopRated(client, apiKey)
        : await _fetchList(client, apiKey, listId);

    // Keep only movies that have a title and a poster.
    final List<Map<String, dynamic>> selected = candidates
        .where((Map<String, dynamic> m) =>
            m['title'] != null && m['poster_path'] != null)
        .take(movieCount)
        .toList();

    // Remove old (placeholder) posters.
    final Directory posterDir = Directory('assets/posters');
    if (posterDir.existsSync()) {
      for (final FileSystemEntity entity in posterDir.listSync()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.jpg')) {
          entity.deleteSync();
        }
      }
    } else {
      posterDir.createSync(recursive: true);
    }

    final Set<String> usedNames = <String>{};
    final StringBuffer entries = StringBuffer();

    for (final Map<String, dynamic> movie in selected) {
      final String title = movie['title'] as String;
      final String releaseDate = (movie['release_date'] as String?) ?? '';
      final int year = releaseDate.length >= 4
          ? (int.tryParse(releaseDate.substring(0, 4)) ?? 0)
          : 0;
      final double rating = ((movie['vote_average'] as num?) ?? 0).toDouble();

      final List<String> genres = ((movie['genre_ids'] as List<dynamic>?) ??
              <dynamic>[])
          .map((dynamic id) => genreNames[id as int])
          .whereType<String>()
          .take(2)
          .toList();
      final String genreText = genres.isEmpty ? 'Movie' : genres.join(', ');

      // Unique, file-system-safe file name.
      String base = title
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      if (base.isEmpty) base = 'movie';
      String fileName = base;
      int suffix = 2;
      while (!usedNames.add(fileName)) {
        fileName = '${base}_$suffix';
        suffix++;
      }

      await _downloadFile(
        client,
        '$imageBase${movie['poster_path']}',
        File('assets/posters/$fileName.jpg'),
      );
      stdout.writeln('OK  $title ($year)  ${rating.toStringAsFixed(1)}');

      entries.writeln('  Movie(');
      entries.writeln("    title: '${_escape(title)}',");
      entries.writeln("    genre: '${_escape(genreText)}',");
      entries.writeln('    year: $year,');
      entries.writeln('    rating: ${rating.toStringAsFixed(1)},');
      entries.writeln("    image: 'assets/posters/$fileName.jpg',");
      entries.writeln('  ),');
    }

    File('lib/movie.dart').writeAsStringSync(_buildMovieFile(entries.toString()));
    stdout.writeln('\nDone: ${selected.length} movies written to lib/movie.dart');
    if (selected.length < movieCount) {
      stdout.writeln('Note: only ${selected.length} movies had posters.');
    }
  } finally {
    client.close();
  }
}

Future<Map<int, String>> _fetchGenres(HttpClient client, String key) async {
  final Map<String, dynamic> json =
      await _getJson(client, '$apiBase/genre/movie/list?api_key=$key');
  final Map<int, String> result = <int, String>{};
  for (final dynamic g in json['genres'] as List<dynamic>) {
    final Map<String, dynamic> genre = g as Map<String, dynamic>;
    result[genre['id'] as int] = genre['name'] as String;
  }
  return result;
}

Future<List<Map<String, dynamic>>> _fetchTopRated(
    HttpClient client, String key) async {
  final List<Map<String, dynamic>> all = <Map<String, dynamic>>[];
  int page = 1;
  // 20 results per page; fetch a few extra pages in case some lack posters.
  while (all.length < movieCount + 10 && page <= 5) {
    final Map<String, dynamic> json = await _getJson(
        client, '$apiBase/movie/top_rated?api_key=$key&language=en-US&page=$page');
    all.addAll((json['results'] as List<dynamic>).cast<Map<String, dynamic>>());
    page++;
  }
  return all;
}

Future<List<Map<String, dynamic>>> _fetchList(
    HttpClient client, String key, String listId) async {
  final Map<String, dynamic> json =
      await _getJson(client, '$apiBase/list/$listId?api_key=$key&language=en-US');
  return (json['items'] as List<dynamic>).cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> _getJson(HttpClient client, String url) async {
  final HttpClientRequest request = await client.getUrl(Uri.parse(url));
  final HttpClientResponse response = await request.close();
  final String body = await response.transform(utf8.decoder).join();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}: $body');
  }
  return jsonDecode(body) as Map<String, dynamic>;
}

Future<void> _downloadFile(HttpClient client, String url, File target) async {
  final HttpClientRequest request = await client.getUrl(Uri.parse(url));
  final HttpClientResponse response = await request.close();
  if (response.statusCode != 200) {
    throw HttpException('Poster download failed (${response.statusCode}): $url');
  }
  final IOSink sink = target.openWrite();
  await response.pipe(sink);
}

/// Escapes characters that are special inside a single-quoted Dart string.
String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$');

String _buildMovieFile(String entries) {
  return '''/// Data model for a single movie in the library.
/// Generated data comes from TMDB (tool/fetch_tmdb.dart).
/// This product uses the TMDB API but is not endorsed or certified by TMDB.
class Movie {
  const Movie({
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.image,
  });

  final String title;
  final String genre;
  final int year;
  final double rating;

  /// Local asset path, e.g. `assets/posters/inception.jpg`.
  final String image;
}

/// The original, unfiltered movie collection.
/// Every [Movie.image] matches a file inside `assets/posters/`.
const List<Movie> movies = <Movie>[
$entries];
''';
}
