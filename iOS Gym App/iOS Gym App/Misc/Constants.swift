import SwiftUI

struct Constants {
    
    static let cornerRadius: CGFloat = 10
    static let horizontalLabelPaddingh: CGFloat = 5
//    static let cornerRadius: CGFloat = 15.0
    static let leadingContentInset: CGFloat = 26.0
    static let standardPadding: CGFloat = 14.0
    static let landmarkImagePadding: CGFloat = 14.0
    static let safeAreaPadding: CGFloat = 30.0
    static let titleTopPadding: CGFloat = 8.0
    static let titleBottomPadding: CGFloat = -4.0
    
    // MARK: Colors
    
    static let mainAppTheme: Color = .teal
    static let sessionTheme: Color = .indigo
    static let updateTheme: Color = .blue
    static let optionsTheme: Color = .cyan
    static let healthTheme: Color = .pink
    static let calendarTheme: Color = .mint
    
    static func ActivityHeaderView(title: String) -> some View {
        Text(title)
            .font(.title2)
            .bold()
            .padding(.top, titleTopPadding)
            .padding(.bottom, titleBottomPadding)
            .padding(.leading, leadingContentInset)
    }
    
}
