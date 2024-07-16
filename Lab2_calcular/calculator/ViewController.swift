//
//  ViewController.swift
//  calculator
//
//  Created by ED701 on 2024/3/5.
//

import UIKit

class ViewController: UIViewController {
    
    //表示下一次按digit按鈕時要開始輸入一個新的數字
    var shouldStartNewNumberInput = false
    
    //按下operator前輸入的數字暫存在這裡 
    var pendendingNumber = ""
    
    
    @IBOutlet weak var digitLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化數字及運算子的狀態
        digitLabel.text = "0"
        operatorLabel.text = " "
    }

   
    @IBAction func one(_ sender: UIButton) {
        //判斷是否開始新的數字輸入
        if shouldStartNewNumberInput{
            //暫存前一個輸入的數字
            pendendingNumber = digitLabel.text!
            
            //初始化數字輸入匡，初始值是0，與viewDidLoad一樣
            //(剛按下的新的digit在if過後會放到digitLabel)
            digitLabel.text = "0"
            
            //開始新的數字輸入了，把flag改回來
            shouldStartNewNumberInput = false
        }
        
        //如果按下按鈕時，digitLabel為初始0的狀態，把初始的0刪掉後再開始輸入
        if digitLabel.text == "0" && sender.titleLabel?.text != "."
        {
            digitLabel.text = ""
        }
        //為了不讓一個數字出現兩個"."，如果按下"."且原本的數字已經有"."，則跳出
        if sender.titleLabel?.text == "." &&
        digitLabel.text?.range(of: ".") != nil
        {
            return
            }
        
        //將 sender button 的文字接在 digirLabel的文字後方
        digitLabel.text = digitLabel.text! + sender.titleLabel!.text!
    }
    
    @IBAction func operatorButtonPressed(_ sender: UIButton) {
        //將 sender button 的文字取代 operatorLabel 原有的文字
        self.operatorLabel.text = sender.titleLabel?.text
        
        //已按下運算子，下一個digit輸入時應該開始新的數字輸入
        shouldStartNewNumberInput = true
    }
    
    @IBAction func equalButtonPressed(_ sender: Any) {
        //檢查operatorLabel有沒有值，如果是nil或是空字串，則離開function
        guard let operatorString = operatorLabel.text,!operatorString.isEmpty
        else { return}
        
        //檢查 pendingNumber 與 digitLabel 的字串可否轉成數字，若不行則離開
        //若可以轉成數字，unwrap成Double存到value1, value2
        guard let value1 = Double(pendendingNumber),
              let value2 = Double(digitLabel.text!) else { return}
        
        //暫存計算結果的變數
        var result:Double = 0 //根據不同的 operator 做計算
        switch operatorString {
        case "+":
            result=value1+value2
        case "-":
            result=value1-value2
        case "x":
            result=value1*value2
        case "/":
            result=value1/value2
            
        default:
        break;
        }
        //將計算的結果顯示在digitLabel
        digitLabel.text = "\(result)"
        
        // 保留運算子
            // operatorLabel.text = ""

        // 保留計算結果
        pendendingNumber = "\(result)"

//        //將螢幕上的運算子清空
//        operatorLabel.text = ""
        
        //按下等號後，下一次按Digit為輸入一個新的數字(第一個運算數字)
        shouldStartNewNumberInput = true

    }
    
    @IBAction func allClearButtonPressed(_ sender: Any) {
        digitLabel.text = "0"
        operatorLabel.text = ""
        shouldStartNewNumberInput = false;
        pendendingNumber = ""
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        // 取得目前數字輸入框的文字
        guard var currentText = digitLabel.text else { return }
            
        // 如果數字長度為1，則將數字設為0，否則刪除最後一個字符
        if currentText.count == 1 {
            currentText = "0"
        } else {
            currentText.removeLast()
        }
            
        // 更新數字輸入框的文字
        digitLabel.text = currentText
    }
    
}

