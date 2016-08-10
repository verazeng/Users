//
//  ViewController.swift
//  Users
//
//  Created by Heng Zeng on 8/9/16.
//  Copyright © 2016 com.vera. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var orderedProducts : [String] = []
    var firstCellTitle : String? = "Didn't get shared files"
    var firstImage : UIImage?
    
    @IBAction func navigateToProductsShop(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL.init(string: "launchProducts://")!)
    }
    
    @IBAction func loadOrderdProducts(_ sender: UIBarButtonItem) {
        getSharedData()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getSharedData), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getSharedData() {
        if let products = getOrderedProductsFromAppGroup() {
            orderedProducts = products
        } else {
            firstCellTitle = "Didn't get ordered products"
        }
        
        getSharedFolderData()
        tableView.reloadData()
    }
    
    func getOrderedProductsFromAppGroup() -> [String]? {
        let orderKey = "OrderedProducts"
        let sharedUserDefault = UserDefaults.init(suiteName: "group.vera.share")
        return sharedUserDefault?.object(forKey: orderKey) as? [String]
    }
    
    func getSharedFolderData() {
        let manager = FileManager.default
        guard let sharedDir = manager.containerURL(forSecurityApplicationGroupIdentifier: "group.vera.share")?.appendingPathComponent("Shares") else { return }
        
        let urls = try? manager.contentsOfDirectory(at: sharedDir, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(rawValue: UInt(0)))
        try? urls?.forEach { url in
            switch url.pathExtension {
                case "txt":
                    firstCellTitle = try String(contentsOf: url)
                case "jpeg":
                    let imageData = try Data(contentsOf: url)
                    firstImage = UIImage(data: imageData)
                default: break
            }
        }
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedProducts.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderedProduct", for: indexPath)
        cell.imageView?.image = indexPath.row == 0 ? firstImage : nil
        cell.textLabel?.text = indexPath.row == 0 ? firstCellTitle : orderedProducts[indexPath.row - 1]
        return cell
    }
}

