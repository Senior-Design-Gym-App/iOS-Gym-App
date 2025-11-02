import SwiftUI
import UIKit

struct SessionTabUIKitView: UIViewRepresentable {
    
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @Binding var currentSession: WorkoutSession?
    
    func makeUIView(context: Context) -> SessionTabUIView {
        let view = SessionTabUIView()
        view.onTap = { session in
            currentSession = session
        }
        return view
    }
    
    func updateUIView(_ uiView: SessionTabUIView, context: Context) {
        uiView.updateContent(with: sessionManager.currentWorkout, session: sessionManager.session)
    }
}

// MARK: - UIKit View
class SessionTabUIView: UIView {
    
    // MARK: - Properties
    var onTap: ((WorkoutSession) -> Void)?
    private var currentData: SessionData?
    private var session: WorkoutSession?
    
    private lazy var contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private lazy var equipmentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(Constants.mainAppTheme)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var workoutNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(Constants.labelColor)
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var setProgressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(Constants.labelColor)
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var endLabel: UILabel = {
        let label = UILabel()
        label.text = "End"
        label.textColor = UIColor(Constants.labelColor)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(contentButton)
        contentButton.addSubview(containerStack)
        
        textStack.addArrangedSubview(workoutNameLabel)
        textStack.addArrangedSubview(setProgressLabel)
        
        containerStack.addArrangedSubview(equipmentImageView)
        containerStack.addArrangedSubview(textStack)
        containerStack.addArrangedSubview(UIView()) // Spacer
        containerStack.addArrangedSubview(endLabel)
        
        NSLayoutConstraint.activate([
            contentButton.topAnchor.constraint(equalTo: topAnchor),
            contentButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerStack.topAnchor.constraint(equalTo: contentButton.topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: contentButton.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: contentButton.trailingAnchor, constant: -16),
            containerStack.bottomAnchor.constraint(equalTo: contentButton.bottomAnchor),
            
            equipmentImageView.widthAnchor.constraint(equalToConstant: 24),
            equipmentImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Public Methods
    func updateContent(with currentExercise: SessionData?, session: WorkoutSession?) {
        self.currentData = currentExercise
        self.session = session
        
        // Always show if there's a session
        isHidden = (session == nil)
        
        guard let currentWorkout = currentData else {
            // Show placeholder or last known state
            return
        }
        
        let imageName = currentWorkout.exercise.workoutEquipment?.imageName ?? Constants.defaultEquipmentIcon
        equipmentImageView.image = UIImage(systemName: imageName)
        
        workoutNameLabel.text = currentExercise?.exercise.name
        
        let currentSet = currentWorkout.entry.weight.count
        let totalSets = currentWorkout.exercise.weights.count
        setProgressLabel.text = "Set \(currentSet) of \(totalSets)"
    }
    
    // MARK: - Actions
    @objc private func handleButtonTap() {
        
        guard let session = session else {
            print("No session available to present")
            return
        }
        
        onTap?(session)
    }
}
