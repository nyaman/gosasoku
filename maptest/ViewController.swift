//
//  ViewController.swift
//  MapKit003
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var myMapView: MKMapView!
    var myLocationManager: CLLocationManager!
    
    var myLabel:UILabel!
    var distLabel:UILabel!

    var lastlocation :CLLocationCoordinate2D!
    
    var locationCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンの生成.
        let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        myButton.backgroundColor = UIColor.orangeColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("Do", forState: .Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width-40, y:self.view.bounds.height-40)
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        myButton.showsTouchWhenHighlighted = true
        
        // LocationManagerの生成.
        myLocationManager = CLLocationManager()
        
        // Delegateの設定.
        myLocationManager.delegate = self
        
        // 距離のフィルタ.
        myLocationManager.distanceFilter = 100.0
        
        // 精度.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization();
        }
        
        // 位置情報の更新を開始.
        myLocationManager.startUpdatingLocation()
        
        // MapViewの生成.
        myMapView = MKMapView()
        
        // MapViewのサイズを画面全体に.
        myMapView.frame = self.view.bounds
        
        // Delegateを設定.
        myMapView.delegate = self
        
        // MapViewをViewに追加.
        self.view.addSubview(myMapView)
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = 37.506804
        let myLon: CLLocationDegrees = 139.930531
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon) as CLLocationCoordinate2D
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 100
        let myLonDist : CLLocationDistance = 100
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, myLatDist, myLonDist);
        
        // MapViewに反映.
        myMapView.setRegion(myRegion, animated: true)
        
        myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        myLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y:100.0)
//        myLabel.text = locationCount.description+"回測定しました"
//        myLabel.textAlignment = NSTextAlignment.Center

        distLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        distLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - 100)

        self.view.addSubview(myButton)
//        self.view.addSubview(myLabel)
        
        // 長押しのUIGestureRecognizerを生成.
        var myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: "recognizeLongPress:")
        
        // MapViewにUIGestureRecognizerを追加.
        myMapView.addGestureRecognizer(myLongPress)
    }
    
    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
        // 現在位置の取得を開始.
        myLocationManager.startUpdatingLocation()
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 配列から現在座標を取得.
        let myLocations: NSArray = locations as NSArray
        let myLastLocation: CLLocation = myLocations.lastObject as! CLLocation
        let myLocation:CLLocationCoordinate2D = myLastLocation.coordinate
        
        self.lastlocation = myLocation
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 100
        let myLonDist : CLLocationDistance = 100
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, myLatDist, myLonDist);
        
        locationCount += 1
        
        // MapViewに反映.
        myMapView.setRegion(myRegion, animated: true)
        myLabel.text = locationCount.description+"回測定しました"
        myLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(myLabel)

        //ピンを立てる
        putPin(myLastLocation)

        //自動更新stop
        manager.stopUpdatingLocation()
    }

    //ピンを立てる関数
    func putPin(myLastLocation: CLLocation) {
        let now = NSDate()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let pointtime = formatter.stringFromDate(now)
        
        // ピンを生成.
        let myPin: MKPointAnnotation = MKPointAnnotation()
        // 中心点.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLastLocation.coordinate.latitude, myLastLocation.coordinate.longitude)
        // 座標を設定.
        myPin.coordinate = center
        // タイトルを設定.
        myPin.title = "精度 "+myLastLocation.horizontalAccuracy.description
        // サブタイトルを設定.
        myPin.subtitle = "時刻 "+pointtime
        
 //       myPin.description = "緯度 "+myLastLocation.coordinate.latitude.description+"\n経度 "+myLastLocation.coordinate.longitude.description
        
        // MapViewにピンを追加.
        myMapView.addAnnotation(myPin)
    }
    
    /*
     長押しを感知した際に呼ばれるメソッド.
     */
    func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        
        // 長押しの最中に何度もピンを生成しないようにする.
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        
        // 長押しした地点の座標を取得.
        var location = sender.locationInView(myMapView)
        
        // locationをCLLocationCoordinate2Dに変換.
        let distCoordinate: CLLocationCoordinate2D = myMapView.convertPoint(location, toCoordinateFromView: myMapView)
        
        var point1 = MKMapPointForCoordinate(distCoordinate)
        var point2 = MKMapPointForCoordinate(self.lastlocation)
        var distance = MKMetersBetweenMapPoints(point1, point2)
        
        distLabel.text = NSString(format: "%.1f m離れています", distance) as String
        distLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(distLabel)
    }
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    
    // 認証が変更された時に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            print("AuthorizedWhenInUse")
        case .Authorized:
            print("Authorized")
        case .Denied:
            print("Denied")
        case .Restricted:
            print("Restricted")
        case .NotDetermined:
            print("NotDetermined")
        default:
            print("etc.")
        }
    }
    
}