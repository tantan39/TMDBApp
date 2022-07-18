//
//  LoadMoreCellController.swift
//  TMDBApp
//
//  Created by Tan Tan on 7/18/22.
//

import UIKit

public class LoadMoreCellController: Hashable {
    let id: AnyHashable = UUID()
    private var viewModel: LoadMoreCellViewModel
    
    internal init(viewModel: LoadMoreCellViewModel) {
        self.viewModel = viewModel
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell") as? LoadMoreCell else { return UITableViewCell() }
        return cell
    }
    
    func loadMore() {
        self.viewModel.loadMore()
    }

    public static func == (lhs: LoadMoreCellController, rhs: LoadMoreCellController) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
