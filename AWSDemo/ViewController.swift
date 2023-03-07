
// Created by Bojiang Li on 2/13/2022.
// Last commit by Bojiang Li on 3/21/2022.

import UIKit
import MapKit
import CoreLocation
import CoreLocationUI
import AVFoundation



class ViewController: UIViewController, CLLocationManagerDelegate {
    var points = [[String]]()
    var player:AVAudioPlayer? = nil
    lazy var musicButton:UIButton =  {
        let  musicButton = UIButton.init(frame: CGRect(x:0 ,y:0,width: 100  ,height: 40))
        musicButton.center = self.view.center
        musicButton.setTitle("PlayMusic", for: .normal)
        musicButton.backgroundColor = UIColor.black
        musicButton.addTarget(self, action: #selector(playMusic), for: .touchUpInside)
        return musicButton
    }()
    
    var notification = false

    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
//    let mapView = MKMapView()
     
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 20, y: 50, width: view.frame.self.width-40, height: view.frame.size.height-100)
        locationManager.delegate = self
        mapView.delegate = self
        getDirections()
        getDirections2()
        createButton()
        
        //createNotifyButton()
        //createAnotions()
        ///---MARK:
//        createMusicPlayButton()
        ///---MARK:
        let url = URL(string: "https://18745-data-analysis.s3.us-west-2.amazonaws.com/infras/obj_detection/results.csv")
        print("11111111")
        FileDownloader.loadFileAsync(url: url!) {[weak self] (path, error) in
            guard let `self` = self , let  filepath = path else {return }
            print("CSV File downloaded to : \(path!)")
            var  arrays =  self.decodeCSV(path: filepath)
            var lastLat = ""
            var lastLng = ""
            for  ara in arrays {
                
                print("info line  :\(ara.Latitude),\(ara.Longitude)，\(ara.Obstacle)")
                let annotation1 = MKPointAnnotation()
                let lat = Double(ara.Latitude) ?? 0
                let log = Double(ara.Longitude) ?? 0
//                var point = [Double] ()
//                point[0] = lat
//                point[1] = log
                if (lastLat != ara.Latitude) && (lastLng != ara.Longitude){
                    self.points.append([ara.Latitude,ara.Longitude])
                }
                else{
                    lastLat = ara.Latitude
                    lastLng = ara.Longitude
                }
                self.points.append([ara.Latitude,ara.Longitude])
                annotation1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                annotation1.title = "obstacle detected"
                self.mapView.addAnnotation(annotation1)
            }
        }
                    
        
        let button = UIButton(frame: CGRect(x: 140,
                                                    y: 660,
                                                    width: 200,
                                                    height: 60))
                button.setTitle("Notification",
                                for: .normal)
                button.setTitleColor(.systemBlue,
                                     for: .normal)
                
                button.addTarget(self,
                                 action: #selector(buttonAction),
                                 for: .touchUpInside)
                
                self.view.addSubview(button)
       
        
        
        
//        let annotation1 = MKPointAnnotation()
//        annotation1.coordinate = CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.9428)
//        annotation1.title = "Ice"
//        mapView.addAnnotation(annotation1)
//
//        let annotation2 = MKPointAnnotation()
//        annotation2.coordinate = CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.96)
//        annotation1.title = "Tree in the road"
//        mapView.addAnnotation(annotation2)
//
//        let annotation3 = MKPointAnnotation()
//        annotation3.coordinate = CLLocationCoordinate2D(latitude: 40.45, longitude: -79.93)
//        annotation3.title = "Rock"
//        mapView.addAnnotation(annotation3)
//
//        let annotation4 = MKPointAnnotation()
//        annotation4.coordinate = CLLocationCoordinate2D(latitude: 40.44, longitude: -79.95)
//        annotation4.title = "Ice"
//        mapView.addAnnotation(annotation4)
//
//        let region = MKCoordinateRegion(center: annotation1.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)

//        mapView.setRegion(region, animated: true)

        

    }
    ///---MARK:
    func createMusicPlayButton() {
        self.view.addSubview(self.musicButton)
        self.view.bringSubviewToFront(musicButton)
    }
    
    private func createButton() {
        let button = CLLocationButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.center = CGPoint(x: view.center.x, y: view.frame.size.height-70)
        button.cornerRadius = 12
        button.icon = .arrowOutline
        view.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        locationManager.startUpdatingLocation()
        checkDistance()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.userTrackingMode = .follow
        guard let location = locations.first else {return}
        self.locationManager.stopUpdatingLocation()
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // ask for permition for location
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else {
            // show alert letting the user kow they have to turn on
        }
    }
    
    func checkLocationAuthorization() {
        
    }
    
    @objc
        func buttonAction() {
            if (notification == false) {
                self.showToast(message: "Notification Mode On", font: .systemFont(ofSize: 12.0))
                self.notification = !notification

            } else {
                self.showToast(message: "Notification Mode Off", font: .systemFont(ofSize: 12.0))
                self.notification = !notification

            }
            print("Notification Button pressed")
        }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 90, y: self.view.frame.size.height - 400, width: 200, height: 60))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 6.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func getDirections() {
        let request = MKDirections.Request()
        // Source
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.45, longitude: -79.93))
        request.source = MKMapItem(placemark: sourcePlaceMark)
        // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.4432, longitude: -79.9428))
        request.destination = MKMapItem(placemark: destPlaceMark)
        // Transport Types
        request.transportType = [.automobile, .walking]

