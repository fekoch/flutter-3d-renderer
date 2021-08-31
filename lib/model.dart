import 'dart:math';
import 'dart:developer' as Dev;

import 'package:flutter/material.dart';

abstract class GraphicsObject {
  void draw(Canvas canvas, Size size);

  /// Converts coordinates from a simple 100x100 grid to the scale of the canvas
  Offset convertCoordinates(num x, num y, Size canvasSize) {
    return Offset(x / 100 * canvasSize.width, y / 100 * canvasSize.height);
  }
}

@immutable
class Point extends GraphicsObject {
  final num x;
  final num y;
  final num z;

  Point({this.x: 0, this.y: 0, this.z: 0});

  /// Adds a [Vector] to a [Point]
  Point operator +(Vector vec) =>
      Point(x: x + vec.x, y: y + vec.y, z: z + vec.z);

  /// Subtracts a [Vector] from this [Point] and returns the new [Point]
  Point subtractVector(Vector vec) =>
      Point(x: x - vec.x, y: y - vec.y, z: z - vec.z);

  /// Subtracts the second [Point] from the first one. The result is a [Vector]
  Vector operator -(Point other) =>
      Vector(x: x - other.x, y: y - other.y, z: z - other.z);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  // Graphics Stuff TODO: refractor out into other class
  static num pointSize = 1;

  /// Draws this [Point] onto the [canvas]
  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawCircle(convertCoordinates(x, y, size), pointSize as double,
        Paint()..color = Colors.black);
  }

  @override
  String toString() => "($x|$y|$z)";
}

@immutable
class Vector extends Matrix {
  num get x => _m[0][0];

  num get y => _m[1][0];

  num get z => _m[2][0];

  Vector({x: 0, y: 0, z: 0}) : super.vector(x, y, z);

  Vector operator +(Vector vec) =>
      Vector(x: x + vec.x, y: y + vec.y, z: z + vec.z);

  Vector operator -(Vector vec) =>
      Vector(x: x - vec.x, y: y - vec.y, z: z - vec.z);

  num _degToRad(num degree) => degree / 180 * pi;

  Vector rotateXY(num degree) {
    var rad = _degToRad(degree);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  @override
  String toString() => "v($x, $y, $z)";
}

class Matrix {
  final List<List<num>> _m;

  num _get(int r, int c) {
    if (r < 0 || c < 0 || r >= _m.length || c >= _m[r].length)
      throw IllegalArgumentException("IndexOutOfBounds");
    return _m[r][c];
  }

  /// Lets you access the values of this matrix
  ///
  /// The first access-index has to be smaller than the [height] of the
  /// [Matrix].
  ///
  /// The second access-index has to be smaller than the [width] of the
  /// [Matrix].
  _InnerMatrixHelper<num> operator [](int index) {
    return _InnerMatrixHelper((index2) => _get(index,index2),
        (index2, value) => _set(index, index2, value));
  }

  /// Returns an unmodifiable copy of the column
  List<num> getColumn(int index) {
    assert(index < this.width && index >= 0);
    List<num> col = [];
    _m.forEach((row) => col.add(row[index]));
    return List.unmodifiable(col);
  }

  /// Returns an unmodifiable copy of the row
  List<num> getRow(int index) {
    assert(_m.length > index && index >= 0);
    return List.unmodifiable(_m[index]);
  }

  void _set(int r, int c, num val) {
    if (r < 0 || c < 0 || r >= _m.length || c >= _m[r].length)
      throw IllegalArgumentException("IndexOutOfBounds");
    _m[r][c] = val;
  }

  int get height => _m.length;

  int get width {
    int w = _m.first.length;
    assert(_m.skip(1).every((element) => element.length == w));
    return w;
  }

  Matrix.rotationXY(num theta)
      : this.threeByThree(
            List.of([cos(theta), -sin(theta), 0], growable: false),
            List.of([sin(theta), cos(theta), 0], growable: false),
            List.of([0, 0, 1], growable: false));

  Matrix.threeByThree(List<num> top, List<num> mid, List<num> bot)
      : assert(top.length != 3 || mid.length != 3 || bot.length != 3, false),
        _m = List.of([top, mid, bot], growable: false);

  Matrix.vector(num x, num y, num z)
      : _m = [
          [x],
          [y],
          [z]
        ];

  Matrix.empty(int width, int height)
      : assert(width > 0 && height > 0),
        _m = List.generate(height, (index) => List.filled(width, 0),growable: false);

  /// Dot multiplication
  Matrix operator *(Matrix other) {
    if (this.width != other.height)
      throw IllegalArgumentException(/*TODO: MSG*/);

    Matrix nMat = Matrix.empty(other.width, this.height);
    nMat.fillEach((row, column, value) {
      Dev.log("Row: $row - Column: $column - Value: $value");
      var a = this.getRow(row);
      var b = other.getColumn(column).toList();
      var newVal = a.fold(0,(num value, num element) => value + element*b.removeAt(0));
      assert(b.isEmpty);
      return newVal;
    });

    return nMat;
  }

  /// parses the whole [Matrix]
  void forEach(void Function(int row,int column,num value) function) {
    for(int row = 0; row < this.height; row++) {
      for(int column = 0; column < this.width; column++){
        function.call(row,column,this[row][column]);
      }
    }
  }

  /// Calls the function for all cells in the [Matrix].
  ///
  /// If [function] returns `null`, then the value will not be touched.
  /// If [function] returns a new [num]-value, then the old value will be
  /// overwritten.
  void fillEach(num? Function(int row,int column,num value) function) {
    for(int row = 0; row < this.height; row++) {
      for(int column = 0; column < this.width; column++){
        var newval = function.call(row,column,this[row][column]);
        if (newval != null) this[row][column] = newval;
      }
    }
  }

  List<num> get values => _m.fold([],(value, element) => value..addAll(element));

  @override
  String toString() {
    String s = "";
    for(int i = 0; i < this.height; i++) {
      for(int w = 0; w < this.width; w++) {
       s += "${this[i][w]}\t";
      }
      s+= "\n";
    }
    return s;
  }
}

/// Helper for [Matrix]
class _InnerMatrixHelper<E> {
  E Function(int) reader;
  void Function(int, E) writer;

  _InnerMatrixHelper(this.reader, this.writer);

  E operator [](int index) => reader.call(index);

  void operator []=(int index, E value) => writer.call(index, value);
}

class IllegalArgumentException implements Exception {
  final String? message;

  const IllegalArgumentException([this.message]);

  @override
  String toString() => message ?? "IllegalArgumentException";
}
