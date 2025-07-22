//
//  NFTView.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI

// TODO: Finish up implementation for tvOS demo
// struct NFTView: View {
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
// }
