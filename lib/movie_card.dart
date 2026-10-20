import 'package:flutter/material.dart';

import 'movie.dart';

/// A stateless card showing one movie.
///
/// The shared bonus value ([discount]) and the tap handler
/// ([onDiscountTap]) are owned by the parent (`HomePage`), so this
/// widget never needs its own state.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.discount,
    required this.onDiscountTap,
  });

  final Movie movie;
  final int discount;
  final VoidCallback onDiscountTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      // Clipping makes the poster follow the rounded corners.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh, // derived from the app theme
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      // LayoutBuilder lets the same card work in both layouts:
      //  - Grid: the cell height is bounded, so the poster fills the space.
      //  - List: height is unbounded, so the poster gets a fixed aspect ratio.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget poster = _buildPoster(colors);
          final bool hasBoundedHeight = constraints.hasBoundedHeight;

          return Column(
            mainAxisSize:
                hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (hasBoundedHeight)
                Expanded(child: poster)
              else
                AspectRatio(aspectRatio: 16 / 10, child: poster),
              _buildInfo(theme),
            ],
          );
        },
      ),
    );
  }

  /// Poster image with rating, bookmark and year overlays.
  Widget _buildPoster(ColorScheme colors) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          movie.image,
          fit: BoxFit.cover,
          // Graceful fallback if an image is missing or corrupt.
          errorBuilder: (BuildContext context, Object error, StackTrace? st) {
            return Container(
              color: colors.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Icon(
                Icons.movie_outlined,
                size: 48,
                color: Colors.white38,
              ),
            );
          },
        ),
        // Dark gradient at the bottom keeps the year readable.
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x00000000), Color(0xCC000000)],
              ),
            ),
          ),
        ),
        // Rating badge: top-left.
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xCC000000),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.star_rounded, size: 16, color: colors.primary),
                const SizedBox(width: 3),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bookmark icon: top-right.
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Color(0xCC000000),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        // Release year: bottom-left.
        Positioned(
          left: 10,
          bottom: 8,
          child: Text(
            movie.year.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              shadows: <Shadow>[Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }

  /// Title, genre and tappable bonus badge.
  Widget _buildInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  movie.genre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(width: 6),
              _buildDiscountBadge(theme),
            ],
          ),
        ],
      ),
    );
  }

  /// Tappable bonus badge. Tapping only calls the parent's callback.
  Widget _buildDiscountBadge(ThemeData theme) {
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onDiscountTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.local_offer, size: 13, color: Colors.black87),
              const SizedBox(width: 4),
              Text(
                '$discount%',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
