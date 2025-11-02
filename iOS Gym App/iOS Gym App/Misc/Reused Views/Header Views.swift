import SwiftUI

struct ReusedViews {
    
    struct Labels {
        
        static func MediumTextLabel(title: String) -> some View {
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(Constants.labelColor)
                .font(.footnote)
                .frame(width: Constants.mediumIconSize)
        }
        
        static func MediumIconSize(key: String) -> some View {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(ColorManager.shared.GetColor(key: key))
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: Constants.mediumIconSize, height: Constants.mediumIconSize)
        }
        
        static func SmallIconSize(key: String) -> some View {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(ColorManager.shared.GetColor(key: key))
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: Constants.smallIconSize, height: Constants.smallIconSize)
        }
        
        static func TinyIconSize(key: String) -> some View {
            RoundedRectangle(cornerRadius: Constants.smallRadius)
                .fill(ColorManager.shared.GetColor(key: key))
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: Constants.tinyIconSIze, height: Constants.tinyIconSIze)
        }
        
        static func LargeIconSize(key: String) -> some View {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(ColorManager.shared.GetColor(key: key))
                    .frame(width: Constants.largeIconSize, height: Constants.largeIconSize)
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
        
        static func ListDescription<C: Collection>(name: String, items: C, type: WorkoutItemType) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                Text("\(items.count) \(type.listLabel)\(items.count == 1 ? "" : "s")")
                    .font(.callout)
                    .fontWeight(.thin)
            }
        }
        
        static func HeaderWithArrow(title: String) -> some View {
            HStack(alignment: .top) {
                Header(text: title)
                Spacer()
                Image(systemName: "chevron.forward.circle.fill")
                    .tint(.gray)
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
