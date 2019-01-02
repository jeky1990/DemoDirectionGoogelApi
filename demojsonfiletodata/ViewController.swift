//
//  ViewController.swift
//  demojsonfiletodata
//
//  Created by macbook on 02/01/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var stepTableView : UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var stepsArray = [Any](){
        didSet{
            
            stepTableView.reloadData()
        }
    }

    var rectangle = GMSPolyline()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        GetDirectionData()
    }
    
    @IBAction func GetDirection(_ sender: UIButton) {
        
        GetDirectionData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else{
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    func GetDirectionData()
    {
        let file = Bundle.main.path(forResource: "route", ofType: "json")
        let fileURL = URL(fileURLWithPath: file!)
        do{
            let jsonData = try Data(contentsOf: fileURL)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
            let routes = json["routes"] as! [Any]
            let routesDic = routes[0] as! [String:Any]
            let Legs = routesDic["legs"] as! [Any]
            let alllegs = Legs[0] as! [String:Any]
            let steps = alllegs["steps"] as! [Any]
            stepsArray = steps
            
            
            let bound = routesDic["bounds"] as! [String:Any]
            let boundNorth = bound["northeast"] as! [String:Any]
            let sourcelat = boundNorth["lat"]
            let sourcelong = boundNorth["lng"]
            
            let boundWest = bound["southwest"] as! [String:Any]
            let desLat = boundWest["lat"]
            let desLong = boundWest["lng"]
            
            let routeOverviewPolyline = routesDic["overview_polyline"] as! [String:Any]
            let points = routeOverviewPolyline["points"] as! String
            let path = GMSPath.init(fromEncodedPath: points)
            let polyline = GMSPolyline.init(path: path)
            polyline.strokeWidth = 4
            polyline.strokeColor =  UIColor.blue
            polyline.map = self.mapView
        
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: sourcelat! as! CLLocationDegrees, longitude: sourcelong! as! CLLocationDegrees)
            // marker.icon = userImage.af_imageScaled(to: CGSize(width: 50, height: 50)).af_imageRoundedIntoCircle()
            marker.title = "Source"
            marker.map = mapView
            
            
            let markerr = GMSMarker()
            markerr.position = CLLocationCoordinate2D(latitude: desLat! as! CLLocationDegrees, longitude: desLong! as! CLLocationDegrees)
            // markerr.icon =  washerImage.af_imageScaled(to: CGSize(width: 50, height: 50)).af_imageRoundedIntoCircle()
            markerr.title = "Desintation"
            markerr.map = mapView
            
            let camera = GMSCameraPosition.camera(withLatitude: sourcelat! as! CLLocationDegrees, longitude: sourcelong! as! CLLocationDegrees, zoom: 13)
            self.mapView.camera = camera
            self.mapView.animate(to: camera)
              
         
        }
        catch{
            print("error in convert data")
        }
    }

}

extension ViewController :UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return stepsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let step = stepsArray[indexPath.row] as! [String:Any]
        let instruction = step["html_instructions"] as! String
        let distance = step["distance"] as! [String:Any]
        
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.text = instruction.html2String
        cell?.textLabel?.numberOfLines = 0
        cell?.detailTextLabel?.text = distance["text"] as? String
        
        
        return cell!
    }
}

extension ViewController :UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

