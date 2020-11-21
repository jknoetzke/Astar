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
        
    private let distanceLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Distance"
        return label
    }()
    
    private let wattsLbl: UILabel = {
        let label = UILabel()
        label.text = "Avg Watts"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private let rideTimeLbl: UILabel = {
        let label = UILabel()
        label.text = "Ride Time"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private let elevationLbl: UILabel = {
        let label = UILabel()
        label.text = "Elevation"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let wattsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let rideTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let elevationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    
    //MARK: - Lifecycle
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(headerImageView)
        headerImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop:10, paddingLeft: 1)
        headerImageView.setDimensions(height: 40, width: 40)
        headerImageView.layer.cornerRadius = 40 / 2
        
        addSubview(dateRideButton)
        dateRideButton.centerY(inView: headerImageView, leftAnchor: headerImageView.rightAnchor, paddingLeft: 8)
        
        addSubview(postImageView)
        postImageView.anchor(top: headerImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 2)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        postImageView.setDimensions(height: 340, width: 374)
       
        
        addSubview(rideTimeLabel)
        rideTimeLabel.anchor(top: postImageView.bottomAnchor, left: leftAnchor, paddingTop: 2, paddingLeft: 8)
                
        addSubview(wattsLabel)
        wattsLabel.anchor(top: rideTimeLabel.bottomAnchor, left: leftAnchor, paddingTop: 2, paddingLeft: 8)
       
        addSubview(distanceLabel)
        distanceLabel.anchor(top: wattsLabel.bottomAnchor, left: leftAnchor, paddingTop: 2, paddingLeft: 8)
       
        let stackView = UIStackView(arrangedSubviews: [rideTimeLbl, wattsLbl, distanceLbl, elevationLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, paddingTop: 2, width: 380, height: 18)  //Height of the row

        let stackView1 = UIStackView(arrangedSubviews: [rideTimeLabel, wattsLabel, distanceLabel, elevationLabel])
        stackView1.axis = .horizontal
        stackView1.distribution = .fillEqually
        addSubview(stackView1)
        stackView1.anchor(top: stackView.bottomAnchor, paddingTop: 8, width: 380, height: 16)

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
        rideTimeLabel.text = rideTime
        
        wattsLabel.text = String(viewModel.avgWatts)
        
        let distance = String(viewModel.distance / 1000)
        distanceLabel.text = String(distance + "km")
        
        let mapImage = CoreDataServices.load(fileName: viewModel.filePath)
        postImageView.image = mapImage
        headerImageView.image = mapImage
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let date = formatter.string(from: viewModel.rideDate)
        dateRideButton.setTitle(date, for: .normal)
    
        elevationLabel.text = String(viewModel.elevation)
    
    
    }
}
