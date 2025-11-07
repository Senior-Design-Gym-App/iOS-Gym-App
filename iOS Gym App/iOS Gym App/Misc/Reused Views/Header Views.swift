import SwiftUI

struct ReusedViews {
    
    struct Labels {
        
        static private func Icon(size: CGFloat, cornerRadius: CGFloat, color: Color) -> some View {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: size, height: size)
        }
        
        static func MediumTextLabel(title: String) -> some View {
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(Constants.labelColor)
                .font(.footnote)
                .frame(width: Constants.mediumIconSize)
        }
        
        static func MediumIconSize(color: Color) -> some View {
            Icon(size: Constants.mediumIconSize, cornerRadius: Constants.cornerRadius, color: color)
        }
        
        static func SmallIconSize(color: Color) -> some View {
            Icon(size: Constants.smallIconSize, cornerRadius: Constants.cornerRadius, color: color)
        }
        
//        static func TinyIconSize(Color: String) -> some View {
//            Icon(size: Constants.tinyIconSIze, cornerRadius: Constants.smallRadius, color: ColorManager.shared.GetColor(key: Color))
//        }
        
        static func LargeIconSize(color: Color) -> some View {
            HStack {
                Spacer()
                Icon(size: Constants.largeIconSize, cornerRadius: Constants.cornerRadius, color: color)
                Spacer()
            }
        }
        
        static func SingleCardTextField(textFieldName: Binding<String>, createdDate: Date, type: WorkoutItemType) -> some View {
            VStack(spacing: 0) {
                TextField("\(type.rawValue) Name", text: textFieldName)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Text("Created \(DateHandler().RelativeTime(from: createdDate))")
                    .foregroundStyle(.secondary)
                    .font(.caption2)
                    .fontWeight(.light)
            }
        }
        
        static func SingleCardTitle(title: String, modified: Date) -> some View {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 0) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    Text("Edited \(DateHandler().RelativeTime(from: modified))")
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
        }
        
        static func TypeListDescription<C: Collection>(name: String, items: C, type: WorkoutItemType) -> some View {
            ListDescription(title: name, subtitle: "\(items.count) \(type.listLabel)\(items.count == 1 ? "" : "s")")
        }
        
        static func HeaderWithArrow(title: String) -> some View {
            HStack(alignment: .top) {
                Header(text: title)
                Spacer()
                Image(systemName: "chevron.forward.circle.fill")
                    .tint(.gray)
            }
        }
        
        static func ListDescription(title: String, subtitle: String) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                Text(subtitle)
                    .font(.callout)
                    .fontWeight(.thin)
            }
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
        
    }
    
}
