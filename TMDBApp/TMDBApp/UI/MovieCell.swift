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
    
    var posterURL: URL? {
        let url = URL(string: "\(ROOT_IMAGE)w500/\(pathImage)")
        return url
    }
    
    func view(in tableView: UITableView, forItemAt indexPath: IndexPath) -> MovieCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return MovieCell() }
        cell.titleLabel.text = self.title
        cell.descriptionLabel.text = self.description
        cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        return cell
    }
}

extension MovieCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
