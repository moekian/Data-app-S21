//
//  Book.swift
//  Data app S21
//
//  Created by Mohammad Kiani on 2021-05-19.
//

import Foundation

class Book {
    internal init(title: String, author: String, pages: Int, year: Int) {
        self.title = title
        self.author = author
        self.pages = pages
        self.year = year
    }
    
    var title: String
    var author: String
    var pages: Int
    var year: Int
    
}

//var books: [Book]?
