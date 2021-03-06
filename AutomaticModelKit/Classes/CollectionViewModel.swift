//
//  CollectionViewModel.swift
//  AutomaticModelKit
//
//  Created by Georges Boumis on 13/04/2018.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//


import Foundation

/// A one-dimension generic collection view model of homogenous entries that is
/// specialized by the type `T` for each entry and the cell `Cell` type.
/// A `CollectionViewModel` acts as a `Collection` of `T` elements.
///
/// `T` can by of any type.
///
/// `Cell` can be any subtype of `UICollectionViewCell`.
///
/// Example a collection view is to be filled with entries of type `Book` using
/// `UICollectionViewCell`s:
///
/// ```swift
/// let books = [Book]()
/// let model = CollectionViewModel<Book, UICollectionViewCell>(entries: books) { book, cell in
/// /* configure cell with book */
/// }
/// model.register(onCollectionView: collectionView)
/// ```
/// Should you require an index then just pass an `.enumerated()` books.
///
/// ```swift
/// let books = [Book]()
/// let model = CollectionViewModel<(Int,Book), UICollectionViewCell>(entries: books.enumerated()) { enumeratedEntry, cell in
/// /* configure cell with book with enumeratedEntry.offset & enumeratedIndex.element */
/// }
/// model.register(onCollectionView: collectionView)
/// ```
open class CollectionViewModel<T, Cell>: NSObject, Collection, UICollectionViewDataSource where Cell: UICollectionViewCell {
    final private let entries: [T]
    public typealias Configuration = (T, Cell) -> Void
    final private let configuration: Configuration
    
    public init(entries: [T],
         configuration: @escaping Configuration) {
        self.entries = entries
        self.configuration = configuration
    }
    
    final public var cellType: Cell.Type {
        return Cell.self
    }
    final public var cellIdentifier: String {
        return String(describing: type(of: Cell.self))
    }

    /// Registers the model with the given collection view.
    ///
    /// Registering to a collection view means the model register the `cellType`
    /// with `cellIdentifier` to the collection view and sets the receiver as the
    /// the data source of the collection view. If the receiver conforms to
    /// `UICollectionViewDelegate` it sets the receiver as the delegate of the
    /// collection view.
    /// - parameter collectionView: the collection view to register with.
    final public func register(onCollectionView collectionView: UICollectionView) {
        self._register(onCollectionView: collectionView)
        if let delegate = self as? UICollectionViewDelegate {
            collectionView.delegate = delegate
        }
    }
    
    final fileprivate func _register(onCollectionView collectionView: UICollectionView) {
        collectionView.register(self.cellType,
                                forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.dataSource = self
    }
    
    final public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    final public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.entries.count
    }
    
    final public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier,
                                                      for: indexPath) as! Cell
        self.configuration(self[indexPath.row], cell)
        return cell
    }
    
    // MARK: Collection conformance
    final public var startIndex: Int { return self.entries.startIndex }
    final public var endIndex: Int { return self.entries.endIndex }
    final public subscript(i: Int) -> T { return self.entries[i] }
    final public func index(after i: Int) -> Int { return self.entries.index(after: i) }
}

open class MultidimensionCollectionViewModel<T, Cell>: NSObject, UICollectionViewDataSource where Cell: UICollectionViewCell {
    final private let options: [[T]]
    public typealias Configuration = (T, Cell) -> Void
    final private let configuration: Configuration
    
    public init(options: [[T]],
         configuration: @escaping Configuration) {
        self.options = options
        self.configuration = configuration
    }
    
    final public var cellType: Cell.Type {
        return Cell.self
    }
    final public var cellIdentifier: String {
        return String(describing: type(of: Cell.self))
    }
    
    final public func register(onCollectionView collectionView: UICollectionView) {
        self._register(onCollectionView: collectionView)
        if let delegate = self as? UICollectionViewDelegate {
            collectionView.delegate = delegate
        }
    }
    
    final fileprivate func _register(onCollectionView collectionView: UICollectionView) {
        collectionView.register(self.cellType,
                                forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.dataSource = self
    }
    
    final public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.options.count
    }
    
    final public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.options[section].count
    }
    
    final public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier,
                                                      for: indexPath) as! Cell
        self.configuration(self.options[indexPath.section][indexPath.row], cell)
        return cell
    }
    //
    //    // MARK: Collection conformance
    //    final var startIndex: Int { return self.options.startIndex }
    //    final var endIndex: Int { return self.options.endIndex }
    //    final subscript(i: Int) -> T { return self.options[i] }
    //    final func index(after i: Int) -> Int { return self.options.index(after: i) }
}

