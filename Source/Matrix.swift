//
//  Matrix.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/11/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A Matrix is a fixed size generic 2D collection.
/// You can set and get elements using subscript notation. Example:
/// `matrix[row, column] = value`
///
/// This collection also provides linear algebra functions and operators such as
/// `inverse()`, `+` and `*` using Apple's Accelerate framework where vailable. Please note that
/// these operations are designed to work exclusively with `Double` matrices.
/// Check the `Functions` section for more information.
///
/// Conforms to `MutableCollection`,
/// `ExpressibleByArrayLiteral` and `CustomStringConvertible`.
public struct Matrix<T> {
    
    // MARK: Creating a Matrix
    
    /// Constructs a new matrix with all positions set to the specified value.
    public init(rows: Int, columns: Int, repeating repeatedValue: T) {
        precondition(rows >= 0, "Can't create matrix. Invalid number of rows")
        precondition(columns >= 0, "Can't create matrix. Invalid number of columns")
        
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: repeatedValue, count: rows * columns)
    }
    
    /// Constructs a new matrix using a 1D array in row-major order.
    ///
    /// `Matrix[i,j] == grid[i*columns + j]`
    public init(rows: Int, columns: Int, grid: [T]) {
        precondition(grid.count == rows*columns, "Can't create matrix. grid.count must equal rows*columns")

        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    
    /// Constructs a new matrix using a 2D array.
    /// All columns must be the same size, otherwise an error is triggered.
    public init(_ rowsArray: [[T]]) {
        let rows = rowsArray.count
        precondition(rows > 0, "Can't create an empty matrix")
        precondition(rowsArray[0].count > 0, "Can't create a matrix column with no elements")

        let columns = rowsArray[0].count
        for subArray in rowsArray {
            if subArray.count != columns {
                preconditionFailure("Can't create a matrix with different sized columns")
            }
        }
        var grid = Array<T>()
        grid.reserveCapacity(rows*columns)
        for i in 0..<rows {
            for j in 0..<columns {
                grid.append(rowsArray[i][j])
            }
        }
        self.init(rows: rows, columns: columns, grid: grid)
    }
    
    // MARK: Querying a Matrix
    
    /// The number of rows in the matrix.
    public let rows: Int
    
    /// The number of columns in the matrix.
    public let columns: Int
    
    /// The one-dimensional array backing the matrix in row-major order.
    ///
    /// `Matrix[i,j] == grid[i*columns + j]`
    public internal(set) var grid: [T]
    
    /// Returns the transpose of the matrix.
    public var transpose: Matrix<T> {
        var result = Matrix(rows: columns, columns: rows, repeating: self[0,0])
        for i in 0..<rows {
            for j in 0..<columns {
                result[j,i] = self[i,j]
            }
        }
        return result
    }
    
    // MARK: Getting and Setting elements
    
    // Provides random access for getting and setting elements using square bracket notation.
    // The first argument is the row number.
    // The first argument is the column number.
    public subscript(row: Int, column: Int) -> T {
        get {
            precondition(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            precondition(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    
    // MARK: Private Properties and Helper Methods
    
    fileprivate func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}


extension Matrix: MutableCollection {

    
    // MARK: MutableCollectionType Protocol Conformance
    
    public typealias MatrixIndex = Int
    
    /// Always zero, which is the index of the first element when non-empty.
    public var startIndex : MatrixIndex {
        return 0
    }
    
    /// Always `rows*columns`, which is the successor of the last valid subscript argument.
    public var endIndex : MatrixIndex {
        return rows*columns
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    /// Provides random access to elements using the matrix back-end array coordinate
    /// in row-major order.
    /// Matrix[row, column] is preferred.
    public subscript(position: MatrixIndex) -> T {
        get {
            return self[position/columns, position % columns]
        }
        set {
            self[position/columns, position % columns] = newValue
        }
    }
}

extension Matrix: ExpressibleByArrayLiteral {
    
    // MARK: ExpressibleByArrayLiteral Protocol Conformance
    
    /// Constructs a matrix using an array literal.
    public init(arrayLiteral elements: Array<T>...) {
        self.init(elements)
    }
}

extension Matrix: CustomStringConvertible {
    
    // MARK: CustomStringConvertible Protocol Conformance
    
    /// A string containing a suitable textual
    /// representation of the matrix.
    public var description: String {
        var result = "["
        for i in 0..<rows {
            if i != 0 {
                result += ", "
            }
            let start = i*columns
            let end = start + columns
            result += "[" + grid[start..<end].map {"\($0)"}.joined(separator: ", ") + "]"
        }
        result += "]"
        return result
    }
}

// MARK: Matrix Standard Operators

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
