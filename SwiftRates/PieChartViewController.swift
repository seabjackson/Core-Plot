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

class PieChartViewController: UIViewController {
  
  @IBOutlet weak var hostView: CPTGraphHostingView!
  
  var base: Currency!
  var rate: Rate!
  var symbols: [Currency]!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // add the base currency to the symbols, so it will show on the graph
    symbols.insert(base, at: 0)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    initPlot()
  }
  
  func initPlot() {
    configureHostView()
    configureGraph()
    configureChart()
    configureLegend()
  }
  
  func configureHostView() {
    hostView.allowPinchScaling = false
  }
  
  func configureGraph() {
    // create an configure the graph
    let graph = CPTXYGraph(frame: hostView.bounds)
    hostView.hostedGraph = graph
    graph.paddingLeft = 0.0
    graph.paddingTop = 0.0
    graph.paddingRight = 0.0
    graph.paddingBottom = 0.0
    graph.axisSet = nil
    
    // create text styles
    let textStyle: CPTMutableTextStyle = CPTMutableTextStyle()
    textStyle.color = CPTColor.black()
    textStyle.fontName = "HelveticaNeue-Bold"
    textStyle.fontSize = 16.0
    textStyle.textAlignment = .center
    
    // set graph title and text style
    graph.title = "\(base.name) exchange rates\n\(rate.date)"
    graph.titleTextStyle = textStyle
    graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top
  }
  
  func configureChart() {
    // get a reference to the graph
    
    let graph = hostView.hostedGraph!
    
    let pieChart = CPTPieChart()
    pieChart.delegate = self
    pieChart.dataSource = self
    pieChart.pieRadius = (min(hostView.bounds.size.width, hostView.bounds.size.height) * 0.7) / 2
    pieChart.identifier = NSString(string: graph.title!)
    pieChart.startAngle = CGFloat(M_PI_4)
    pieChart.sliceDirection = .clockwise
    pieChart.labelOffset = 0.6 * pieChart.pieRadius
    
    // configure border style
    let borderStyle = CPTMutableLineStyle()
    borderStyle.lineColor = CPTColor.white()
    borderStyle.lineWidth = 2.0
    pieChart.borderLineStyle = borderStyle
    
    // configure text style
    let textStyle = CPTMutableTextStyle()
    textStyle.color = CPTColor.white()
    textStyle.textAlignment = .center
    pieChart.labelTextStyle = textStyle
    
    // add chart to the graph
    graph.add(pieChart)
  }
  
  func configureLegend() {
    // get the graph instance
    guard let graph = hostView.hostedGraph else { return }
    
    let theLegend = CPTLegend(graph: graph)
    
    // configure the legend
    theLegend.numberOfColumns = 1
    theLegend.fill = CPTFill(color: CPTColor.white())
    let textStyle = CPTMutableTextStyle()
    textStyle.fontSize = 18
    theLegend.textStyle = textStyle
    
    // add the legend to graph
    graph.legend = theLegend
    if view.bounds.width > view.bounds.height {
      graph.legendAnchor = .right
      graph.legendDisplacement = CGPoint(x: -20, y: 0.0)
    } else {
      graph.legendAnchor = .bottomRight
      graph.legendDisplacement = CGPoint(x: -8.0, y: 8.0)
    }
  }
  
}

extension PieChartViewController: CPTPieChartDataSource, CPTPieChartDelegate {
  
  func numberOfRecords(for plot: CPTPlot) -> UInt {
    return UInt(symbols.count)
  }
  
  func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
    let symbol = symbols[Int(idx)]
    let currencyRate = rate.rates[symbol.name]!.floatValue
    return 1.0 / currencyRate
  }
  
  func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
    let value = rate.rates[symbols[Int(idx)].name]!.floatValue
    let layer = CPTTextLayer(text: String(format: "\(symbols[Int(idx)].name)\n%.2f", value))
    layer.textStyle = plot.labelTextStyle
    return layer
  }
  
  func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
    switch idx {
    case 0:
      return CPTFill(color: CPTColor(componentRed: 0.92, green: 0.28, blue: 0.25, alpha: 1.00))
    case 1:
      return CPTFill(color: CPTColor(componentRed: 0.06, green: 0.80, blue: 0.48, alpha: 1.00))
    case 2:
      return CPTFill(color: CPTColor(componentRed: 0.22, green: 0.33, blue: 0.49, alpha: 1.00))
    default:
      return nil

    }
  }
  
  func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
    return symbols[Int(idx)].name
  }
  
  
  
  
}






























