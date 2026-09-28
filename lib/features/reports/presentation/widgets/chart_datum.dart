import 'package:flutter/material.dart';

/// A single labeled, colored, numeric slice used by the chart widgets below.
class ChartDatum {
  final String label;
  final int value;
  final Color color;
  const ChartDatum({
    required this.label,
    required this.value,
    required this.color,
  });
}
