//
//  FeedCell.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-11-13.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    
    var viewModel: RideViewModel? {
        didSet { configure() }
    }
    
    //MARK: - Properties
    
    private let headerImageView: UIImageView = {
    
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        return iv
        
    }()
    
    private lazy var dateRideButton: UIButton = {
        let button = UIButton(type: .system)
       
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(didTapUsername), for: .touchUpInside)
        
        return button
    }()
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
        
    private let distanceLabel: UILabel = {
        let label = UILabel()
        //label.text="Distance: 100km"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let wattsLabel: UILabel = {
        let label = UILabel()
        //label.text="Average Watts: 240"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private let rideTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Lifecycle
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(headerImageView)
        headerImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 1)
        headerImageView.setDimensions(height: 40, width: 40)
        headerImageView.layer.cornerRadius = 40 / 2
        
        addSubview(dateRideButton)
        dateRideButton.centerY(inView: headerImageView, leftAnchor: headerImageView.rightAnchor, paddingLeft: 8)
        
        addSubview(postImageView)
        postImageView.anchor(top: headerImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        //postImageView.setDimensions(height: 280, width: 380)
        
        addSubview(rideTimeLabel)
        rideTimeLabel.anchor(top: postImageView.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        addSubview(wattsLabel)
        wattsLabel.anchor(top: rideTimeLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        addSubview(distanceLabel)
        distanceLabel.anchor(top: wattsLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapUsername() {
        print ("Username Tapped")
    }

    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        let hours = Int(viewModel.rideTime) / 3600
        let minutes = Int(viewModel.rideTime) / 60 % 60
        let seconds = Int(viewModel.rideTime) % 60
        let rideTime = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        rideTimeLabel.text = "Ride Time " + rideTime
        
        wattsLabel.text = String("Average Watts: \(viewModel.avgWatts)")
        
        distanceLabel.text = String("Distance: \(viewModel.distance / 1000)km")
        
        let mapImage = CoreDataServices.load(fileName: viewModel.filePath)
        postImageView.image = mapImage
        headerImageView.image = mapImage
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let date = formatter.string(from: viewModel.rideDate)
        dateRideButton.setTitle(date, for: .normal)
    }
}
