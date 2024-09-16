//
//  CollectionViewViewController.swift
//  HopSpot.
//
//  Created by Yousef Hozayen on 2024-08-22.
//

import UIKit

final class MyCollectionViewController: UIViewController {
    
    // Creating the collection view
    private let collectionView: UICollectionView = {
        // Setting up the layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // Set the scroll direction to vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        
        // Creating the collection view with the layout
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground // Set background color
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        // Set the delegates and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register the cell
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds // Make the collection view take up the whole screen
    }
}

extension MyCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20 // Set the number of items in the section
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .blue // Set the background color of the cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // Handle cell selection
    }
}
