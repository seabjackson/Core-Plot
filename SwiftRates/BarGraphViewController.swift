/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CorePlot

class BarGraphViewController: UIViewController {
  
  @IBOutlet var hostView: CPTGraphHostingView!
  
  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var label2: UILabel!
  @IBOutlet weak var label3: UILabel!
    
  var base: Currency!
  var rates: [Rate]!
  var symbols: [Currency]!
  
  var plot1: CPTBarPlot!
  var plot2: CPTBarPlot!
  var plot3: CPTBarPlot!

  let barWidth = 0.25
  let barInitialX = 0.25
  
  var priceAnnotation: CPTPlotSpaceAnnotation?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }
  
  func updateLabels() {
    label1.text = base.name
    label2.text = symbols[0].name
    label3.text = symbols[1].name
  }
  
  func highestRateValue() -> Double {
    var maxRate = DBL_MIN
    for rate in rates {
      maxRate = max(maxRate, rate.maxRate().doubleValue)
    }
    return maxRate
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    initPlot()
  }
  
  func initPlot() {
    configureHostView()
    configureGraph()
    configureChart()
    configureAxes()
  }
  
  func configureHostView() {
    hostView.allowPinchScaling = false
  }
  
  func configureGraph() {
    // create the graph
    
    let graph = CPTXYGraph(frame: hostView.bounds)
    graph.plotAreaFrame?.masksToBorder = false
    hostView.hostedGraph = graph
    
    // configure the graph
    graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
    graph.fill = CPTFill(color: CPTColor.clear())
    graph.paddingBottom = 30.0
    graph.paddingLeft = 30.0
    graph.paddingTop = 0.0
    graph.paddingRight = 0.0
    
    // set up styles
    let titleStyle = CPTMutableTextStyle()
    titleStyle.color = CPTColor.black()
    titleStyle.fontName = "HelveticaNeue-Bold"
    titleStyle.fontSize = 16.0
    titleStyle.textAlignment = .center
    graph.titleTextStyle = titleStyle
    
    let title = "\(base.name) exchange rates \n\(rates.first!.date) - \(rates.last!.date)"
    graph.title = title
    graph.titlePlotAreaFrameAnchor = .top
    graph.titleDisplacement = CGPoint(x: 0.0, y: -16.0)
    
    // set up plot space
    let xMin = 0.0
    let xMax = Double(rates.count)
    let yMin = 0.0
    let yMax = 1.4 * highestRateValue()
    
    guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
    plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
    plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin)
      , lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
  }
  
  func configureChart() {
    // set up the three plots
    plot1 = CPTBarPlot()
    plot1.fill = CPTFill(color: CPTColor(componentRed: 0.92, green: 0.28, blue: 0.25, alpha: 1.00))
    plot2 = CPTBarPlot()
    plot2.fill = CPTFill(color: CPTColor(componentRed: 0.06, green: 0.80, blue: 0.48, alpha: 1.00))
    plot3 = CPTBarPlot()
    plot3.fill = CPTFill(color: CPTColor(componentRed: 0.22, green: 0.33, blue: 0.49, alpha: 1.00))
    
    // set up line style
    let barLineStyle = CPTMutableLineStyle()
    barLineStyle.lineColor = CPTColor.lightGray()
    barLineStyle.lineWidth = 0.5
    
    // add plots to graph
    guard let graph = hostView.hostedGraph else { return }
    var barX = barInitialX
    let plots = [plot1!, plot2!, plot3!]
    for plot: CPTBarPlot in plots {
      plot.dataSource = self
      plot.delegate = self
      plot.barWidth = NSNumber(value: barWidth)
      plot.barOffset = NSNumber(value: barX)
      plot.lineStyle = barLineStyle
      graph.add(plot, to: graph.defaultPlotSpace)
      barX += barWidth
    }
  }
  
  func configureAxes() {
    // configure styles
    let axisLineStyle = CPTMutableLineStyle()
    axisLineStyle.lineWidth = 2.0
    axisLineStyle.lineColor = CPTColor.blue()
    
    // get the graph axis set
    guard let axisSet = hostView.hostedGraph?.axisSet as? CPTXYAxisSet else { return }
    
    // configure the x axis
    if let xAxis = axisSet.xAxis {
      xAxis.labelingPolicy = .none
      xAxis.majorIntervalLength = 1
      xAxis.axisLineStyle = axisLineStyle
      var majorTickLocations = Set<NSNumber>()
      var axisLabels = Set<CPTAxisLabel>()
      for (idx, rate) in rates.enumerated() {
        majorTickLocations.insert(NSNumber(value: idx))
        let label = CPTAxisLabel(text: "\(rate.date)", textStyle: CPTTextStyle())
        label.tickLocation = NSNumber(value: idx)
        label.offset = 5.0
        label.alignment = .left
        axisLabels.insert(label)
      }
      xAxis.majorTickLocations = majorTickLocations
      xAxis.axisLabels = axisLabels
    }
    
    // configure the y axis
    if let yAxis = axisSet.yAxis {
      yAxis.labelingPolicy = .fixedInterval
      yAxis.labelOffset = -10.0
      yAxis.minorTicksPerInterval = 3
      yAxis.majorTickLength = 30
      let majorTickLineStyle = CPTMutableLineStyle()
      majorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.1)
      yAxis.majorTickLineStyle = majorTickLineStyle
      yAxis.minorTickLength = 20
      let minorTickLineStyle = CPTMutableLineStyle()
      minorTickLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.05)
      yAxis.minorTickLineStyle = minorTickLineStyle
      yAxis.axisLineStyle = axisLineStyle
    }
  }
}

