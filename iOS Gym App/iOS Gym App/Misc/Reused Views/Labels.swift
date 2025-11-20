import SwiftUI

struct ReusedViews {
    
    struct Labels {
        
        static private func Icon(size: CGFloat, cornerRadius: CGFloat, color: Color) -> some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: size, height: size)
        }
        
        static func MediumIconSize(color: Color) -> some View {
            Icon(size: Constants.mediumIconSize, cornerRadius: Constants.cornerRadius, color: color)
        }
        
        static func SmallIconSize(color: Color) -> some View {
            Icon(size: Constants.smallIconSize, cornerRadius: Constants.cornerRadius, color: color)
        }
        
        static func SingleCardTitle(title: String, modified: Date) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Edited \(DateHandler().RelativeTime(from: modified))")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .fontWeight(.light)
            }
        }
        
        static func TypeListDescription<C: Collection>(name: String, items: C, type: WorkoutItemType, extend: Bool) -> some View {
            ListDescription(title: name, subtitle: "\(items.count) \(type.listLabel)\(items.count == 1 ? "" : "s")", extend: extend)
        }
        
        static func HeaderWithArrow(title: String) -> some View {
            HStack(alignment: .top) {
                Header(text: title)
                Spacer()
                Image(systemName: "chevron.forward.circle.fill")
                    .tint(.gray)
            }
        }
        
        static func ListDescription(title: String, subtitle: String, extend: Bool) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: extend ? .infinity : Constants.mediumIconSize, alignment: .leading)
        }
        
        static func Subheader(title: String) -> some View {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        static func Header(text: String) -> some View {
            Text(text)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Constants.labelColor)
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
        
        static func NavigationHeader(text: String) -> some View {
            HStack(spacing: 5) {
                Text(text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Constants.labelColor)
                Image(systemName: "chevron.right")
                    .fontWeight(.medium)
                    .tint(Constants.labelColor.tertiary)
                Spacer()
            }
        }
        
    }
    
}
