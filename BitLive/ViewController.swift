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
    
    @IBAction func currencySegmentedControl(sender: AnyObject) {
        
        selectedSegmentIndex = SegmentIndex(rawValue: sender.selectedSegmentIndex)!
        
        // Query for current Value and start a timer
        queryCurrentValue()
        
        // Query for historic values
        queryHistoricValue(weeks: 4)
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
        queryCurrentValue()
        
        // Starting timer independent of above query
        self.startTimer(selector: "queryCurrentValue")
        
        // Query for historic values
        queryHistoricValue(weeks: 4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Bitcoin Functions
    
    func queryCurrentValue() {
        
        let queryLink = "https://api.coindesk.com/v1/bpi/currentprice.json"
        
        // Load from cache first
        if let currentValueCacheData = DataCache.defaultCache.readDataForKey("\(queryLink)") {
            
            let bitcoinJSONResults =  JSON(data: currentValueCacheData)
            self.updateCurrentData(bitcoinJSONResults)

        }
        
        // Fetch new data
        QueryHelper.sharedInstance.queryWith(queryLink) { (result) in
            
            do {
                
                let bitcoinResults = try result()
                
                let bitcoinJSONResults =  JSON(data: bitcoinResults)
                
                DataCache.defaultCache.writeData(bitcoinResults, forKey: "\(queryLink)")
                self.updateCurrentData(bitcoinJSONResults)
                
            } catch {
                
                //TO-DO: Alert users no data found
            }
        }
    }
    
    func queryHistoricValue(weeks weeks: Int) {
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today = NSDate()
        let daysAgo = dateBySubtractingDays(today, numberOfDays: -(weeks * 7))
        
        let todayFormatted: String = formatter.stringFromDate(today)
        let daysAgoFormatted: String = formatter.stringFromDate(daysAgo)
        
        let queryLink = "https://api.coindesk.com/v1/bpi/historical/close.json?start=\(daysAgoFormatted)&end=\(todayFormatted)&currency=\(selectedSegmentIndex)"
        
        // Load from cache first
        if let historicValuesCacheData = DataCache.defaultCache.readDataForKey("\(queryLink)") {
            
            let bitcoinJSONResults =  JSON(data: historicValuesCacheData)
            self.updateHistoricData(bitcoinJSONResults)
            
        }
        
        // Fetch new data
        QueryHelper.sharedInstance.queryWith(queryLink) { (result) in
            
            do {
                
                let bitcoinResults = try result()
                
                let bitcoinJSONResults = JSON(data: bitcoinResults)
                
                DataCache.defaultCache.writeData(bitcoinResults, forKey: "\(queryLink)")
                self.updateHistoricData(bitcoinJSONResults)
                
            } catch {
                
                //TO-DO: Alert users no data found
            }
        }
    }
    
    func updateCurrentData(bitcoinJSONResults: JSON) {
        
        let bpi = bitcoinJSONResults["bpi"]
        let currency = bpi["\(selectedSegmentIndex)"]
        let currencySymbol = getCurrencySymbol()
        let rate = currency["rate"]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.bitcoinValueLabel.text = "\(currencySymbol) \(rate.doubleValue.roundToPlaces(2))"
            self.currentValue = rate.doubleValue.roundToPlaces(2)
        })
    }
    
    func updateHistoricData(bitcoinJSONResults: JSON) {
        
        let bpi = bitcoinJSONResults["bpi"]
        let bpiSorted = bpi.sort { $0.0 < $1.0 }
        
        var xValues = [String]()
        var yValues = [Double]()
        
        for (key, value) in bpiSorted {
            xValues.append(key)
            yValues.append(value.doubleValue.roundToPlaces(2))
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.setChart(xValues, values: yValues)
            
            if let lastValue = yValues.last {
                self.yesterdaysValue = lastValue
                self.updateChangeValue(self.yesterdaysValue, todaysValue: self.currentValue)
            }
        })
    }
    
    func updateChangeValue(yesterdaysValue: Double?, todaysValue: Double?) {
        
        guard let yesterdaysValue = yesterdaysValue, let todaysValue = todaysValue else  { return }
        
        let difference = todaysValue - yesterdaysValue
        let differentPercent = (difference / yesterdaysValue) * 100
        
        let currencySymbol = getCurrencySymbol()
        
        self.bitcoinChangeLabel.hidden = false
        self.bitcoinChangeLabel.text = "\(currencySymbol) \(difference.roundToPlaces(2)) (\(differentPercent.roundToPlaces(2))%)"
        
    }
    
    // MARK: Chart Function
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        if let _ = values.find ({ $0 > 1 }) {
            
            var yValues = [ChartDataEntry]()
            
            for i in 0..<dataPoints.count {
                let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
                yValues.append(dataEntry)
            }
            
            let lineDataSet = LineChartDataSet(yVals: yValues, label: nil)
            lineDataSet.drawValuesEnabled = false
            lineDataSet.axisDependency = .Left
            lineDataSet.setColor(UIColor.whiteColor())
            lineDataSet.setCircleColor(UIColor.whiteColor())
            lineDataSet.lineWidth = 3.0
            
            lineDataSet.drawCirclesEnabled = false
            //            lineDataSet.circleRadius = 6.0
            lineDataSet.fillAlpha = 65 / 255.0
            lineDataSet.fillColor = Constants.goldColor
            lineDataSet.highlightColor = UIColor.whiteColor()
            lineDataSet.drawCircleHoleEnabled = true
            
            var chartDataSet: [LineChartDataSet] = [LineChartDataSet]()
            chartDataSet.append(lineDataSet)
            
            let marker: BalloonMarker = BalloonMarker(color: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
            marker.minimumSize = CGSizeMake(40.0, 40.0)
            
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
            bitcoinChartView.hidden = true
        }
    }
    
    // MARK: Helper Functions
    
    func dateBySubtractingDays(currentDate: NSDate, numberOfDays: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.day = numberOfDays
        return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: numberOfDays, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func startTimer(selector selector: String) {
        
        // Note: As per docs, XBP is updated every 60 seconds
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector(selector), userInfo: nil, repeats: true)
        
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

