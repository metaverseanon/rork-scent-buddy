import SwiftUI
import SwiftData

@Observable
@MainActor
class CollectionViewModel {
    var searchText: String = ""
    var selectedSortOption: SortOption = .dateAdded
    var showingAddPerfume: Bool = false
    var selectedFilter: String = "All"

    let filterOptions = ["All", "Favorites", "Eau de Parfum", "Eau de Toilette", "Extrait de Parfum"]

    func filteredPerfumes(_ perfumes: [Perfume]) -> [Perfume] {
        var result = perfumes

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedStandardContains(searchText) ||
                $0.brand.localizedStandardContains(searchText)
            }
        }

        switch selectedFilter {
        case "Favorites":
            result = result.filter(\.isFavorite)
        case "All":
            break
        default:
            result = result.filter { $0.concentration == selectedFilter }
        }

        switch selectedSortOption {
        case .dateAdded:
            result.sort { $0.dateAdded > $1.dateAdded }
        case .name:
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .brand:
            result.sort { $0.brand.localizedCompare($1.brand) == .orderedAscending }
        case .rating:
            result.sort { $0.rating > $1.rating }
        }

        return result
    }
}

nonisolated enum SortOption: String, CaseIterable, Sendable {
    case dateAdded = "Date Added"
    case name = "Name"
    case brand = "Brand"
    case rating = "Rating"

    var icon: String {
        switch self {
        case .dateAdded: return "calendar"
        case .name: return "textformat"
        case .brand: return "tag"
        case .rating: return "star"
        }
    }
}
