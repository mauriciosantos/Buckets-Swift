//
//  Matrix.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/11/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation
import Accelerate

public struct Matrix<T> {
    
    // MARK: Creating a Matrix
    
    public init(rows: Int, columns: Int, repeatedValue: T) {
        if rows <= 0 {
            fatalError("Can't create matrix. Invalid number of rows.")
        }
        if columns <= 0 {
            fatalError("Can't create matrix. Invalid number of columns")
        }
        
        self.rows = rows
        self.columns = columns
        grid = Array(count: rows * columns, repeatedValue: repeatedValue)
    }
    
    public init(rows: Int, columns: Int, grid: [T]) {
        if grid.count != rows*columns {
            fatalError("Can't create matrix. grid.count must equal rows*columns")
        }
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    
    // MARK: Querying a Matrix
    
    public let rows: Int
    public let columns: Int
    
    /// The one dimensional array backing the matrix in row-major order.
    /// Matrix[i,j] == grid[i*columns + j]
    public private(set) var grid: [T]
    
    public var transpose: Matrix<T> {
        var result = Matrix(rows: columns, columns: rows, repeatedValue: self[0,0])
        for i in 0..<rows {
            for j in 0..<columns {
                result[j,i] = self[i,j]
            }
        }
        return result
    }
    
    // MARK: Getting and Setting elements
    
    public subscript(row: Int, column: Int) -> T {
        get {
            if indexIsValidForRow(row, column: column) {
                fatalError("Index out of range")
            }
            return grid[(row * columns) + column]
        }
        set {
            if indexIsValidForRow(row, column: column) {
                fatalError("Index out of range")
            }
            grid[(row * columns) + column] = newValue
        }
    }
    
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}

/// Returns `true` if and only if the matrices contain the same elements
/// at the same coordinates.
/// The underlying elements must conform to the `Equatable` protocol.
public func ==<T: Equatable>(lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
    return lhs.columns == rhs.columns && lhs.rows == rhs.rows &&
        lhs.grid == rhs.grid
}

public func !=<T: Equatable>(lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
    return !(lhs == rhs)
}

// MARK: Linear Algebra Matrix Operations

// Addition

public func +(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.rows != rhs.rows || lhs.columns != rhs.columns {
        fatalError("Impossible to add different size matrices")
    }
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeatedValue: 0)
    vDSP_vaddD(lhs.grid, 1, rhs.grid, 1, &result.grid, 1, vDSP_Length(lhs.grid.count))
    return result
}

public func +=(inout lhs: Matrix<Double>, rhs: Matrix<Double>) {
    lhs.grid = (lhs + rhs).grid
}

public func +(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var scalar = rhs
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeatedValue: 0)
    vDSP_vsaddD(lhs.grid, 1, &scalar, &result.grid, 1, vDSP_Length(lhs.grid.count))
    return result
}

public func +(lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return rhs + lhs
}

public func +=(inout lhs: Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs + rhs).grid
}

// Substraction

public func -(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.rows != rhs.rows || lhs.columns != rhs.columns {
        fatalError("Impossible to substract different size matrices.")
    }
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeatedValue: 0)
    vDSP_vsubD(lhs.grid, 1, rhs.grid, 1, &result.grid, 1, vDSP_Length(lhs.grid.count))
    return result
}

public func -=(inout lhs: Matrix<Double>, rhs: Matrix<Double>) {
    lhs.grid = (lhs - rhs).grid
}

public func -(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    return lhs + (-rhs)
}

public func -=(inout lhs: Matrix<Double>, rhs: Double) {
    lhs.grid = (lhs - rhs).grid
}

// Negation

public prefix func -(m: Matrix<Double>) -> Matrix<Double> {
    var result = Matrix<Double>(rows: m.rows, columns: m.columns, repeatedValue: 0)
    vDSP_vnegD(m.grid, 1, &result.grid, 1, vDSP_Length(m.grid.count))
    return result
}

// Multiplication

public func *(lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    if lhs.columns != rhs.rows {
        fatalError("Matrix product is undefined: first.columns != second.rows")
    }
    var result = Matrix<Double>(rows: lhs.rows, columns: rhs.columns, repeatedValue: 0)
    vDSP_mmulD(lhs.grid, 1, rhs.grid, 1, &result.grid, 1, vDSP_Length(lhs.rows),
        vDSP_Length(rhs.columns), vDSP_Length(lhs.columns))
    return result
}

public func *(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var scalar = rhs
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeatedValue: 0)
    vDSP_vsmulD(lhs.grid, 1, &scalar, &result.grid, 1, vDSP_Length(lhs.grid.count))
    return result
}

public func *(lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return rhs*lhs
}

// Division

public func /(lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var scalar = rhs
    var result = Matrix<Double>(rows: lhs.rows, columns: lhs.columns, repeatedValue: 0)
    vDSP_vsdivD(lhs.grid, 1, &scalar, &result.grid, 1, vDSP_Length(lhs.grid.count))
    return result
}

// Inversion

public func invert(matrix: Matrix<Double>) -> Matrix<Double>? {
    if matrix.columns != matrix.rows {
        fatalError("Can't invert a non-square matrix.")
    }
    var inMatrix = matrix
    var N = __CLPK_integer(sqrt(Double(inMatrix.grid.count)))
    var pivots = [__CLPK_integer](count: Int(N), repeatedValue: 0)
    var workspace = [Double](count: Int(N), repeatedValue: 0.0)
    var error : __CLPK_integer = 0
    dgetrf_(&N, &N, &inMatrix.grid, &N, &pivots, &error)
    dgetri_(&N, &inMatrix.grid, &N, &pivots, &workspace, &N, &error)
    if error != 0 {
        return nil
    }
    return inMatrix
}

