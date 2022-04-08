//
//  MovieCell.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit

class MovieCell: UITableViewCell {
    lazy var poster: UIImageView = {
        let imgv = UIImageView()
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.backgroundColor = .yellow
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupUI()
    }
    
    private func setupUI() {
        addSubview(poster)
        NSLayoutConstraint.activate([
            poster.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            poster.heightAnchor.constraint(equalToConstant: 200),
            poster.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
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
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
        ])
    }
    
    func configCell(_ controller: MovieCellController) {
        titleLabel.text = controller.title
        descriptionLabel.text = controller.description
        poster.sd_setImage(with: controller.posterURL, placeholderImage: UIImage(named: "placeHolder"))
    }
}


struct MovieCellController {
    let id: Int
    let title: String
    let pathImage: String
    let description: String
    
    internal init(id: Int, title: String, pathImage: String, description: String) {
        self.id = id
        self.title = title
        self.pathImage = pathImage
        self.description = description
    }
    
    var posterURL: URL {
        let url = URL(string: "\(ROOT_IMAGE)/\(pathImage)")!
        return url
    }
}

extension MovieCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
