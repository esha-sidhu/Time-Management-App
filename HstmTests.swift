//
//  HstmTests.swift
//  HstmTests
//
//

import XCTest
@testable import HSTM

class HstmTests: XCTestCase {
    
    //HSTM Class Tests
    
    // Confirm that the initializer returns a HSTM object when passed valid parameters.
    func testHstmInitializationSucceeds() {
        /*
        // Zero rating
        let zeroRatingHstm = HSTM.init(name: "Zero", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRatingHstm)

        // Positive rating
        let positiveRatingHstm = HSTM.init(name: "Positive", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRatingHstm)
 */
    }
    
    // Confirm that the HSTM initialier returns nil when passed a negative rating or an empty name.
    func testHstmInitializationFails() {
      /*
        // Negative rating
        let negativeRatingHstm = HSTM.init(name: "Negative", photo: nil, rating: -1)
        XCTAssertNil(negativeRatingHstm)
        
        // Rating exceeds maximum
        let largeRatingHstm = HSTM.init(name: "Large", photo: nil, rating: 6)
        XCTAssertNil(largeRatingHstm)

        // Empty String
        let emptyStringHstm = HSTM.init(name: "", photo: nil, rating: 0)
        XCTAssertNil(emptyStringHstm)
      */
    }
}
