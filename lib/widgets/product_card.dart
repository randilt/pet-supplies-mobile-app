import 'package:flutter/material.dart';
import 'package:pet_store_mobile_app/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            _buildProductInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(5),
        ),
        child: Image.network(
          product.imageUrl ?? 'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/placeholder.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductName(name: product.name),
          const SizedBox(height: 4),
          _ProductPrice(price: product.price),
        ],
      ),
    );
  }
}

class _ProductName extends StatelessWidget {
  final String name;

  const _ProductName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProductPrice extends StatelessWidget {
  final double price;

  const _ProductPrice({required this.price});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Rs. $price',
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
    );
  }
}
