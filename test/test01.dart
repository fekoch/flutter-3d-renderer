import 'dart:developer';
import 'dart:math' as Math;

import 'package:flutter_test/flutter_test.dart';
import 'package:just_a_3d_renderer/model.dart';

void main() {
  test("Basic tests of the arithmetics", () {
    var point1 = new Point(x: 1, y: 2, z: 1);
    var point2 = new Point(x: 0, y: 4, z: 4);
    var vector1 = new Vector(x: 2, y: 0, z: 0);
    var vector2;

    expect(point1.toString(), "(1|2|1)");
    expect(point2.toString(), "(0|4|4)");

    vector2 = point1 - point2;
    // log(vector2.toString());

    vector1 = vector1 + vector2;
    // log(vector1.toString());

    point1 = point1 + vector1;
    expect(point1.toString(), "(4|0|-2)");

    point2 = point2.subtractVector(vector2);
    expect(point2.toString(), "(-1|6|7)");
  });

  test("Basic tests of matrix-multiplication", () {
    var matrixA = Matrix.empty(3, 2);
    matrixA[0][0] = 1;
    matrixA[0][1] = 2;
    matrixA[0][2] = 3;
    matrixA[1][0] = 4;
    matrixA[1][1] = 5;
    matrixA[1][2] = 6;
    log("A:");
    log(matrixA.toString());
    expect(matrixA.values, [1, 2, 3, 4, 5, 6]);

    var matrixB = Matrix.empty(2, 3);
    matrixB[0][0] = 7;
    matrixB[0][1] = 8;
    matrixB[1][0] = 9;
    matrixB[1][1] = 10;
    matrixB[2][0] = 11;
    matrixB[2][1] = 12;
    log("B:");
    log(matrixB.toString());
    expect(matrixB.values, [7, 8, 9, 10, 11, 12]);

    var matrixC = matrixA * matrixB;
    log("C:");
    log(matrixC.toString());
    expect(matrixC.width, 2);
    expect(matrixC.height, 2);
    expect(matrixC.values, [58, 64, 139, 154]);
  });
}
