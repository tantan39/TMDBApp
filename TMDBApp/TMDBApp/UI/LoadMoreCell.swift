//
//  LoadMoreCell.swift
//  TMDBApp
//
//  Created by Tan Tan on 4/8/22.
//

import UIKit
import Combine

public class LoadMoreCellController: Hashable {
    let id: AnyHashable = UUID()
    private var page: Int = 1
    private var isLoadMore: Bool = false
    private var apiService: FeedLoader
    private var cancellables = Set<AnyCancellable>()
    var onPaging: ([Movie]) -> Void = { _ in }
    
    internal init(apiService: FeedLoader) {
        self.apiService = apiService
    }
    
    func view(in tableView: UITableView, forItemAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell") as? LoadMoreCell else { return UITableViewCell() }
        return cell
    }
    
    func loadMore() {
        guard !isLoadMore else { return }
        isLoadMore = true
        self.page += 1
        
        apiService.fetchPopularMovies(page: page)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { error in
            }, receiveValue: { [weak self] movies in
                self?.isLoadMore = false
                self?.onPaging(movies)
            })
            .store(in: &cancellables)
    }

    public static func == (lhs: LoadMoreCellController, rhs: LoadMoreCellController) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class LoadMoreCell: UITableViewCell {
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
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
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        spinner.startAnimating()
    }
}
