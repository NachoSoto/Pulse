// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI

#if os(iOS) || os(tvOS)

struct ConsoleFiltersLabelsPickerView: View {
    @ObservedObject var viewModel: ConsoleMessageSearchCriteriaViewModel

    @State private var searchText = ""

    var body: some View {
        if #available(iOS 15, tvOS 15, *) {
            form
#if os(iOS)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
#else
                .searchable(text: $searchText)
#endif
        } else {
            form
        }
    }

    @ViewBuilder
    private var form: some View {
        Form {
            Button(viewModel.bindingForTogglingAllLabels.wrappedValue ? "Disable All" : "Enable All", action: { viewModel.bindingForTogglingAllLabels.wrappedValue.toggle() })
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.accentColor)

            ForEach(labels, id: \.self) { item in
                Toggle(item.capitalized, isOn: viewModel.binding(forLabel: item))
            }
        }
        .navigationBarTitle("Labels")
    }

    private var labels: [String] {
        if searchText.isEmpty {
            return viewModel.allLabels
        } else {
            return viewModel.allLabels.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#if DEBUG
struct ConsoleFiltersLabelsPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsoleFiltersLabelsPickerView(viewModel: .init(store: .mock))
        }
    }
}
#endif

#endif
