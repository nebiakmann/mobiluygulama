import 'package:flutter/material.dart';

class FacilityCard extends StatelessWidget {
  final dynamic facility;
  //final FacilityModel facility;
  final VoidCallback onTap;
  final String? imageUrl;
  final String? assetImage;

  const FacilityCard({
    super.key,
    required this.facility,
    required this.onTap,
    this.imageUrl,
    this.assetImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 200, // Changed from Container to SizedBox
                width: double.infinity,
                child: _buildImage(),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFacilityName(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFacilityDescription(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getFacilityLocation(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Priority: imageUrl > assetImage > default placeholder
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (assetImage != null && assetImage!.isNotEmpty) {
      return Image.asset(
        assetImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error'); // Add debug print
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.fitness_center, // Changed to more appropriate gym icon
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Helper methods to safely access facility properties
  String _getFacilityName() {
    try {
      return facility.name ?? 'Fitness Center';
    } catch (e) {
      return 'Fitness Center';
    }
  }

  String _getFacilityDescription() {
    try {
      return facility.description ?? 'Modern fitness facility with state-of-the-art equipment';
    } catch (e) {
      return 'Modern fitness facility with state-of-the-art equipment';
    }
  }

  String _getFacilityLocation() {
    try {
      // Try different possible property names for location
      if (facility.location != null) return facility.location;
      if (facility.address != null) return facility.address;
      if (facility.venue != null) return facility.venue;
      return 'Campus Fitness Center';
    } catch (e) {
      return 'Campus Fitness Center';
    }
  }
}