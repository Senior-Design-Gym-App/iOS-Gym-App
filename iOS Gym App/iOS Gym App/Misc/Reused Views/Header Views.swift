import SwiftUI

struct ReusedViews {
    
    static func HeaderTitle(title: String) -> some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
    }
    
    static func HeaderSubtitle(subtitle: String) -> some View {
        Text(subtitle)
        .font(.subheadline)
        .fontWeight(.medium)
        .multilineTextAlignment(.center)
    }
    
    static func HorizontalHeader(text: String, showNavigation: Bool) -> some View {
        HStack(spacing: 5) {
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Constants.labelColor)
            if showNavigation {
                Image(systemName: "chevron.right")
                    .fontWeight(.medium)
                    .tint(Constants.labelColor.tertiary)
            }
            Spacer()
        }
    }
    
    static func Description(topText: String, bottomText: String) -> some View {
        VStack(alignment: .leading) {
            Text(topText)
                .foregroundStyle(Constants.labelColor)
                .font(.callout)
            Text(bottomText)
                .foregroundStyle(Constants.labelColor)
                .font(.caption)
                .fontWeight(.thin)
        }
    }
    
}