// MARK: Actions

extension BarGraphViewController {
  
  @IBAction func switch1Changed(_ sender: UISwitch) {
    
  }
  
  @IBAction func switch2Changed(_ sender: UISwitch) {
    
  }
  
  @IBAction func switch3Changed(_ sender: UISwitch) {
    
  }
  
}

extension BarGraphViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {
  func numberOfRecords(for plot: CPTPlot) -> UInt {
    return UInt(rates.count)
  }
  
  func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
    if fieldEnum == UInt(CPTBarPlotField.barTip.rawValue) {
      if plot == plot1 {
        return 1.0 as AnyObject?
      }
      
      if plot == plot2 {
        return rates[Int(idx)].rates[symbols[0].name]!
      }
      
      if plot == plot3 {
        return rates[Int(idx)].rates[symbols[1].name]!
      }
    }
    return idx
   }
  
  func barPlot(_ plot: CPTBarPlot, barWasSelectedAtRecord idx: UInt, with event: UIEvent) {
    if plot.isHidden == true {
      return
    }
    
    let style = CPTMutableTextStyle()
    style.fontSize = 12.0
    style.fontName = "HelveticaNeue-Bold"
    
    // create annotation
    guard let price = number(for: plot, field: UInt(CPTBarPlotField.barTip.rawValue), record: idx) as? CGFloat else { return }
    priceAnnotation?.annotationHostLayer?.removeAnnotation(priceAnnotation)
    priceAnnotation = CPTPlotSpaceAnnotation(plotSpace: plot.plotSpace!, anchorPlotPoint: [0.0])
    
    // create number formatter
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    
    // create text layer for annotation
    let priceValue = formatter.string(from: NSNumber(cgFloat: price))
    let textLayer = CPTTextLayer(text: priceValue, style: style)
    priceAnnotation!.contentLayer = textLayer
    
    var plotIndex: Int = 0
    if plot == plot1 {
      plotIndex = 0
    }
    else if plot == plot2 {
      plotIndex = 1
    }
    else if plot == plot3 {
      plotIndex = 2
    }
    // 7 - Get the anchor point for annotation
    let x = CGFloat(idx) + CGFloat(barInitialX) + (CGFloat(plotIndex) * CGFloat(barWidth))
    let y = CGFloat(price) + 0.05
    priceAnnotation!.anchorPlotPoint = [NSNumber(cgFloat: x), NSNumber(cgFloat: y)]
    // 8 - Add the annotation
    guard let plotArea = plot.graph?.plotAreaFrame?.plotArea else { return }
    plotArea.addAnnotation(priceAnnotation)
  }
}
































