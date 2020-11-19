//
//  FeedController.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-13.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedController: UICollectionViewController {
    
    private var rides: [RideMetrics]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        let coreData = CoreDataServices()
        rides = coreData.retrieveAllRideStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadRides() {
        let coreData = CoreDataServices()
        rides = coreData.retrieveAllRideStats()
        self.collectionView.reloadData()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func updateFeed() {
        let defaults = UserDefaults.standard
        let currentRide = defaults.integer(forKey: "RideID")

        let coreData = CoreDataServices()
        let aRide = coreData.retrieveRideStats(rideID: currentRide - 1)
        rides?.append(aRide)
        self.collectionView.reloadData()
    }
    
    
}


// MARK: UIColllectionViewDataSource
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rides!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.viewModel = RideViewModel(ride: rides![indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 110
        
        return CGSize(width: width, height: height)
    }
}
