import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var isShowingScanner = false
    @State private var scannedCode = "Scan a QR code to get started."
    @State private var isApproved = false
    @State private var isShowingStartScreen = true
    @State private var approvedURL = ""
    @State private var isLoading = true
    @State private var fetchSuccess = true
    // Her defineres QR scanner, vha apples CodeScanner bibliotek
    var scannerSheet: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "http://approvedsite.com", completion: handleScan)
    }
    // Her bygges GUI
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Fetching approved URLs...")
            } else if !fetchSuccess {
                Text("Failed to fetch approved URLs. Please try again.")
            } else {
                if isShowingStartScreen {
                    StartScreenView(startScanningAction: {
                        isShowingScanner = true
                    })
                    .sheet(isPresented: $isShowingScanner) {
                        scannerSheet
                    }
                } else {
                    LandingPageView(url: approvedURL, imageName: isApproved ? "approvedLandingPage" : "nonApprovedLandingPage", startScanningAction: {
                        isShowingScanner = true
                    })
                    .sheet(isPresented: $isShowingScanner) {
                        scannerSheet
                    }
                }
            }
        }
        // Ved opstart af app hentes URL'er fra database
        .onAppear {
            NetworkManager.shared.fetchApprovedURLs { success in
                self.fetchSuccess = success
                self.isLoading = false
            }
        }
    }
    // QR-scanning håndteres
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let code):
            isApproved = NetworkManager.shared.isURLApproved(code.string)
            scannedCode = code.string
            approvedURL = code.string
            isShowingStartScreen = false
            if scannedCode == "https://www.roskilde-festival.dk/"{
                isApproved = true
            }
        case .failure(_):
            scannedCode = "Failed to scan QR code"
            isShowingStartScreen = true
        }
    }
}

// Struktur til at bygge forhåndsvisning
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
// Visning af startside
struct StartScreenView: View {
    var startScanningAction: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("backgroundWithLogoAndTitle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Button("Start Scanning") {
                        startScanningAction()
                    }
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color("Pantone151C"))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .font(.headline)
                    .shadow(radius: 10)
                    .padding(.bottom, geo.size.height * 0.1)
                }
            }
        }
    }
}

// Visning af landingside
struct LandingPageView: View {
    var url: String
    var imageName: String
    var startScanningAction: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Link(destination: URL(string: url)!) {
                        Text(url)
                            .foregroundColor(Color.blue)
                            .frame(width: geo.size.width * 0.8, height: 50)
                            .padding()
                            .underline()
                    }
                    .padding(.bottom, geo.size.height * 0.02)

                    Button("Scan Another Code") {
                        startScanningAction()
                    }
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color("Pantone151C"))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .font(.headline)
                    .padding(.bottom, geo.size.height * 0.001)
                    
                }
            }
        }
    }
}
