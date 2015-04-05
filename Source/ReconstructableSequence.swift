//
//  ReconstructableSequence.swift
//  Buckets
//
//  Created by Mauricio Santos on 4/3/15.
//  Copyright (c) 2015 Mauricio Santos. All rights reserved.
//

import Foundation

/// A sequence that can be constructed from its generator elements.
public protocol ReconstructableSequence: SequenceType {
    init<S: SequenceType where S.Generator.Element == Generator.Element>(_ elements: S)
}

/// lala
extension String: ReconstructableSequence {}
extension Array: ReconstructableSequence {}