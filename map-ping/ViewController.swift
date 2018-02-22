//
//  ViewController.swift
//  map-ping
//
//  Created by Nicholas Whyte on 22/2/18.
//  Copyright © 2018 Nicholas Whyte. All rights reserved.
//
import CoreLocation
import UIKit
import PlainPing
import CoreData
import CoreTelephony

class ViewController: UITableViewController, CLLocationManagerDelegate {
    
    var seqId: Int = 0
    var startTime: Date? = nil
    var totalSent: Int = 0
    var totalErr: Int = 0
    var lastLatency: Double = 0
    var activeSession: Session? = nil
    
    var ctx: NSManagedObjectContext!
    var location: CLLocationManager!
    
    var running: Bool = false
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var signalStrengthLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var totalPendingLabel: UILabel!
    @IBOutlet weak var totalErrorLabel: UILabel!
    @IBOutlet weak var totalSentLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!
    @IBOutlet weak var technologyLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.hostField.text = "8.8.8.8";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ctx = appDelegate.persistentContainer.viewContext
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        self.location = CLLocationManager()
        self.location.delegate = self
        self.location.allowsBackgroundLocationUpdates = true
        self.location.showsBackgroundLocationIndicator = true
        
        // For use in foreground
        self.location.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.location.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.location.startUpdatingLocation()
        } else {
            print("No location available");
        }
        
        self.updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View diappear")
    }
    
    func startStopPressed() {
        running = !running
        if (running && activeSession == nil){
            print("Creating new session!")
            activeSession = Session(context: ctx)
            activeSession!.date = Date() as NSDate
            activeSession!.network = getNetworkProvider()
            activeSession!.device = UIDevice.current.modelName
        }
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.locationDidUpdate(coordinate: coordinate)
    }
    
    func updateUI() {
        totalSentLabel.text = "\(totalSent)"
        totalErrorLabel.text = "\(totalErr)"
        totalPendingLabel.text = "\(totalPending)"
        let roundedLatency = Double(round(lastLatency * 1000)) / 1000
        latencyLabel.text = "\(roundedLatency)"
        
        providerLabel.text = getNetworkProvider()
        technologyLabel.text = getRadioAccessTechnology()
        signalStrengthLabel.text = "\(getSignalStrength())"
        
        if (running) {
            startStopLabel.text = "Pause"
            doneButton.isEnabled = false
        } else {
            startStopLabel.text = "Start"
            doneButton.isEnabled = true
        }
    }
    
    var totalPending:Int {
        get {
            // TODO NW Query coredata.
            return 0
        }
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            break
        case 1: do {
            switch indexPath.row {
            case 0:
                self.hostField.becomeFirstResponder()
                break
            case 5:
                print("start stop")
                self.dismissKeyboard()
                self.startStopPressed()
                break
            default:
                break
            }
        }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func locationDidUpdate(coordinate: CLLocationCoordinate2D) {
        guard self.running else  {  return }
        guard let session = self.activeSession else {
            return
        }
        
        let req = Request(context: self.ctx)
        req.seqId = Int32(seqId)
        req.sendTime = Date() as NSDate
        req.sendLat = coordinate.latitude
        req.sendLong = coordinate.longitude
        req.session = session
        req.sendTechnology = getRadioAccessTechnology()
        req.sendSignal = Int16(getSignalStrength())
        
        let strength = getSignalStrength()
        print("Signal strength: \(strength)")
        
        ctx.insert(req)
        try! ctx.save()
        
        PlainPing.ping(self.hostField.text!, withTimeout: 10.0, completionBlock: self.onPingCompletion(req: req))
        seqId += 1
        totalSent += 1
        
    }
    
    func getRadioAccessTechnology() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.currentRadioAccessTechnology?.replacingOccurrences(of: "CTRadioAccessTechnology", with: "")
    }
    
    func getNetworkProvider() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.subscriberCellularProvider?.carrierName
    }
    
    private func onPingCompletion(req: Request) -> (Double?, Error?) -> Void{
        return { [weak self](timeElapsed: Double?, error: Error?) -> Void in
            guard let `self` = self else { return }
            
            let coordinate = self.location.location?.coordinate
            req.recvLat = coordinate?.latitude ?? 0
            req.recvLong = coordinate?.longitude ?? 0
            req.recvTime = Date() as NSDate
            req.recvTechnology = self.getRadioAccessTechnology()
            req.recvSignal = Int16(self.getSignalStrength())
    
            
            if let latency = timeElapsed {
                req.latency = latency
                req.timeout = false
                self.lastLatency = latency
            }
            
            if error != nil {
                req.timeout = true
                self.totalErr += 1
            }
            
            print("Recv Ping with Seq \(req.seqId). Latency: \(req.latency) Tech: \(req.recvTechnology ?? "")")
            try! self.ctx.save()
            self.updateUI()
        }
    }
    
    func getSignalStrength() -> Int {
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews
        
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
    }
}






