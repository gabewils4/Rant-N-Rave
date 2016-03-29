

import UIKit
import MapKit

class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor
    var title1: String?
    var subtitle1: String?
    
    init(pinColor: UIColor, title: String, subtitle: String, id: String) {
        
        self.pinColor = pinColor
        self.subtitle1 = subtitle
        super.init()
        self.title = title
        self.subtitle = subtitle
        
    }
}
