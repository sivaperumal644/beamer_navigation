import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// DATA
class Book {
  const Book(this.id, this.title, this.author);

  final int id;
  final String title;
  final String author;
}

const List<Book> books = [
  Book(1, 'Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book(2, 'Foundation', 'Isaac Asimov'),
  Book(3, 'Fahrenheit 451', 'Ray Bradbury'),
];

// SCREENS
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.beamToNamed('/books'),
          child: const Text('See books'),
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: books
                  .map(
                    (book) => ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      onTap: () => context.beamToNamed(
                          '/books/books_details?bookId=${book.id}'),
                    ),
                  )
                  .toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Go back"),
          ),
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  final Book? book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book?.title ?? 'Not Found'),
      ),
      body: book != null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Author: ${book!.author}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.beamToNamed(
                      "/books/books_details/recommendation?bookId=${book!.id}",
                    );
                  },
                  child: const Text("Next page"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Go back"),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class BookRecomendationScreen extends StatelessWidget {
  const BookRecomendationScreen({Key? key, required this.book})
      : super(key: key);

  final Book? book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book?.title ?? 'Not Found'),
      ),
      body: book != null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Recomendation: ${book!.title}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Go back"),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/books/:books_details/recommendation'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomeScreen(),
      ),
      if (state.uri.pathSegments.contains('books'))
        const BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        ),
      if (state.uri.pathSegments.contains('books') &&
          state.uri.pathSegments.contains("books_details") &&
          state.queryParameters.containsKey("bookId"))
        BeamPage(
          key: ValueKey('book-${state.queryParameters['bookId']}'),
          title: 'Book #${state.queryParameters['bookId']}',
          child: BookDetailsScreen(
            book: books.firstWhereOrNull(
              (book) =>
                  book.id ==
                  int.tryParse(state.queryParameters['bookId'] as String),
            ),
          ),
        ),
      if (state.uri.pathSegments.contains('books') &&
          state.uri.pathSegments.contains("books_details") &&
          state.uri.pathSegments.contains("recommendation"))
        BeamPage(
          key: ValueKey(
              'book-${state.queryParameters['bookId']}-recommendation'),
          title: 'Book #${state.queryParameters['bookId']}',
          child: BookRecomendationScreen(
            book: books.firstWhereOrNull(
              (book) =>
                  book.id ==
                  int.tryParse(state.queryParameters['bookId'] as String),
            ),
          ),
        ),
    ];
  }
}

// APP
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [BooksLocation()],
    ),
    notFoundRedirectNamed: '/books',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
    );
  }
}

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}
