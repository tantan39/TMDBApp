//
//  MovieDetailVC.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation
import UIKit

class MovieDetailVC: UIViewController {
    lazy var backdropImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    var movieID: Int?
    let service = FeedAPIService()
    
    convenience init(movieID: Int) {
        self.init()
        self.movieID = movieID
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        setupUI()
        getDetail()
    }
    
    private func setupUI() {
        setupBackdrop()
        setupTitle()
        setupOverviewLabel()
        setupDetailLabel()
    }
    
    private func setupBackdrop() {
        view.addSubview(backdropImageView)
        NSLayoutConstraint.activate([
            backdropImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 30)
        ])
    }
    
    private func setupOverviewLabel() {
        view.addSubview(overviewLabel)
        NSLayoutConstraint.activate([
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupDetailLabel() {
        view.addSubview(detailsLabel)
        NSLayoutConstraint.activate([
            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func getDetail() {
        guard let id = movieID else {
            return
        }
        service.getMovieDetail(id) { result in
            switch result {
            case let .success(movie):
                self.configView(movie)
            default:
                break
            }
        }
    }
    
    private func configView(_ movie: Movie) {
        self.backdropImageView.sd_setImage(with: movie.backDropURL, placeholderImage: UIImage(named: "placeHolder"), options: .refreshCached)
        self.titleLabel.text = movie.title
        self.overviewLabel.text = movie.overview
        
        let attributeString = NSMutableAttributedString(string: "Revenue: \(movie.revenue ?? 0)", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ])
        
        attributeString.append(NSAttributedString(string: "\nRelease: \(movie.release_date ?? "")", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]))
        
        self.detailsLabel.attributedText = attributeString
    }
}
