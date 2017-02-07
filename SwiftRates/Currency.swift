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

class Currency {
  
  static var currencies: [Currency] = {
    var currencies = [Currency]()
    let path = Bundle.main.path(forResource: "Currencies", ofType: "plist")!
    for entry in NSArray(contentsOfFile: path)! {
      if let entry = entry as? [String: AnyObject],
        let name = entry["name"] as? String,
        let image = entry["image"] as? String {
        let currency = Currency(name: name, image: UIImage(named: image)!)
        currencies.append(currency)
      }
    }
    return currencies
  }()
  
  static func currency(named name: String) -> Currency? {
    return currencies.filter({ (currency) -> Bool in
      currency.name == name
    }).first
  }
  
  var name: String
  var image: UIImage
  
  init(name: String, image: UIImage) {
    self.name = name
    self.image = image
  }
  
}

// MARK: - Equatable

extension Currency: Equatable {
  
}

func ==(lhs: Currency, rhs: Currency) -> Bool {
  return lhs.name == rhs.name
}
