import SwiftUI

struct CustomLabelView: View {
    
    let text: String
    let image: String
    
    var body: some View {
        Label(text, systemImage: image)
//        HStack(spacing: Constants.customLabelPadding) {
//            Image(systemName: image)
//            Text(text)
//        }
//        .foregroundStyle(.white)
    }
    
}
