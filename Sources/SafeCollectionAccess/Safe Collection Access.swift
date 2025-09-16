//
//  Safe Collection Access.swift
//  Safe Collection Access
//
//  Created by Ben Leggiero on 2019-12-06.
//  Copyright © 2019 Ben Leggiero BH-1-PS.
//



// MARK: - `contains`

public extension RandomAccessCollection {
    
    /// Determines whether this collection has an item at the given index
    ///
    /// - Parameter index: An index that might be in this collection
    /// - Returns: `true` iff `index` points to an item that's in this collection
    func contains(index: Index) -> Bool {
        indices.contains(index)
    }
    
    
    /// Determines whether this collection contains all the indices in the given index
    ///
    /// This is a naïve iteration over all the indices in this collection
    ///
    /// - Complexity: O(n)
    ///
    /// - Parameter otherIndices: Some indices which might point to items in this collection
    /// - Returns: `false` if any of the given indices
    func contains<Indices>(allIn otherIndices: Indices) -> Bool
        where Indices: Sequence,
            Indices.Element == Index
    {
        otherIndices.allSatisfy { indices.contains($0) }
    }
}



// MARK: - `[orNil: ]`

public extension RandomAccessCollection {
    
    /// Safely access an element in this collection. If the index you pass is not in this collection, then `nil` is returned.
    ///
    /// - Parameter index: The index of the element to retrieve, or an index outside this collection
    /// - Returns: The element which is in this collection at the given index, or `nil` if it's outside this collection
    @inlinable
    subscript(orNil index: Index) -> Element? {
        return contains(index: index)
            ? self[index]
            : nil
    }
    
    
    /// Safely access or mutate an element in this collection. If the index you pass is not in this collection, then `nil` is returned, or if you're trying to mutate this collection, nothing is done.
    /// Setting the value to `nil` is interpreted as removing the element from this collection.
    ///
    /// - Parameter index: The index of the element to retrieve or modify, or an index outside this collection
    /// - Returns: The element which is in this collection at the given index, or `nil` if it's outside this collection
    @inlinable
    subscript(orNil index: Index) -> Element?
        where Self: MutableCollection,
            Self: RangeReplaceableCollection
    {
        get {
            contains(index: index)
                ? self[index]
                : nil
        }
        
        set {
            guard contains(index: index) else { return }
            
            if let newValue = newValue {
                self[index] = newValue
            }
            else {
                self.remove(at: index)
            }
        }
    }
}



// MARK: - `[clamping: ]`

public extension RandomAccessCollection {
    
    /// Safely access an element in this collection. If the index you pass is not in this collection, the closest extreme is returned. If this collection is empty (and thus there is no such extreme to return), then `nil` is returned.
    ///
    /// - Parameter index: The index of the element to retrieve, or an index outside this collection
    /// - Returns: The element which is in this collection at the given index, or the closest one if it's outside this
    ///            collection, or `nil` if this collection is empty
    @inlinable
    subscript(clamping index: Index) -> Element? {
        if isEmpty {
            return nil
        }
        else if index < startIndex {
            return first
        }
        else if index >= endIndex {
            return last
        }
        else {
            return self[index]
        }
    }
    
    /// Safely access or mutate  an element in this collection. If the index you pass is not in this collection, the closest extreme is returned. If this collection is empty (and thus there is no such extreme to return), then `nil` is returned. When mutating this collection, the provided index is set, or the closest extreme index, unless the collection is empty, in which case no action is taken. Setting a slot to `nil` signifies removing that element
    ///
    /// - Parameter index: The index of the element to retrieve, or an index outside this collection
    /// - Returns: The element which is in this collection at the given index, or the closest one if it's outside this
    ///            collection, or `nil` if this collection is empty
    @inlinable
    subscript(clamping index: Index) -> Element?
    where Self: RangeReplaceableCollection,
          Self: MutableCollection
    {
        get {
            if isEmpty {
                return nil
            }
            else if index < startIndex {
                return first
            }
            else if index >= endIndex {
                return last
            }
            else {
                return self[index]
            }
        }
        
        set {
            if isEmpty {
                return
            }
            else if index < startIndex {
                if let newValue = newValue {
                    self[startIndex] = newValue
                }
                else {
                    self.remove(at: startIndex)
                }
            }
            else if index >= endIndex {
                if let newValue = newValue {
                    self[self.index(endIndex, offsetBy: -1)] = newValue
                }
                else {
                    self.remove(at: self.index(endIndex, offsetBy: -1))
                }
            }
            else {
                if let newValue = newValue {
                    self[index] = newValue
                }
                else {
                    self.remove(at: index)
                }
            }
        }
    }
}



// MARK: - `nil` or `index(before:)`/`index(after:)`

public extension BidirectionalCollection {
    
    /// Returns the position immediately after the given index, or `nil` if there is none.
    ///
    /// The successor of an index must be well defined. For an index `i` into an immutable
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: An index of the collection.
    /// - Returns: The index value immediately after `i`, or `nil` if such an index wouldn't be in the collection.
    func indexOrNil(after i: Index) -> Index? {
        guard i < endIndex else { return nil }
        return index(after: i)
    }
    
    
    /// Replaces the given index with its successor, or `nil` if there is none.
    ///
    /// `i` is set to `nil` if the resulting index wouldn't be in the collection.
    ///
    /// - Parameter i: An index of the collection.
    func formIndexOrNil(after i: inout Index?) {
        guard let nonNilIndex = i else { return }
        i = indexOrNil(after: nonNilIndex)
    }
    
    
    /// Returns the position immediately before the given index, or `nil` if there is none.
    ///
    /// - Parameter i: An index of the collection.
    /// - Returns: The index value immediately before `i`, or `nil` if such an index wouldn't be in the collection.
    func indexOrNil(before i: Index) -> Index? {
        guard i > startIndex else { return nil }
        return index(before: i)
    }
    
    
    /// Replaces the given index with its predecessor, or `nil` if there is none.
    ///
    /// `i` is set to `nil` if the resulting index wouldn't be in the collection.
    ///
    /// - Parameter i: An index of the collection.
    func formIndexOrNil(before i: inout Index?) {
        guard let nonNilIndex = i else { return }
        i = indexOrNil(before: nonNilIndex)
    }
    
    
    /// Returns an index that is the specified distance from the given index, or `nil` if there isn't one.
    ///
    /// - Parameters:
    ///   - i:        A valid index of the collection.
    ///   - distance: The distance to offset `i`. `distance` must not be negative unless the collection conforms to the `BidirectionalCollection` protocol.
    /// - Returns: An index offset by `distance` from the index `i`.
    ///            If `distance` is positive, this is the same value as the result of `distance` calls to `index(after:)`.
    ///            If `distance` is negative, this is the same value as the result of `abs(distance)` calls to `index(before:)`.
    ///            If the index which would be `distance` from `i` would lie outside this collection, this returns `nil`.
    func indexOrNil(_ i: Index, offsetBy distance: Int) -> Index? {
        if distance > 0 {
            index(i, offsetBy: distance, limitedBy: endIndex)
        }
        else if distance < 0 {
            index(i, offsetBy: distance, limitedBy: startIndex)
        }
        else {
            i
        }
    }
}
