//
//  SessionViewController.swift
//  map-ping
//
//  Created by Nicholas Whyte on 25/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SessionViewController: UIViewController {
    public var session: Session! = nil
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        loadMap()
    }
    
    func loadMap() {
        mapView.setRegion(mapRegion(), animated: true)
        mapView.addOverlays(polyLine())
    }
    
    func polyLine() -> [MulticolorPolyline] {
        var segments: [MulticolorPolyline] = []
        
        let sort = NSSortDescriptor(key: "sendTime", ascending: true)
        let requests = self.session.requests!.sortedArray(using: [sort]) as! [Request]
//        let requests = self.session.requests!.allObjects as! [Request]
        for (first, second) in zip(requests, requests.dropFirst()) {
            let start = CLLocation(latitude: first.sendLat, longitude: first.sendLong)
            let end = CLLocation(latitude: second.sendLat, longitude: second.sendLong)
            
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = segmentColor(latency: first.latency)
            segments.append(segment)
        }
        
        return segments
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let requests = self.session.requests!.allObjects as! [Request]
        
        let latitudes = requests.map { request -> Double in
            return request.sendLat
        }
        
        let longitudes = requests.map { request -> Double in
            return request.sendLong
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func segmentColor(latency: Double) -> UIColor {
//        enum BaseColors {
//            static let r_red: CGFloat = 1
//            static let r_green: CGFloat = 20 / 255
//            static let r_blue: CGFloat = 44 / 255
//
//            static let y_red: CGFloat = 1
//            static let y_green: CGFloat = 215 / 255
//            static let y_blue: CGFloat = 0
//
//            static let g_red: CGFloat = 0
//            static let g_green: CGFloat = 146 / 255
//            static let g_blue: CGFloat = 78 / 255
//        }
        
        // < 50, green ish
        // < 300, ok
        // < 1, not good
        // > 1, bad
        // > 5, terrible.
        
        
        
//
        let red, green, blue: CGFloat
        
//
//        if latency > midSpeed {
//            let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
//            red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
//            green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
//            blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
//        } else {
//            let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
//            red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
//            green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
//            blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
//        }
//
        return UIColor(red: 255, green: 0, blue: 0, alpha: 1)
    }
}




// MARK: - Map View Delegate

extension SessionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MulticolorPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? BadgeAnnotation else { return nil }
//        let reuseID = "checkpoint"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
//            annotationView?.image = #imageLiteral(resourceName: "mapPin")
//            annotationView?.canShowCallout = true
//        }
//        annotationView?.annotation = annotation
//
//        let badgeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        badgeImageView.image = UIImage(named: annotation.imageName)
//        badgeImageView.contentMode = .scaleAspectFit
//        annotationView?.leftCalloutAccessoryView = badgeImageView
//
//        return annotationView
//    }
}
