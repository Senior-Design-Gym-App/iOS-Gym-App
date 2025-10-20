import SwiftUI

struct CustomLabelView: View {
    
    let text: String
    let image: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: image)
            Text(text)
        }
    }
    
}
