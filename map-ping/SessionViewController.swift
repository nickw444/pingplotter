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

class ColoredCircle: MKCircle {
    var color = UIColor.black
}

class SessionViewController: UIViewController {
    public var session: Session! = nil
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        loadMap()
    }
    
    func loadMap() {
        mapView.setRegion(mapRegion(), animated: true)
        mapView.addOverlays(points())
    }
    func points() -> [ColoredCircle] {
        var points: [ColoredCircle] = []
        
        let sort = NSSortDescriptor(key: "sendTime", ascending: true)
        let requests = self.session.requests!.sortedArray(using: [sort]) as! [Request]
        for first in requests {
            let start = CLLocation(latitude: first.sendLat, longitude: first.sendLong)
            let circle = ColoredCircle(center: start.coordinate, radius: 15)
            circle.color = segmentColor(req: first)
            points.append(circle)
        }
        
        return points
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
    
    private func segmentColor(req: Request) -> UIColor {
        
        if (req.recvTime == nil || req.timeout) {
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        let red = UIColor(red: 1, green: 20/255, blue: 44/255, alpha: 1)
        let yellow = UIColor(red: 1, green: 215/255, blue: 0, alpha: 1)
        let green = UIColor(red: 0, green: 146/255, blue: 78/255, alpha: 1)
        
        // < 50, green ish
        // < 300, ok
        // < 1000, not good
        // > 1000, bad
        // > 5000, terrible.

        let latency = req.latency
        if latency < 50 {
            return green
        } else if latency < 300 {
            let progress = CGFloat(latency - 50) / (300 - 50)
            return UIColor.interpolate(from: green, to: yellow, with: progress)
        } else if latency < 1000 {
            let progress = CGFloat(latency - 300) / (1000 - 300)
            return UIColor.interpolate(from: yellow, to: red, with: progress)
        } else {
            return red
        }
    }
}

// MARK: - Map View Delegate

extension SessionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {        
        if let circle = overlay as? ColoredCircle {
            let renderer = MKCircleRenderer(circle: circle)
            let c = circle.color
            renderer.fillColor = c.withAlphaComponent(0.2)
            renderer.strokeColor = c
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
