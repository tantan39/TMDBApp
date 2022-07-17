//
//  MovieCell.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit

class MovieCell: UITableViewCell {
    var poster: UIImageView = {
        let imgv = UIImageView()
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.backgroundColor = .black
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    lazy var favoriteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "star")
        return imageView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(poster)
        NSLayoutConstraint.activate([
            poster.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            poster.heightAnchor.constraint(equalToConstant: 200),
            poster.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: poster.bottomAnchor, constant: -16),
        ])
        
        addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
        ])
    }
}


class MovieCellController {
    private let movie: Movie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    
    internal init(movie: Movie, imageLoader: ImageDataLoader) {
        self.movie = movie
        self.imageLoader = imageLoader
    }
    
    var posterURL: URL? {
        let url = URL(string: "\(ROOT_IMAGE)w500/\(self.movie.poster_path)")
        return url
    }
    
    func view(in tableView: UITableView, forItemAt indexPath: IndexPath) -> MovieCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return MovieCell() }
        cell.titleLabel.text = self.movie.title
        cell.descriptionLabel.text = self.movie.overview
        cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        cell.poster.image = nil
        cell.isShimmering = true
        if let url = posterURL {
            self.task = self.imageLoader.loadImageData(from: url) { [weak cell] result in
                let data = try? result.get()
                DispatchQueue.main.async { [weak cell] in
                    cell?.isShimmering = false
                    cell?.poster.setImageAnimated(data.map(UIImage.init) ?? nil)
                }
            }
        }
        return cell
    }
    
    func preload() {
        if let url = posterURL {
            self.task = self.imageLoader.loadImageData(from: url, completion: { _ in })
        }
    }
    
    deinit {
        task?.cancel()
    }
}

extension MovieCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(movie.id)
    }

    static func == (lhs: MovieCellController,
                        rhs: MovieCellController) -> Bool {
        lhs.movie.id == rhs.movie.id
        }
}
