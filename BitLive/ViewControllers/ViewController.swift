//
//  ViewController.swift
//  BitLive
//
//  Created by Ace Green on 7/14/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import DataCache
import LTMorphingLabel

class ViewController: UIViewController {
    
    enum SegmentIndex: Int {
        case USD
        case GBP
        case EUR
    }
    
    enum Currency: String {
        case USD = "$"
        case GBP = "£"
        case EUR = "€"
    }
    
    @IBOutlet var bitcoinValueLabel: LTMorphingLabel!
    
    @IBOutlet var bitcoinChangeLabel: UILabel!
    
    @IBOutlet var bitcoinChartView: LineChartView!
    
    @IBAction func currencySegmentedControl(_ sender: AnyObject) {
        
        selectedSegmentIndex = SegmentIndex(rawValue: sender.selectedSegmentIndex)!
        
        // Query and Update current Value
        queryUpdateCurrentValue()
        
        // Query and Update historic values
        queryUpdateHistoricValues()
    }
    
    var selectedSegmentIndex: SegmentIndex = SegmentIndex(rawValue: 0)!
    
    var currentValue: Double! {
        didSet {
            
            if yesterdaysValue != nil {
                updateChangeValue(yesterdaysValue, todaysValue: currentValue)
            }
        }
    }
    
    var yesterdaysValue: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Query for current Value and start a timer
        queryUpdateCurrentValue()
        
        // Starting timer independent of above query
        self.startTimer("queryUpdateCurrentValue")
        
        // Query for historic values
        queryUpdateHistoricValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Bitcoin Functions
    
    func queryCurrentValue(_ completion: @escaping (JSON) -> Void) {
        
        let queryLink = "https://api.coindesk.com/v1/bpi/currentprice.json"
        
        // Load from cache first
        if let currentValueCacheData = DataCache.instance.readData(forKey: "\(queryLink)") {
            
            let bitcoinJSONResults =  JSON(data: currentValueCacheData)
            completion(bitcoinJSONResults)
        }
        
        // Fetch new data
        QueryHelper.sharedInstance.queryWith(queryLink) { (result) in
            
            do {
                
                let bitcoinResults = try result()
                
                let bitcoinJSONResults = JSON(data: bitcoinResults)
                
                DataCache.instance.write(data: bitcoinResults, forKey: "\(queryLink)")
                
                completion(bitcoinJSONResults)
                
            } catch {
                
                //TO-DO: Alert users no data found
            }
        }
    }
    
    func queryHistoricValues(_ weeks: Int, completion: @escaping (JSON) -> Void) {
        
        let today = Date()
        let daysAgo = dateBySubtractingDays(today, numberOfDays: -(weeks * 7))
        
        let todayFormatted: String = dateFormattedString(today)
        let daysAgoFormatted: String = dateFormattedString(daysAgo)
        
        let queryLink = "https://api.coindesk.com/v1/bpi/historical/close.json?start=\(daysAgoFormatted)&end=\(todayFormatted)&currency=\(selectedSegmentIndex)"
        
        // Load from cache first
        if let historicValuesCacheData = DataCache.instance.readData(forKey:"\(queryLink)") {
            
            let bitcoinJSONResults =  JSON(data: historicValuesCacheData)
            
            completion(bitcoinJSONResults)
        }
        
        // Fetch new data
        QueryHelper.sharedInstance.queryWith(queryLink) { (result) in
            
            do {
                
                let bitcoinResults = try result()
                
                let bitcoinJSONResults = JSON(data: bitcoinResults)
                
                DataCache.instance.write(data: bitcoinResults, forKey: "\(queryLink)")
                
                completion(bitcoinJSONResults)
                
            } catch {
                
                //TO-DO: Alert users no data found
            }
        }
    }
    