//        let directions = MKDirections(request: request)
//        directions.calculate { response, error in
//            guard let response = response else {
//                print("Error: \(error?.localizedDescription ?? "No error specified").")
//                return
//            }
//
//            let route = response.routes[0]
//            self.mapView.addOverlay(route.polyline)
//
//            // …
//        }

    }
    
    func getDirections2() {
        let request = MKDirections.Request()
        // Source
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.445, longitude: -79.965))
        request.source = MKMapItem(placemark: sourcePlaceMark)
        // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.44, longitude: -79.968))
        request.destination = MKMapItem(placemark: destPlaceMark)
        // Transport Types
        request.transportType = [.automobile, .walking]

//        let directions = MKDirections(request: request)
//        directions.calculate { response, error in
//            guard let response = response else {
//                print("Error: \(error?.localizedDescription ?? "No error specified").")
//                return
//            }
//
//            let route = response.routes[0]
//            self.mapView.addOverlay(route.polyline)
//
//            // …
//        }

    }
    func radians(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func haversine_distance(origin : [Double] , destination : [Double]) -> Double{
        let lat1 = origin[0]
        let lon1 = origin[1]
        let lat2 = destination[0]
        let lon2 = destination[1]
        let radius = 6371.0  // km
        let dlat = radians(lat2 - lat1)
        let dlon = radians(lon2 - lon1)
        let a = sin(dlat / 2) * sin(dlat / 2) + cos(radians(lat1)) * cos( radians(lat2)) * sin(dlon / 2) * sin(dlon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = radius * c
        return d
    }

    func checkDistance(){
        addThread(completion: {(success) in
            if success{
                self.playMusic()
            }
        })
    }

    func addThread(completion: @escaping (Bool)-> Void){
        DispatchQueue.global().asyncAfter(deadline: .now() + 2){
//        let cur = [60.445,-79.965]
        let curLat = self.mapView.userLocation.coordinate.latitude
        let curLng = self.mapView.userLocation.coordinate.longitude
        let cur = [curLat, curLng]
        print("cur",cur)
        for coor in self.points{
            let lat = Double(coor[0]) ?? 0
            let log = Double(coor[1]) ?? 0
            if (self.haversine_distance(origin : cur, destination : [lat,log]) <= 0.1){
                print("true")
                DispatchQueue.main.async {
                    completion(true)
                }
            }
            else{
                DispatchQueue.main.async {
                    completion(false)
                    }
                }
            }
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        // Set the color for the line
        renderer.strokeColor = .red
        return renderer
    }
}

//extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    //
//    }
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        //
//    }
//}


///---MARK:
extension ViewController:AVAudioPlayerDelegate {
    
   @objc func   playMusic(){
        guard let soundFileURL = Bundle.main.url(
            forResource: "test", withExtension: "mp3"
        ) else  {
            debugPrint("audio can not found")
            return
        }
        let  err = try? AVAudioSession.sharedInstance().setCategory(
            AVAudioSession.Category.playback,
            options: AVAudioSession.CategoryOptions.mixWithOthers
            )
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                // Handle error
                debugPrint(error)
            }
           player =  try? AVAudioPlayer(contentsOf: soundFileURL)
           player?.delegate = self
           player?.play()
        musicButton.setTitle("Playing", for: .normal)
        
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            musicButton.setTitle("PlayMusic", for: .normal)
        }
    }
}
///---MARK:


extension  ViewController {
    ///---MARK:
    func  decodeCSV(path:String) -> [CSVLocationDataInfo] {
        guard let   csvFile = try? CSVReader.init(stream: InputStream.init(url: URL.init(fileURLWithPath: path))!,hasHeaderRow: true)  else{
            print("file error")
            return []
        }
        guard let   headers = csvFile.headerRow else {
            return []
        }
        
        let  arrayInfos:[CSVLocationDataInfo] =   csvFile.map { (lineStr) -> CSVLocationDataInfo in
            var  dic:[String:Any] = [:]
        
            for  i in 0..<headers.count{
                dic[headers[i]] = lineStr[i]
            }
            let decoder = JSONDecoder()
            let product = try? decoder.toModel(CSVLocationDataInfo.self, value: dic)
            return product ??  CSVLocationDataInfo.init()
        }
        return  arrayInfos
    }
    ///---MARK:
}
