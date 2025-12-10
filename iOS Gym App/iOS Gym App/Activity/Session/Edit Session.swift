import SwiftUI

struct SessionTitleInfo: View {
    
    let deleteSession: () -> Void
    @Binding var session: WorkoutSession
    @State var startDate: Date
    @State var endDate: Date
    @State private var showDateSheet: Bool = false
    @State private var dateSelect: Bool = false
    
    var body: some View {
        SessionTitle()
            .sheet(isPresented: $showDateSheet) {
                NavigationStack {
                    VStack {
                        switch dateSelect {
                        case true:
                            DateSelector(date: $startDate, dateSelect: true)
                        case false:
                            DateSelector(date: $endDate, dateSelect: false)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            ReusedViews.Buttons.SaveButton(disabled: startDate >= endDate, save: UpdateDates)
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            ReusedViews.Buttons.CancelButton(cancel: Dismiss)
                        }
                        ToolbarItem(placement: .principal) {
                            DateSelect()
                        }
                    }
                }.presentationDetents([.height(200)])
            }
    }
    
    private func DateSelect() -> some View {
        Picker("Date Select", selection: $dateSelect) {
            Text("Start Date").tag(true)
            Text("End Date").tag(false)
        }.pickerStyle(.segmented)
    }
    
    private func DateSelector(date: Binding<Date>, dateSelect: Bool) -> some View {
        DatePicker(dateSelect ? "Start Date" : "End Date", selection: date)
            .datePickerStyle(.wheel)
            .labelsHidden()
    }
    
    private func SessionTitle() -> some View {
        HStack {
            GenerateImage(for: session.started)
                .resizable()
                .frame(width: Constants.mediumIconSize, height: Constants.mediumIconSize)
                .foregroundStyle(session.color)
            VStack(alignment: .leading) {
                Text(session.name)
                    .font(.title)
                    .fontWeight(.semibold)
                NavigationLink {
                    DayActivity(dayProgress: session.started)
                } label: {
                    Text(formatDateRange(start: session.started, end: session.completed))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .fontWeight(.light)
                }.navigationLinkIndicatorVisibility(.hidden)
                Spacer()
                SessionButtons()
            }
            Spacer()
        }.listRowBackground(Color.clear)
            .padding(.bottom)
        
    }
    
    private func SessionButtons() -> some View {
        HStack {
            ReusedViews.Buttons.RenameButtonAlert(type: .session, oldName: $session.name)
            Button {
                showDateSheet = true
            } label: {
                Label("Ch", systemImage: "clock")
                    .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
                    .labelStyle(.iconOnly)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.glass)
            ReusedViews.Buttons.DeleteButtonConfirmation(type: .session, deleteAction: deleteSession)
        }
    }
    
    private func UpdateDates() {
        session.started = startDate
        session.completed = endDate
        showDateSheet = false
    }
    
    private func Dismiss() {
        showDateSheet = false
    }
    
    private func formatDateRange(start: Date, end: Date?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        guard let end = end else {
            return "Incomplete"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDate(start, inSameDayAs: end) {
            formatter.dateFormat = "h:mm a"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else {
            formatter.dateFormat = "MMM d h:mm a"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
    
    private func GenerateImage(for date: Date) -> Image {
        let dayNumber = Calendar.current.component(.day, from: date)
        let imageName = "\(dayNumber).calendar"
        
        return Image(systemName: imageName)
    }
    
}