    func updateCurrentValue(from bitcoinJSONResults: JSON) {
        
        print(bitcoinJSONResults)
        
        let bpi = bitcoinJSONResults["bpi"]
        let currency = bpi["\(selectedSegmentIndex)"]
        let currencySymbol = getCurrencySymbol()
        var rate = currency["rate"]
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.bitcoinValueLabel.text = "\(currencySymbol) \(rate.doubleValue.roundTo(places: 2))"
            self.currentValue = rate.doubleValue.roundTo(places: 2)
        })
    }
    
    func updateHistoricData(from bitcoinJSONResults: JSON) {
        
        //print(bitcoinJSONResults)
        
        let bpi = bitcoinJSONResults["bpi"]
        let bpiSorted = bpi.sorted { $0.0 < $1.0 }
        
        var xValues = [String]()
        var yValues = [Double]()
        
        for (key, var value) in bpiSorted {
            xValues.append(key)
            yValues.append(value.doubleValue.roundTo(places: 2))
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.setChart(xValues, values: yValues)
            
            if let lastValue = yValues.last {
                self.yesterdaysValue = lastValue
                self.updateChangeValue(self.yesterdaysValue, todaysValue: self.currentValue)
            }
        })
    }
    
    func updateChangeValue(_ yesterdaysValue: Double?, todaysValue: Double?) {
        
        guard let yesterdaysValue = yesterdaysValue, let todaysValue = todaysValue else  { return }
        
        var difference = todaysValue - yesterdaysValue
        var differentPercent = (difference / yesterdaysValue) * 100
        
        let currencySymbol = getCurrencySymbol()
        
        self.bitcoinChangeLabel.isHidden = false
        self.bitcoinChangeLabel.text = "\(currencySymbol) \(difference.roundTo(places: 2)) (\(differentPercent.roundTo(places: 2))%)"
        
    }
    
    func queryUpdateCurrentValue() {
        queryCurrentValue { (resultsJSON) in
            self.updateCurrentValue(from: resultsJSON)
        }
    }
    
    func queryUpdateHistoricValues() {
        queryHistoricValues(4) { (resultsJSON) in
            self.updateHistoricData(from: resultsJSON)
        }
    }
    
    // MARK: Chart Function
    
    func setChart(_ dataPoints: [String], values: [Double]) {
        
        if let _ = values.find ({ $0 > 1 }) {
            
            var yValues = [ChartDataEntry]()
            
            for i in 0..<dataPoints.count {
                let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
                yValues.append(dataEntry)
            }
            
            let lineDataSet = LineChartDataSet(yVals: yValues, label: nil)
            lineDataSet.drawValuesEnabled = false
            lineDataSet.axisDependency = .left
            lineDataSet.setColor(UIColor.white)
            lineDataSet.setCircleColor(UIColor.white)
            lineDataSet.lineWidth = 3.0
            
            lineDataSet.drawCirclesEnabled = false
//            lineDataSet.circleRadius = 6.0
            lineDataSet.fillAlpha = 65 / 255.0
            lineDataSet.fillColor = Constants.goldColor
            lineDataSet.highlightColor = UIColor.white
            lineDataSet.drawCircleHoleEnabled = true
            
            var chartDataSet: [LineChartDataSet] = [LineChartDataSet]()
            chartDataSet.append(lineDataSet)
            
            let marker: BalloonMarker = BalloonMarker(color: UIColor.white, font: UIFont.systemFont(ofSize: 12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSize(width: 40.0, height: 40.0)
            
            bitcoinChartView.descriptionText = ""
            bitcoinChartView.xAxis.enabled = false
            bitcoinChartView.xAxis.drawGridLinesEnabled = false
            bitcoinChartView.leftAxis.enabled = false
            bitcoinChartView.leftAxis.drawGridLinesEnabled = false
            bitcoinChartView.rightAxis.enabled = false
            bitcoinChartView.rightAxis.drawGridLinesEnabled = false
            bitcoinChartView.drawBordersEnabled = false
            bitcoinChartView.drawGridBackgroundEnabled = false
            bitcoinChartView.legend.enabled = false
            bitcoinChartView.marker = marker
            
            let chartData:LineChartData = LineChartData(xVals: dataPoints, dataSets: chartDataSet)
            bitcoinChartView.data = chartData
            
            bitcoinChartView.animate(xAxisDuration: 1.0, yAxisDuration: 0)
        } else {
            bitcoinChartView.isHidden = true
        }
    }
    
    // MARK: Helper Functions
    
    func dateFormattedString(_ date: Date) -> String {
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: date)
    }
    
    func dateBySubtractingDays(_ currentDate: Date, numberOfDays: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = numberOfDays
        return (Calendar.current as NSCalendar).date(byAdding: .day, value: numberOfDays, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func startTimer(_ selector: String) {
        
        // Note: As per docs, XBP is updated every 60 seconds
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: Selector(selector), userInfo: nil, repeats: true)
    }
    
    func getCurrencySymbol() -> String {
        switch selectedSegmentIndex {
        case .USD:
            return Currency.USD.rawValue
        case .GBP:
            return Currency.GBP.rawValue
        case .EUR:
            return Currency.EUR.rawValue
        }
    }
}

