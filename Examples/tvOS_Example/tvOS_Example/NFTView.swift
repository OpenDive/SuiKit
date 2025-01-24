//
//  NFTView.swift
//  SKtvOSDemo
//
//  Created by Marcus Arnett on 10/15/24.
//

import SwiftUI

//struct NFTView: View {
//    @StateObject private var articleCategoriesVM = ArticleCategoriesViewModel()
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(alignment: .leading, spacing: 48) {
//                ForEach(articleCategoriesVM.categoryArticles, id: \.category) { category in
//                    ArticleCarouselView(title: category.category.text, articles: category.articles)
//                }
//            }
//        }
//        .overlay(self.overlayView)
//        .task {
//            self.refreshTask()
//        }
//    }
//
//    @ViewBuilder
//    private var overlayView: some View {
//        switch articleCategoriesVM.phase {
//        case .empty:
//            ProgressView()
//        case .success(let articles) where articles.isEmpty:
//            EmptyPlaceholderView(text: "No Articles", image: nil)
//        case .failure(let error):
//            RetryView(text: error.localizedDescription, retryAction: self.refreshTask)
//        default:
//            EmptyView()
//        }
//    }
//
//    private func refreshTask() {
//        Task {
//            await self.articleCategoriesVM.loadCategoryArticles(withPreview: true)
//        }
//    }
//}
