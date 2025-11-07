import UIKit
import SwiftUI

class EquipmentPicker: UIButton {
    
    var selectedEquipment: WorkoutEquipment? {
        didSet {
            updateMenu()
        }
    }
    
    var onSelectionChanged: ((WorkoutEquipment?) -> Void)?
    
    init(selectedEquipment: WorkoutEquipment? = nil) {
        self.selectedEquipment = selectedEquipment
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        showsMenuAsPrimaryAction = true
        updateAppearance()
        updateMenu()
    }
    
    private func updateAppearance() {
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "scale.3d")
        config.attributedTitle = AttributedString(
            "Equipment",
            attributes: AttributeContainer([
                .font: UIFont.boldSystemFont(ofSize: 17)
            ])
        )
        
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        configuration = config
    }
    
    private func updateMenu() {
        let menuItems: [UIAction] = [
            UIAction(
                title: "No Equipment",
                image: UIImage(systemName: "xmark.circle"),
                state: selectedEquipment == nil ? .on : .off
            ) { [weak self] _ in
                self?.selectedEquipment = nil
                self?.onSelectionChanged?(nil)
            }
        ] + WorkoutEquipment.allCases.map { equipment in
            UIAction(
                title: equipment.rawValue,
                image: UIImage(systemName: equipment.imageName),
                state: self.selectedEquipment == equipment ? .on : .off
            ) { [weak self] _ in
                self?.selectedEquipment = equipment
                self?.onSelectionChanged?(equipment)
            }
        }
        
        menu = UIMenu(title: "Equipment", children: menuItems)
    }
}

struct MuscleMenuButton: UIViewRepresentable {
    @Binding var selectedMuscle: Muscle?
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.showsMenuAsPrimaryAction = true
        button.menu = context.coordinator.createMenu()
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "scope")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = config
        
        context.coordinator.updateButtonTitle(button)
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.selectedMuscle = selectedMuscle
        uiView.menu = context.coordinator.createMenu()
        context.coordinator.updateButtonTitle(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedMuscle: selectedMuscle) { [self] newValue in
            self.selectedMuscle = newValue
        }
    }
    
    // MARK: - Coordinator
    class Coordinator {
        var selectedMuscle: Muscle?
        var onSelectionChange: (Muscle?) -> Void
        
        init(selectedMuscle: Muscle?, onSelectionChange: @escaping (Muscle?) -> Void) {
            self.selectedMuscle = selectedMuscle
            self.onSelectionChange = onSelectionChange
        }
        
        func updateButtonTitle(_ button: UIButton) {
            var config = button.configuration
            let title = selectedMuscle?.rawValue.capitalized ?? "Muscle"
            config?.attributedTitle = AttributedString(
                title,
                attributes: AttributeContainer([
                    .font: UIFont.boldSystemFont(ofSize: 17)
                ])
            )
            button.configuration = config
        }
        
        func createMenu() -> UIMenu {
            let noneAction = UIAction(
                title: "None",
                state: selectedMuscle == nil ? .on : .off
            ) { [weak self] _ in
                self?.onSelectionChange(nil)
            }
            
            let generalMuscles = Muscle.allCases.filter { $0.general == .general }
            let generalActions = generalMuscles.map { muscle in
                UIAction(
                    title: muscle.rawValue.capitalized,
                    state: selectedMuscle == muscle ? .on : .off
                ) { [weak self] _ in
                    self?.onSelectionChange(muscle)
                }
            }
            
            let groupsMenu = UIMenu(
                title: "Groups",
                options: .displayInline,
                children: generalActions
            )
            
            let generalSection = UIMenu(
                title: "General Options",
                options: .displayInline,
                children: [noneAction, groupsMenu]
            )
            
            let chestMenu = createMuscleSubmenu(
                title: "Chest",
                general: .chest
            )
            
            let backMenu = createMuscleSubmenu(
                title: "Back",
                general: .back
            )
            
            let legsMenu = createMuscleSubmenu(
                title: "Legs",
                general: .legs
            )
            
            let shouldersMenu = createMuscleSubmenu(
                title: "Shoulders",
                general: .shoulders
            )
            
            let bicepsMenu = createMuscleSubmenu(
                title: "Biceps",
                general: .biceps
            )
            
            let tricepsMenu = createMuscleSubmenu(
                title: "Triceps",
                general: .triceps
            )
            
            let coreMenu = createMuscleSubmenu(
                title: "Core",
                general: .core
            )
            
            let specificSection = UIMenu(
                title: "Specific Options",
                options: .displayInline,
                children: [chestMenu, backMenu, legsMenu, shouldersMenu, bicepsMenu, tricepsMenu, coreMenu]
            )
            
            return UIMenu(
                title: "",
                children: [generalSection, specificSection]
            )
        }
        
        private func createMuscleSubmenu(title: String, general: MuscleGroup) -> UIMenu {
            let muscles = Muscle.allCases.filter { $0.general == general }
            let actions = muscles.map { muscle in
                UIAction(
                    title: muscle.rawValue.capitalized,
                    state: selectedMuscle == muscle ? .on : .off
                ) { [weak self] _ in
                    self?.onSelectionChange(muscle)
                }
            }
            
            return UIMenu(
                title: title,
                children: actions
            )
        }
    }
}
