//
//  MatrixOperators.swift
//  Buckets
//
//  Created by Mauricio Santos on 2016-02-03.
//  Copyright © 2016 Mauricio Santos. All rights reserved.
//

#if os(OSX) || os(iOS)
import Foundation
import Accelerate

// MARK: Matrix Linear Algebra Operations

// Inversion

/// Returns the inverse of the given matrix or nil if it doesn't exist.
/// If the argument is a non-square matrix an error is triggered.
/// Comments and improvements from: http://connor-johnson.com/2015/10/07/matrix-inversion-using-swift-and-accelerate/
public func inverse(_ matrix: Matrix<Double>) -> Matrix<Double>? {
    if matrix.columns != matrix.rows {
        fatalError("Can't invert a non-square matrix.")
    }
    var invMatrix = matrix
    // Get the dimensions of the matrix. An NxN matrix has N^2
    // elements, so sqrt( N^2 ) will return N, the dimension.
    var N = __CLPK_integer(sqrt(Double(invMatrix.grid.count)))
    // Initialize some arrays for the dgetrf_(), and dgetri_() functions.
    var pivots = [__CLPK_integer](repeating: 0, count: Int(N))
    var workspace = [Double](repeating: 0.0, count: Int(N))
    
    return withUnsafeMutablePointer(to: &N) {
        var error: __CLPK_integer = 0
    
        return
            // Perform LU factorization.
            dgetrf_($0, $0, &invMatrix.grid, $0, &pivots, &error) == 0 &&
            // Calculate inverse from LU factorization.
            dgetri_($0, &invMatrix.grid, $0, &pivots, &workspace, $0, &error) == 0 ?
                invMatrix : nil
    }
}

// Addition

/// Performs matrix and matrix addition.
public func +(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.rows != rhs.rows || lhs.columns != rhs.columns {
        fatalError("Impossible to add different size matrices")
    }
    var result = rhs
    cblas_daxpy(Int32(lhs.grid.count), 1.0, lhs.grid, 1, &(result.grid), 1)
    return result
}

/// Performs matrix and matrix addition.
public func +=(lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs.grid = (lhs + rhs).grid
}

/// Performs matrix and scalar addition.
public func +(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    let scalar = rhs
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeating: scalar)
    cblas_daxpy(Int32(lhs.grid.count), 1, lhs.grid, 1, &(result.grid), 1)
    return result
}

/// Performs scalar and matrix addition.
public func +(lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return rhs + lhs
}

/// Performs matrix and scalar addition.
public func +=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs + rhs).grid
}

// Subtraction

/// Performs matrix and matrix subtraction.
public func -(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.rows != rhs.rows || lhs.columns != rhs.columns {
        fatalError("Impossible to substract different size matrices.")
    }
    var result = lhs
    cblas_daxpy(Int32(lhs.grid.count), -1.0, rhs.grid, 1, &(result.grid), 1)
    return result
}

/// Performs matrix and matrix subtraction.
public func -=(lhs: inout Matrix<Double>, rhs: Matrix<Double>) {
    lhs.grid = (lhs - rhs).grid
}

/// Performs matrix and scalar subtraction.
public func -(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    return lhs + (-rhs)
}

/// Performs matrix and scalar subtraction.
public func -=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs - rhs).grid
}

// Negation

/// Negates all the values in a matrix.
public prefix func -(m: Matrix<Double>) -> Matrix<Double> {
    var result = m
    cblas_dscal(Int32(m.grid.count), -1.0, &(result.grid), 1)
    return result
}

// Multiplication

/// Performs matrix and matrix multiplication.
/// The first argument's number of columns must match the second argument's number of rows,
/// otherwise an error is triggered.
public func *(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.columns != rhs.rows {
        fatalError("Matrix product is undefined: first.columns != second.rows")
    }
    var result = Matrix<Double>(rows: lhs.rows, columns: rhs.columns, repeating: 0.0)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(lhs.rows), Int32(rhs.columns),
        Int32(lhs.columns), 1.0, lhs.grid, Int32(lhs.columns), rhs.grid, Int32(rhs.columns),
        0.0, &(result.grid), Int32(result.columns))
    
    return result
}

/// Performs matrix and scalar multiplication.
public func *(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var result = lhs
    cblas_dscal(Int32(lhs.grid.count), rhs, &(result.grid), 1)
    return result
}

/// Performs scalar and matrix multiplication.
public func *(lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return rhs*lhs
}

/// Performs matrix and scalar multiplication.
public func *=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs*rhs).grid
}

// Division

/// Performs matrix and scalar division.
public func /(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    return lhs * (1/rhs)
}

/// Performs matrix and scalar division.
public func /=(lhs: inout Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs/rhs).grid
}
#endif
