//
//  MovieDetailVC.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import Foundation
import UIKit

struct FavoriteItem {
    let id: Int
    let status: Bool
}

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
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
//        button.setTitle("Favorite", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        return button
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
    private var imageLoader: ImageDataLoader?
    private var task: ImageDataLoaderTask?
    
    var isFavorited: Bool = false {
        didSet {
            let icon = isFavorited ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            favoriteButton.setImage(icon, for: .normal)
        }
    }
    
    var favoriteButtonOnClick: ((FavoriteItem) -> Void)?
    
    convenience init(service: FeedLoader, imageLoader: ImageDataLoader, movieID: Int, didFavorited: ((FavoriteItem) -> Void)?) {
        self.init()
        self.apiService = service
        self.imageLoader = imageLoader
        self.movieID = movieID
        self.favoriteButtonOnClick = didFavorited
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        setupUI()
        getDetail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.task = nil
    }
    
    private func setupUI() {
        setupScrollView()
        setupContainerView()
        setupBackdrop()
        setupTitle()
        setupFavoriteButton()
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
    
    private func setupFavoriteButton() {
        containerView.addSubview(favoriteButton)
        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            favoriteButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            favoriteButton.widthAnchor.constraint(equalToConstant: 100),
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
    
    @objc func favoriteButtonTapped() {
        guard let movieID = movieID else {
            return
        }
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        let item = FavoriteItem(id: movieID, status: true)
        self.favoriteButtonOnClick?(item)
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
        if let url = movie.backDropURL {
            self.task = imageLoader?.loadImageData(from: url, completion: { result in
                if let data = try? result.get() {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.backdropImageView.setImageAnimated(image)
                    }
                }
            })
        }

        self.titleLabel.text = movie.title
        self.overviewLabel.text = "Description: \(movie.overview)"
        
        let attributeString = NSMutableAttributedString(string: "Revenue: \(movie.revenue ?? 0)", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ])
        
        attributeString.append(NSAttributedString(string: "\nRelease: \(movie.release_date ?? "")", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]))
        
        self.detailsLabel.attributedText = attributeString
        
        UIView.transition(with: self.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.backdropImageView.isHidden = false
            self.titleLabel.isHidden = false
            self.overviewLabel.isHidden = false
            self.detailsLabel.isHidden = false
        })
    }
}
