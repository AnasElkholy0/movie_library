import 'package:flutter/material.dart';

import 'movie.dart';
import 'movie_card.dart';

/// Main screen: search field + List/Grid toggle + shared bonus state.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGridView = false;
  String searchText = '';
  int discount = 20; // Shared bonus value shown on every card.

  /// Called by any card's badge. Updates all cards via a single setState.
  void _decreaseDiscount() {
    setState(() {
      if (discount > 0) {
        discount--; // Never goes below 0.
      }
    });
  }

  /// Case-insensitive partial match on title or genre.
  List<Movie> get _filteredMovies {
    final String query = searchText.trim().toLowerCase();
    if (query.isEmpty) {
      return movies;
    }
    return movies.where((Movie movie) {
      return movie.title.toLowerCase().contains(query) ||
          movie.genre.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Movie> visibleMovies = _filteredMovies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Library'),
        actions: <Widget>[
          IconButton(
            tooltip:
                isGridView ? 'Switch to list view' : 'Switch to grid view',
            // The icon shows the layout you will switch TO.
            icon: Icon(
              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Search field (no TextEditingController needed).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (String value) {
                setState(() {
                  searchText = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: visibleMovies.isEmpty
                ? const Center(
                    child: Text(
                      'No movies found',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                : (isGridView
                    ? _buildGridView(visibleMovies)
                    : _buildListView(visibleMovies)),
          ),
        ],
      ),
    );
  }

  /// One movie per row.
  Widget _buildListView(List<Movie> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MovieCard(
            movie: items[index],
            discount: discount,
            onDiscountTap: _decreaseDiscount,
          ),
        );
      },
    );
  }

  /// Exactly two columns.
  Widget _buildGridView(List<Movie> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Taller than wide so the poster and the info area both fit.
        childAspectRatio: 0.6,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return MovieCard(
          movie: items[index],
          discount: discount,
          onDiscountTap: _decreaseDiscount,
        );
      },
    );
  }
}
