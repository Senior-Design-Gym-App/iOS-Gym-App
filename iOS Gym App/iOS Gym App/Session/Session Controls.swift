import SwiftUI

struct SessionSetControlView: View {
    
    let sessionName: String
    let endAction: () -> Void
    let deleteAction: () -> Void
    let sessionManager: SessionManager
    
    @AppStorage("weightChangeType") private var weightChangeType: WeightChangeType = .ten
    @AppStorage("timerType") private var timerType: TimerType = .liveActivities
    
    var body: some View {
        @Bindable var sessionManager = sessionManager
        Divider()
            .padding(.top)
        StepControl(reps: $sessionManager.reps, weight: $sessionManager.weight)
        BottomControls()
    }
    
    private func StepControl(reps: Binding<Int>, weight: Binding<Double>) -> some View {
        VStack {
            Stepper("\(reps.wrappedValue) Rep\(reps.wrappedValue == 1 ? "" : "s")", value: reps)
            Stepper(value: weight, step: weightChangeType.weightChange) {
                Text("\(weight.wrappedValue, specifier: "%.1f") lbs")
            }
        }
    }
    
    private func WeightChangeSelector() -> some View {
        Picker("Weight Change Type", selection: $weightChangeType) {
            ForEach(WeightChangeType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
    
    private func BottomControls() -> some View {
        HStack {
            GroupBox {
                Menu {
                    Section {
                        Button(role: .confirm) {
                            endAction()
                        } label: {
                            Label("End", systemImage: "stop")
                                .frame(idealWidth: .infinity ,maxWidth: .infinity)
                        }
                        Button(role: .destructive) {
                            deleteAction()
                        } label: {
                            Label("Discard", systemImage: "trash")
                                .frame(idealWidth: .infinity ,maxWidth: .infinity)
                        }
                    } header: {
                        Text(sessionName)
                    }
                } label: {
                    Label("Options", systemImage: "list.bullet.circle")
                        .labelStyle(.iconOnly)
                }
            }.clipShape(.circle)
            Spacer()
            GroupBox {
                Menu {
                    Picker("Timer Type", selection: $timerType) {
                        ForEach(TimerType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    WeightChangeSelector()
                } label: {
                    Label("Settings", systemImage: "gearshape.circle")
                        .labelStyle(.iconOnly)
                }
            }.clipShape(.circle)
        }.frame(idealWidth: .infinity ,maxWidth: .infinity)
    }
    
}
