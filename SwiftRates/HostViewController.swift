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

class HostViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var contentView: UIView!
  
  var base: Currency!
  var rates: [Rate]?
  var symbols: [Currency]!
  
  var activeViewController: UIViewController? {
    didSet {
      oldValue?.view.removeFromSuperview()
      
      guard let activeViewController = activeViewController else { return }
      activeViewController.view.frame = contentView.bounds
      contentView.addSubview(activeViewController.view)
      activeViewController.didMove(toParentViewController: self)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadRates()
  }
  
  func loadRates() {
    let symbolNames = symbols.map { $0.name }
 
    DataStore.sharedStore.getRates(
      fromDateString: "2016-02-28",
      toDateString: "2016-03-03",
      base: base.name,
      symbols: symbolNames,
      success: { [weak self] rates in
        guard let strongSelf = self else { return }
        strongSelf.rates = rates
        strongSelf.showViewControllerForSegment(strongSelf.segmentedControl.selectedSegmentIndex)
     
      }, failure: { error in
      print("error: \(error?.localizedDescription)")
    })
  }
  
  func showViewControllerForSegment(_ index: Int) {
    
    let viewController = viewControllerForSegment(index)
    
    if let viewController = viewController as? PieChartViewController {
      viewController.base = base
      viewController.symbols = symbols
      viewController.rate = rates?.last
      
    } else if let viewController = viewController as? BarGraphViewController {
      viewController.base = base
      viewController.symbols = symbols
      viewController.rates = rates
    }
    activeViewController = viewController
  }
  
  func viewControllerForSegment(_ index: Int) -> UIViewController {
    switch index {
    case 0:   return storyboard!.instantiateViewController(withIdentifier: "PieChartViewController")
    case 1:   return storyboard!.instantiateViewController(withIdentifier: "BarGraphViewController")
    default:  return UIViewController()
    }
  }
}

// MARK: Actions

extension HostViewController {
  
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    let index = sender.selectedSegmentIndex
    showViewControllerForSegment(index)
  }
  
}
