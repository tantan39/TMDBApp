//
//  ViewController.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/7/22.
//

import UIKit
import SDWebImage

struct MovieCellController: Hashable {
    let id: AnyHashable
    let title: String
    let pathImage: String
    let description: String
    
    internal init(id: AnyHashable, title: String, pathImage: String, description: String) {
        self.id = id
        self.title = title
        self.pathImage = pathImage
        self.description = description
    }
    
    var posterURL: URL {
        let url = URL(string: "\(ROOT)\(pathImage)")!
        return url
    }
}

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
}

class ViewController: UITableViewController {

    lazy var datasource = UITableViewDiffableDataSource<Int, MovieCellController>(tableView: tableView) { tableView, indexPath, controller in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return UITableViewCell() }
        cell.titleLabel.text = controller.title
        cell.descriptionLabel.text = controller.description
        cell.poster.sd_setImage(with: controller.posterURL, placeholderImage: UIImage(named: "placeHolder"))
        cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        fetchMovies()
    }

    func fetchMovies() {
        let apiService = FeedAPIService()
        apiService.fetchPopularMovies(page: 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(movies):
                let controllers = movies.map { MovieCellController(id: $0.id, title: $0.title, pathImage: $0.poster_path, description: $0.overview) }
                var snapshot = NSDiffableDataSourceSnapshot<Int,MovieCellController>()
                snapshot.appendSections([0])
                snapshot.appendItems(controllers, toSection: 0)
                self.datasource.apply(snapshot)
                
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

