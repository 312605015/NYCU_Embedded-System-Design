//
//  ViewController.swift
//  bookkeeping
//
//  Created by ED701 on 2024/3/12.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //var dataArray:[Double] = [123, 456, 789]
    //空的 [String:Any] dictionary array 來儲存消費資料
    var dataArray = [[String:Any]]()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var newCostField: UITextField!
    
    @IBAction func addData(_ sender: Any) {
        //檢查輸入匡有沒有文字，如果沒有，離開function
        guard let newCostString = newCostField.text, !newCostString.isEmpty else { return }
        
        //檢查輸入的文字可不可以轉成 Double，如果不能，離開function
        guard let newCost = Double(newCostString) else { return }
        //檢查、取得輸入的名字
        guard let newName = nameField.text, !newName.isEmpty else { return }
        //取得輸入資料當下的時間
        let newDate = Date()
        //創造新的Dictionary加入array
        dataArray.append(["name":newName,"cost":newCost,"date":newDate])
        
        
        //        //將新的數值加入array
        //        dataArray.append(newCost)
        
        //叫table view 重新讀取一次資料
        tableView.reloadData()
        
        //準備下次輸入，將輸入匡清空
        newCostField.text = ""
        nameField.text = ""
        
        //將鍵盤收起
        newCostField.resignFirstResponder()
        
        //        //(擇一？)創立指向新增資料所在的table位置的IndexPath物件
        //        let refreshIndexPath = IndexPath.init(row: dataArray.count-1, section: 0)
        //        //告訴table view要插入這些位置(array)的row，使用從上插入的動畫
        //        tableView.insertRows(at:[refreshIndexPath], with: .top)
        
        saveDataArray()
        updateTotal()

    }
    
    @IBOutlet weak var nameField: UITextField!
    
    
    //回傳不同位置的section header要顯示什麼title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < dataArray.count else{
            return nil
        }
        
        guard let date = dataArray[section]["date"] as? Date else{
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //從storyboard中的table view尋找有 identifier 為"Basic Cell"的 cell 範例
        //且如果之前有相同identifier的Cell被宣告出來且沒有在用的話，重複使用，節省記憶體
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)
        
        //取得dictionary取得要顯示的資料的key的值?
        //取得key為name的資料條件轉型成String
        //如果沒有這個key value pair 或轉型不成功，使用"No name"字串取代
        let name = dataArray[indexPath.row]["name"] as? String ?? "No name"
        
        //取得key為cost的資料條件轉型成Double
        //如果沒有這個key value pair 或轉型不成功，使用0.0取代
        let cost = dataArray[indexPath.row]["cost"] as? Double ?? 0.0
        
        // 取得 key 為 date 的資料條件轉型成 Date
        if let date = dataArray[indexPath.row]["date"] as? Date {
            // 格式化日期
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = dateFormatter.string(from: date)
            
            //設定cell的內容
            //    cell.textLabel?.text = "\(dataArray[indexPath.row])"
            cell.textLabel?.text = name //把name設定到cell的title
            cell.detailTextLabel?.text = "\(cost)"//把cost設定到cell的detail title
                
            // 創建一個 UILabel 來顯示日期
            let timeLabel = UILabel()
            timeLabel.text = dateString
            timeLabel.font = UIFont.systemFont(ofSize: 12)
            timeLabel.sizeToFit()
                
            // 將 UILabel 設置為 cell 的 accessoryView
            cell.accessoryView = timeLabel
            
        
        
//        if let date = date {
//            let dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//            let dateString = dateFormatter.string(from:date)
//            let timeLabel = UILabel()
//            timeLabel.text = dateString
//            timeLabel.font = UIFont.systemFont(ofSize: 12)
//            timeLabel.sizeToFit()
//            cell.accessoryView = timeLabel
            
            }else{
                //如果時間訊息不可用，清空時間標籤
                cell.accessoryView = nil
            }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //我們讓 edit 的功能在每個位置的row都啟用。
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: //如果是 commit delete 的動作動畫
            dataArray.remove(at: indexPath.row ) //從 array 移除資料
            //告訴table view要刪掉這些位置(array)的資料，的row，使用往上刪除的
            tableView.deleteRows(at: [indexPath], with: .top)
        default: //其他edit的動作不做任何事
            break
        }
        saveDataArray()
        updateTotal()
    }
    
    func updateTotal(){
        var total:Double = 0
        for item in dataArray{
            if let cost = item["cost"] as? Double{
                total+=cost
            }
        }
        totalCostLabel.text="\(total)"
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            // 您可以根據日期數量來返回 section 數量
            // 在這個例子中，我們假設 dataArray 中的每個元素都是一個 dictionary，
            // 包含日期資訊在 "date" 鍵中。
            // 我們先取得所有日期的集合，並返回其元素的數量作為 section 數量。
            let uniqueDates = Set(dataArray.compactMap { $0["date"] as? Date })
            return uniqueDates.count
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataArray()
        updateTotal()
        // Do any additional setup after loading the view.
    }
    
    
    //將讀檔與寫檔的功能寫成各自的method，將字串寫入檔案的 method 需要有 file name 及要寫入的 string 兩種 input
    
    //寫檔
    func writeStringToFile(writeString:String, fileName:String) { //取得app專用資料夾路徑，並且確定檔案路徑存在
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                
        else{
            return
        }
        
        //在路徑後加上檔名，組合成要寫入的檔案路徑
        let fileURL = dir.appendingPathComponent(fileName)
        do{
            //嘗試使用utf8格式寫入檔案
            try writeString.write(to: fileURL, atomically: false, encoding: .utf8)
        }catch{
            //若寫入錯誤print錯誤
            print(fileURL)
            print("write error")
        }
    }
    
    //讀檔
    func readFileToString(fileName:String) -> String { //取得app專用資料夾路徑，並且確定檔案路徑存在，如果不存在，return空字串
        guard let dir = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask).first
        else{
            return ""
        }
        
        //在路徑後加上檔名，組合成要讀取的檔案路徑
        let fileURL = dir.appendingPathComponent(fileName)
        //宣告要儲存讀取出來的string的變數
        var readString = ""
        do{
            //嘗試使用utf8格式讀取字串
            try readString = String.init(contentsOf: fileURL, encoding: .utf8)
        }catch{
            //若讀取錯誤print錯誤
            print("read error")
        }
        
        //return讀取出的string
        return readString
    }
    
    //儲存DictionaryArray
    func saveDataArray(){
        //宣告儲存最後string的變數
        var finalString = ""
        
        //iterate array 裡所有的 element
        for dictionary in dataArray {
            
            //your code: 將dictionary轉成csv一筆資料的格式，更新finalString
//            //取得現在時間
//            let currentDate = Date()
//            //宣告要拿來轉換時間的formatter 
//            let formatter = DateFormatter()
//            //設定字串轉換要用的格式
//            formatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
//            //轉換時間成字串
//            let dateString = formatter.string(from: currentDate) // "2018/03/22 09:32:13"
//            let otherDateString = "2018/03/11 12:07:53"
//            //轉換字串回時間
//            let date = formatter.date(from: otherDateString) //"Mar 11, 2018 at 12:07 AM"

            // 將每個 dictionary 轉換成 CSV 格式的字串，以逗號分隔每個欄位
            if let name = dictionary["name"] as? String,
               let cost = dictionary["cost"] as? Double,
               let date = dictionary["date"] as? Date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = dateFormatter.string(from: date)
                let csvLine = "\(name),\(cost),\(dateString)\n"
                // 更新 finalString
                finalString.append(csvLine)
                
            }
            
            //寫入data.txt檔案
            writeStringToFile(writeString: finalString, fileName:"data.txt")
        }
        
    }

