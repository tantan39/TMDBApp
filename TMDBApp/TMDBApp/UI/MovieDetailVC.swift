//
//  MovieDetailVC.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation
import UIKit

class MovieDetailVC: UIViewController {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var backdropImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.contentMode = .scaleAspectFill
        imgv.clipsToBounds = true
        imgv.isHidden = true
        return imgv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.isHidden = true
        return label
    }()
    
    lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    var movieID: Int?
    private var apiService: FeedLoader?
    
    convenience init(service: FeedLoader, movieID: Int) {
        self.init()
        self.apiService = service
        self.movieID = movieID
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        setupUI()
        getDetail()
    }
    
    private func setupUI() {
        setupScrollView()
        setupContainerView()
        setupBackdrop()
        setupTitle()
        setupOverviewLabel()
        setupDetailLabel()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContainerView() {
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    private func setupBackdrop() {
        containerView.addSubview(backdropImageView)
        NSLayoutConstraint.activate([
            backdropImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backdropImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])
    }
    
    private func setupTitle() {
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 30)
        ])
    }
    
    private func setupOverviewLabel() {
        containerView.addSubview(overviewLabel)
        NSLayoutConstraint.activate([
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupDetailLabel() {
        containerView.addSubview(detailsLabel)
        NSLayoutConstraint.activate([
            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 20),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60)
        ])
    }
    
    private func getDetail() {
        guard let id = movieID else {
            return
        }
        apiService?.getMovieDetail(id) { result in
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
        
        UIView.transition(with: self.view, duration: 0.33, options: .transitionCrossDissolve, animations: {
            self.backdropImageView.isHidden = false
            self.titleLabel.isHidden = false
            self.overviewLabel.isHidden = false
            self.detailsLabel.isHidden = false
        })
    }
}
