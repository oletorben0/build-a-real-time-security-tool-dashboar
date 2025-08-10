import UIKit
import CoreLocation
import SwiftUI
import Combine

struct SecurityData: Identifiable, Codable {
    let id = UUID()
    var threatLevel: Int
    var location: CLLocation
    var timestamp: Date
}

class SecurityViewModel {
    @Published var securityData: [SecurityData] = []
    @Published var threatLevel: Int = 0
    @Published var warningMessage: String = ""

    private let locationManager = CLLocationManager()
    private let analyticsService = AnalyticsService()

    init() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        analyticsService.fetchSecurityData { [weak self] data in
            self?.securityData = data
            self?.updateThreatLevel()
        }
    }

    func updateThreatLevel() {
        threatLevel = securityData.reduce(0) { $0 + $1.threatLevel } / securityData.count
        if threatLevel > 50 {
            warningMessage = "High threat level detected!"
        } else {
            warningMessage = ""
        }
    }
}

class AnalyticsService {
    func fetchSecurityData(completion: @escaping ([SecurityData]) -> Void) {
        // Simulate API call to fetch security data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion([
                SecurityData(threatLevel: 20, location: CLLocation(latitude: 37.7749, longitude: -122.4194), timestamp: Date()),
                SecurityData(threatLevel: 30, location: CLLocation(latitude: 34.0522, longitude: -118.2437), timestamp: Date()),
                SecurityData(threatLevel: 40, location: CLLocation(latitude: 40.7128, longitude: -74.0060), timestamp: Date())
            ])
        }
    }
}

extension SecurityViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        // Update location-based security data
        securityData.append(SecurityData(threatLevel: 10, location: location, timestamp: Date()))
        updateThreatLevel()
    }
}

struct DashboardView: View {
    @StateObject var viewModel = SecurityViewModel()

    var body: some View {
        VStack {
            Text("Threat Level: \(viewModel.threatLevel)")
                .font(.largeTitle)
            Text(viewModel.warningMessage)
                .foregroundColor(.red)
            List(viewModel.securityData) { data in
                VStack(alignment: .leading) {
                    Text("Location: \(data.location.coordinate.latitude), \(data.location.coordinate.longitude)")
                    Text("Timestamp: \(data.timestamp)")
                    Text("Threat Level: \(data.threatLevel)")
                }
            }
        }
    }
}

@main
struct AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(rootView: DashboardView())
        window?.makeKeyAndVisible()
        return true
    }
}