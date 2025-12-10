import SwiftUI

struct ReusedViews {
    
    struct Labels {
        
        static private func Icon(size: CGFloat, cornerRadius: CGFloat, color: Color) -> some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: size, height: size)
        }
        
        static func ListIcon(color: Color) -> some View {
            Image(systemName: "square.fill")
                .foregroundStyle(color)
        }
        
        static func MediumIconSize(color: Color) -> some View {
            Icon(size: Constants.mediumIconSize, cornerRadius: Constants.cornerRadius, color: color)
        }
        
        static func SmallIconSize(color: Color) -> some View {
            Icon(size: Constants.smallIconSize, cornerRadius: Constants.cornerRadius, color: color)
        }
        
        static func LargeIconSize(color: Color) -> some View {
            Icon(size: Constants.largeIconSize, cornerRadius: Constants.cornerRadius, color: color)
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
        
        static func TypeListDescription<C: Collection>(name: String, items: C, type: WorkoutItemType) -> some View {
            ListDescription(title: name, subtitle: "\(items.count) \(type.listLabel)\(items.count == 1 ? "" : "s")")
        }
        
        static func ListDescription(title: String, subtitle: String) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: Constants.mediumIconSize, alignment: .leading)
        }
        
        static func Header(text: String) -> some View {
            Text(text)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Constants.labelColor)
        }
        
        static func NavigationHeader(text: String) -> some View {
            HStack(spacing: 5) {
                Text(text)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Constants.labelColor)
                Image(systemName: "chevron.right")
                    .fontWeight(.medium)
                    .tint(Constants.labelColor.tertiary)
                Spacer()
            }
        }
        
    }
    
}
