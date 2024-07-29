import Foundation

// Klasse til at håndtere netværkskommunikation
class NetworkManager {
    // Instans til at hele appen kan få adgang og array til at gemme URL's fra database
    static let shared = NetworkManager()
    var approvedURLs: [String] = []
    
    // Hent af forhåndsgodkendte URL'er fra server
    func fetchApprovedURLs(completion: @escaping (Bool) -> Void) {
        let urlString = "http://192.168.0.16/fetch_approved_urls"
        // Sikrer at URL-strengen er formatteret korrekt
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        // Opsætter HTTP-metode, og sætter til GET
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //Data-task startes og der tjekkes for fejl, og at data er modtaget
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error:", error ?? "Unknown error")
                completion(false)
                return
            }
            // Forsøger at dekode modtaget data til en array af strenge og opdaterer listen
            if let fetchedURLs = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    self.approvedURLs = fetchedURLs
                    completion(true)
                }
            } else {
                print("Invalid response from server")
                completion(false)
            }
        }.resume()
    }
    //Check for URL på forhåndsgodkendt liste
    func isURLApproved(_ url: String) -> Bool {
        return approvedURLs.contains(url)
    }
}
