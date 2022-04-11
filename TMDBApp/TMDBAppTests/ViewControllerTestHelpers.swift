//
//  ViewControllerTestHelpers.swift
//  TMDBAppTests
//
//  Created by Tan Tan on 4/10/22.
//

import UIKit
@testable import TMDBApp

extension ViewController {
    func cellForRowAt(row: Int, section: Section) -> UITableViewCell? {
        tableView.cellForRow(at: IndexPath(row: row, section: section.hashValue))
    }
    
    func simulateLoadMore() {
        let scrollView = DraggingScrollView()
        scrollView.contentOffset.y = 1000
        scrollViewDidScroll(scrollView)
    }
    
    func simulateItemVisible(at index: Int, section: Section) -> UITableViewCell? {
        let cell = self.datasource.tableView(self.tableView, cellForRowAt: IndexPath(row: index, section: section.rawValue))
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(item: index, section: section.rawValue)
        delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        return cell
    }
}
