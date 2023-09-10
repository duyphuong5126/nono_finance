import 'package:intl/intl.dart';

class GoldPricesFormatter {
  final priceFormat = NumberFormat("#,##0.00", "en_US");

  String formatHighestBuyingPrice(double price) {
    return 'Giá cao nhất\n${priceFormat.format(price)}tr\n(mua vào)';
  }

  String formatLowestBuyingPrice(double price) {
    return 'Giá thấp nhất\n${priceFormat.format(price)}tr\n(mua vào)';
  }

  String formatHighestSellingPrice(double price) {
    return 'Giá cao nhất\n${priceFormat.format(price)}tr\n(bán ra)';
  }

  String formatLowestSellingPrice(double price) {
    return 'Giá thấp nhất\n${priceFormat.format(price)}tr\n(bán ra)';
  }

  String formatHighestPrice(double price) {
    return 'Giá cao nhất\n${priceFormat.format(price)}tr';
  }

  String formatLowestPrice(double price) {
    return 'Giá thấp nhất\n${priceFormat.format(price)}tr';
  }

  String formatGlobalPrice(double price) {
    return '\$${priceFormat.format(price)}';
  }

  String formatGlobalPriceChangeLabel(double price) {
    return price > 0
        ? 'Tăng'
        : price < 0
            ? 'Giảm'
            : '';
  }

  String formatGlobalPriceChange(double price) {
    return '\$${priceFormat.format(price.abs())}';
  }

  String formatGlobalPriceChangeInPercent(double price) {
    return '${price > 0 ? '+' : price < 0 ? '-' : ''}${priceFormat.format(price.abs())}%';
  }
}