//載入DictionaryArray
    func loadDataArray() { 
        //宣告儲存Array最後的結果的變數
        var finalArray = [[String:Any]]() 
        //讀取data.txt的檔案內容
        let csvString = readFileToString(fileName: "data.txt")
        //用"\n"將每一筆資料分開
        let lineOfString = csvString.components(separatedBy: "\n")
        //iterate 每一筆資料的string
        for line in lineOfString { 
            
            //將這筆資料的string轉成dictionary的格式
            //your code here
            if !line.isEmpty {
                // 使用逗號 "," 分割每筆資料的各個欄位
                let fields = line.components(separatedBy: ",")
                
                // 確認欄位數量是否符合預期
                if fields.count >= 3 {
                    
                    // 如果符合預期，取得各個欄位的值
                    let name = fields[0]
                    let cost = Double(fields[1]) ?? 0.0
                    let dateString = fields[2]
                    
                    // 將日期字串轉換為 Date 物件
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = dateFormatter.date(from: dateString) ?? Date()
                    
                    //將讀取出的這筆資料加入array
                    //your code here
                    // 創建字典並加入到 finalArray 中
                    let dataDict: [String: Any] = ["name": name, "cost": cost, "date": date]
                    finalArray.append(dataDict)
                }
            }
        

        }
        
    //將讀取出的finalArray取代掉原本的dataArray 
    dataArray = finalArray
        
    //更新 tableview 與 介面資料 
    tableView.reloadData()
        
    updateTotal()
        
    }
    
    
    
}


