//
//  DetailViewController.swift
//  bookkeeping
//
//  Created by ED701 on 2024/4/2.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var costField: UITextField!
    
    var data: [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let name = data["name"] as? String
        let cost = data["cost"] as? Double ?? 0.0
        let date = data["date"] as! Date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd hh:mm:ss"
        let dateString = formatter.string(from: date)
        
        nameField.text = name
        costField.text = String(cost)
        dateLabel.text = dateString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 檢查傳遞過來的資料是否為 nil
        guard let data = data else {
        // 如果為 nil，顯示錯誤訊息並返回
            print("Error: Data is nil.")
            return
        }
                
        // 從 data 中取得相關資料
        if let name = data["name"] as? String {
            nameField.text = name // 將名字設定到 nameField 中
        }
                
        if let cost = data["cost"] as? Double {
            costField.text = String(cost) // 將成本設定到 costField 中
        }
                
        if let date = data["date"] as? Date {
            // 將日期格式化為您希望的格式，例如："yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: date)
            dateLabel.text = dateString // 將日期設定到 dateLabel 中
        }
        
    }
    
    

        
    
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     
     

     
    */


