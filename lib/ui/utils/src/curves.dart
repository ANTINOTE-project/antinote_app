import 'package:flutter/material.dart';

class ReversedCurve extends Curve {
  final Curve curve;

  const ReversedCurve(this.curve);

  @override
  double transformInternal(double t) => 1.0 - curve.transform(t);
}
