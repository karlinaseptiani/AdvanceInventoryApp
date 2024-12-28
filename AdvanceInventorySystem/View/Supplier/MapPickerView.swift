//
//  MapPickerView.swift
//  AdvanceInventorySystem
//
//  Created by Karlina Dwi Septiani on 23/12/24.
//


import SwiftUI
import MapKit
import CoreLocation

struct MapPickerView: View {
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var isPresented: Bool

    @State private var annotations: [AnnotationItem] = []
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchText: String = "" // Untuk teks pencarian lokasi
    @StateObject private var locationManagerDelegate = CLLocationManagerDelegateWrapper() // Delegasi untuk mengelola lokasi pengguna
    
    var body: some View {
        VStack {
            // Komponen pencarian lokasi
            SearchBar(text: $searchText, onSearch: searchLocation)
            
            // Map yang mendukung anotasi dan interaksi
            MapViewRepresentable(region: $region, annotations: $annotations, onTap: addAnnotation(at:))
                .edgesIgnoringSafeArea(.all)
            
            HStack (){
                
                // Informasi lokasi yang dipilih
                Text("lat: \(latitude),long: \(longitude)")
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)


                Button {
                    locationManagerDelegate.requestLocation()
                } label: {
                    Image(systemName: "location")
                        .padding()
                        .frame(width: 40, height: 40)
                        .background(.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                }

            }
            .padding()

            Button(action: {
                print("Selected Location: \(latitude), \(longitude)")
                isPresented = false
            }) {
                Text("Select Location")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            // Inisialisasi pengaturan lokasi saat tampilan muncul
            setupLocationManager()
        }
    }

    // Fungsi untuk mengatur lokasi awal pengguna
    private func setupLocationManager() {
        locationManagerDelegate.onLocationUpdate = { location in
            if let location = location {
                let coordinate = location.coordinate
                latitude = coordinate.latitude
                longitude = coordinate.longitude
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                annotations = [AnnotationItem(coordinate: coordinate)]
            }
        }
        locationManagerDelegate.requestLocation()
    }

    // Fungsi untuk menambahkan anotasi pada lokasi yang ditap
    private func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        annotations = [AnnotationItem(coordinate: coordinate)]
        
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    // Fungsi untuk mencari lokasi berdasarkan teks pencarian
    private func searchLocation(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let firstItem = response.mapItems.first else {
                print("Location not found or error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let coordinate = firstItem.placemark.coordinate
            DispatchQueue.main.async {
                latitude = coordinate.latitude
                longitude = coordinate.longitude
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                annotations = [AnnotationItem(coordinate: coordinate)]
            }
        }
    }
}

// Reusable MapView menggunakan UIViewRepresentable
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [AnnotationItem]
    var onTap: (CLLocationCoordinate2D) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations.map { annotation in
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = annotation.coordinate
            return mapAnnotation
        })
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let locationInView = gesture.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            parent.onTap(coordinate)
        }
    }
}


// Wrapper untuk CLLocationManager
class CLLocationManagerDelegateWrapper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    var onLocationUpdate: ((CLLocation?) -> Void)?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        onLocationUpdate?(locations.last)
        manager.stopUpdatingLocation() // Stop setelah mendapatkan lokasi untuk hemat baterai
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
