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

import Alamofire
import SwiftDate

class DataStore {
  
  static var sharedStore = DataStore()
  
  let APIBaseURL = "http://api.fixer.io"
  let APIDateFormat = DateFormat.custom("yyyy-MM-dd")
  
  func getRates(fromDateString: String, toDateString: String, base: String, symbols: [String], success: @escaping (_ rates: [Rate]) -> Void, failure: (_ error: NSError?) -> Void) {
    guard let fromDate = try? fromDateString.date(format: APIDateFormat),
      let toDate = try? toDateString.date(format: APIDateFormat) else {
        failure(nil)
        return
    }
    print("Fetching \(base)/\(symbols.joined(separator: "/")) rates \(fromDateString) to \(toDateString)")
    let queue = TaskQueue()
    var rates = [Rate]()
    var currentDate = fromDate
    while (currentDate <= toDate) {
      let date = currentDate.string(format: self.APIDateFormat)
      queue.tasks +=~ { result, next in
        self.getRate(date: date, base: base, symbols: symbols, success: { (rate) in
          rates.append(rate)
          next(nil)
          }, failure: { (error) in
            next(nil)
        })
      }
      currentDate = currentDate + 1.days
    }
    queue.run() {
      print("Done")
      success(rates)
    }
  }
  
  func getRate(date: String, base: String, symbols: [String], success: @escaping (_ rate: Rate) -> Void, failure: @escaping (_ error: Error?) -> Void) {
    Alamofire.request("\(APIBaseURL)/\(date)", method: .get, parameters: [
      "base": base,
      "symbols": symbols.joined(separator: ",")
      ]).responseJSON { (response) in
        if let error = response.result.error {
          failure(error)
          return
        }
        guard let json = response.result.value as? [String: AnyObject],
          let date = json["date"] as? String,
          let base = json["base"] as? String,
          let rates = json["rates"] as? [String: NSNumber] else {
            failure(nil)
            return
        }
        let rate = Rate(date: date, base: base, rates: rates)
        success(rate)
    }
  }
  
}
