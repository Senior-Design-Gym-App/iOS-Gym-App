import SwiftUI

struct ReusedViews {
    
    static func HeaderCard(fill: Color) -> some View {
        Rectangle()
            .aspectRatio(3.0 / 2.0, contentMode: .fit)
            .foregroundStyle(fill)
    }
    
    static func HeaderTitle(title: String) -> some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
    }
    
    static func HeaderSubtitle(subtitle: String) -> some View {
        Text(subtitle)
        .font(.subheadline)
        .fontWeight(.medium)
        .multilineTextAlignment(.center)
        .foregroundColor(.white)
    }
    
}
