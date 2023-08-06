double calculateInterval(double min, double max, int steps) {
  if (max - min <= 0.5) {
    return 0.1;
  } else if (max - min <= 1.0) {
    return 0.2;
  }
  final avg = (max - min) / steps;
  final result = (avg * 2).round() / 2.0;
  return result >= 0.5 ? result : 0.5;
}
