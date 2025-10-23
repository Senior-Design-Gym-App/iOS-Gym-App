import SwiftUI

struct WeightEntryViews {
    
    @AppStorage("sortMethod") private var sortMethod: Bool = false
    
    func DataView(data: WeightEntry, label: String) -> some View {
        HStack {
            Text("\(data.value, specifier: "%.1f") \(label)")
            Spacer()
            Text(data.date, style: .date)
        }
    }
    
    func DataHeader() -> some View {
        HStack {
            Text(sortMethod ? "Recent First" : "Recent Last")
            Spacer()
            Button {
                sortMethod.toggle()
            } label: {
                Image(systemName: sortMethod ? "arrow.up" : "arrow.down")
            }
            .contentTransition(.symbolEffect(.replace))
            .tint(Constants.mainAppTheme.secondary)
        }
    }
    
}
