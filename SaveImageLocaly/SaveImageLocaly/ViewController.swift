//
//  ViewController.swift
//  SaveImageLocaly
//
//  Created by Giresh Dora on 22/07/19.
//  Copyright © 2019 Giresh Dora. All rights reserved.
//

import UIKit

enum StorageType {
    case userDefault
    case fileSystem
}

class ViewController: UIViewController {

    
    @IBOutlet weak var imageToSaveImageView: UIImageView!
    @IBOutlet weak var imageToRetriveImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    //MARK:- Action methods
    
    @IBAction func saveImage(_ sender: Any) {
        if let image = UIImage(named: "applecampus"){
            DispatchQueue.global(qos: .background).async {
                self.store(image: image, forkey: "applecampus", withStorageType: .fileSystem)
            }
        }
    }
    
    @IBAction func retriveImage(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            if let saveImage = self.retrieveImage(forkey: "applecampus", inStorageType: .fileSystem) as? UIImage{
                DispatchQueue.main.async {
                    self.imageToRetriveImageView.image = saveImage
                }
            }
        }
    }
    
    
    //MARK:- Custome methods
    
    private func store(image: UIImage, forkey key:String, withStorageType storageType:StorageType){
        let pngRepresentation = image.pngData()
        
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forkey: key){
                do {
                    try pngRepresentation?.write(to: filePath, options: .atomic)
                }
                catch let err {
                    print("Saving image in file erro : \(err)")
                }
            }
            break
        case .userDefault:
            UserDefaults.standard.set(pngRepresentation, forKey: key)
            break
        }
    }
    
    
    private func retrieveImage(forkey key:String, inStorageType storageType:StorageType) -> UIImage{
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forkey: key),
                let imageData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: imageData){
                return image
            }
            break
        case .userDefault:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
            break
        }
        
        return UIImage()
    }
    
    private func filePath(forkey key:String) -> URL?{
        let fileManager = FileManager.default
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            return nil
        }
        return documentUrl.appendingPathComponent(key + ".png")
    }
}

