//
//  ViewController.swift
//  Data app S21
//
//  Created by Mohammad Kiani on 2021-05-19.
//

import UIKit
import CoreData

class BookVC: UIViewController {

    @IBOutlet var textFields: [UITextField]!
    
    var books: [Book]?
//    var bookModel: [BookModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
//        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
//        loadData()
        loadCoreData()
    }
    
    /// get the file path
    func getDataFilePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentPath.appending("/book-data.txt")
        return filePath
    }

    @IBAction func addBook(_ sender: UIBarButtonItem) {
        let title = textFields[0].text ?? ""
        let author = textFields[1].text ?? ""
        let pages = Int(textFields[2].text ?? "0") ?? 0
        let year = Int(textFields[3].text ?? "0000") ?? 0000
        
        let book = Book(title: title, author: author, pages: pages, year: year)
        books?.append(book)
    }
    
    //MARK: - write to files methods
    
    func loadData() {
        let filePath = getDataFilePath()
        books = [Book]()
        if FileManager.default.fileExists(atPath: filePath) {
            // extract data
            
            do {
                // create string of file path
                let fileContent = try String(contentsOfFile: filePath)
                // seperate the books
                let contentArray = fileContent.components(separatedBy: "\n")
                for content in contentArray {
                    // seperate each content of book
                    let bookContent = content.components(separatedBy: ",")
                    if bookContent.count == 4 {
                        let book = Book(title: bookContent[0], author: bookContent[1], pages: Int(bookContent[2])!, year: Int(bookContent[3])!)
                        books?.append(book)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc func saveData() {
        let filePath = getDataFilePath()
        var saveString = ""
        for book in books! {
            saveString = "\(saveString)\(book.title),\(book.author),\(book.pages),\(book.year)\n"
        }
        
        do {
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    //MARK: - core data methods
    
    func loadCoreData() {
        books = [Book]()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results is [NSManagedObject] {
                for result in (results as! [NSManagedObject]) {
                    let title = result.value(forKey: "title") as! String
                    let author = result.value(forKey: "author") as! String
                    let pages = result.value(forKey: "pages") as! Int
                    let year = result.value(forKey: "year") as! Int
                    
                    books?.append(Book(title: title, author: author, pages: pages, year: year))
                }
            }
        } catch {
            print(error)
        }
        
    }
    
    @objc func saveCoreData() {
        clearCoreData()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
//        let bookEntityDescription = NSEntityDescription.entity(forEntityName: "BookModel", in: managedContext)!
        
        for book in books! {
//            let bookEntity = NSManagedObject(entity: bookEntityDescription, insertInto: managedContext)
            let bookEntity = NSEntityDescription.insertNewObject(forEntityName: "BookModel", into: managedContext)
            bookEntity.setValue(book.title, forKey: "title")
            bookEntity.setValue(book.author, forKey: "author")
            bookEntity.setValue(book.pages, forKey: "pages")
            bookEntity.setValue(book.year, forKey: "year")
        }
        
        appDelegate.saveContext()
    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
//        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                if let managedObject = result as? NSManagedObject {
                    managedContext.delete(managedObject)
                }
            }
            
        } catch {
            print(error)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bookTVC = segue.destination as? BookListTVC {
            bookTVC.books = books
        }
    }
    
   
}

