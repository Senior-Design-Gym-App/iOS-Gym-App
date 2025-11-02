import SwiftUI

struct SessionSetControlView: View {
    
    let endAction: () -> Void
    let deleteAction: () -> Void
    let sessionManager: SessionManager
    
    @State private var lockControls: Bool = true
    @AppStorage("weightChangeType") private var weightChangeType: WeightChangeType = .ten
    
    var body: some View {
        @Bindable var sessionManager = sessionManager
        Divider()
        StepControl(reps: $sessionManager.reps, weight: $sessionManager.weight)
        WeightChangeSelector()
        HStack {
            GroupBox {
                LockButton()
            }.clipShape(.capsule)
            GroupBox {
                Button(role: .confirm) {
                    endAction()
                } label: {
                    Label("End", systemImage: "stop")
                        .frame(idealWidth: .infinity ,maxWidth: .infinity)
                }.disabled(lockControls)
            }.clipShape(.capsule)
            GroupBox {
                Button {
                    deleteAction()
                } label: {
                    Label("Discard", systemImage: "trash")
                        .frame(idealWidth: .infinity ,maxWidth: .infinity)
                }.disabled(lockControls)
            }.clipShape(.capsule)
        }.frame(idealWidth: .infinity ,maxWidth: .infinity)
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
        }.pickerStyle(.segmented)
    }
    
    private func LockButton() -> some View {
        Button {
            lockControls.toggle()
        } label: {
            Label("Lock Controls", systemImage: lockControls ? "lock.fill" : "lock.slash.fill")
                .labelStyle(.iconOnly)
                .contentTransition(.symbolEffect(.replace))
        }
    }
    
}
