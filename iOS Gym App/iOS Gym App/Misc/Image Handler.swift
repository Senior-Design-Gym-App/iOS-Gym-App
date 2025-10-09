import SwiftUI
import CropViewController
import CloudKit
import TOCropViewController

struct ProfilePictureCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var visible: Bool
    @Binding var didFinish: Bool

    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: ProfilePictureCropper
        
        init(_ parent: ProfilePictureCropper) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            withAnimation {
                parent.visible = false
            }
            parent.didFinish = false
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            withAnimation {
                parent.visible = false
            }
            parent.image = image
            parent.didFinish = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let img = self.image!
        let vc = CropViewController(croppingStyle: .circular, image: img)
        vc.aspectRatioLockEnabled = true
        vc.rotateButtonsHidden = true
        vc.aspectRatioPickerButtonHidden = true
        vc.resetButtonHidden = true
        vc.doneButtonColor = .systemBlue
        vc.cancelButtonColor = .systemRed
        vc.delegate = context.coordinator
        return vc
    }
}

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = CGSize(width: size.width * min(widthRatio, heightRatio),
                             height: size.height * min(widthRatio, heightRatio))
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

struct WorkoutPlanImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var visible: Bool
    
    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: WorkoutPlanImageCropper
        
        init(_ parent: WorkoutPlanImageCropper) {
            self.parent = parent
        }
        
        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            withAnimation {
                parent.visible = false
            }
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            withAnimation {
                parent.visible = false
            }
            parent.image = image
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let img = self.image!
        let vc = CropViewController(croppingStyle: .default, image: img)
//        vc.customAspectRatio = CGSize(width: 1, height: 1)    // this prob changed
        vc.aspectRatioLockEnabled = true
        vc.rotateButtonsHidden = true
        vc.aspectRatioPickerButtonHidden = true
        vc.resetButtonHidden = true
        vc.doneButtonColor = .systemBlue
        vc.cancelButtonColor = .systemRed
        vc.delegate = context.coordinator
        return vc
    }
}

func CropImageToCircle(image: UIImage) -> UIImage? {
    let shortestSide = min(image.size.width, image.size.height)
    let squareSize = CGSize(width: shortestSide, height: shortestSide)

    let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: squareSize))

    UIGraphicsBeginImageContextWithOptions(squareSize, false, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    context.addPath(circlePath.cgPath)
    context.clip()

    let drawRect = CGRect(
        x: (shortestSide - image.size.width) / 2,
        y: (shortestSide - image.size.height) / 2,
        width: image.size.width,
        height: image.size.height
    )
    image.draw(in: drawRect)

    let circularImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return circularImage
}

//struct ProfilePicture: View {
//    
//    let pfplink: PublicUser
//    let size: CGFloat
//    
//    var body: some View {
//        Group {
//            if let fileURL = pfplink.profileImage?.fileURL {
//                Image(uiImage: UIImage(contentsOfFile: fileURL.path) ?? UIImage())
//                    .resizable()
//                    .clipShape(.circle)
//            } else {
//                Image(systemName: "person.crop.circle")
//                    .resizable()
//                    .tint(Color.teal)
//            }
//        }
//        .scaledToFit()
//        .frame(width: size, height: size)
//    }
//    
//}

struct OnlineWorkoutImageView: View {
    
    let image: CKAsset?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let image, let fileURL = image.fileURL {
                Image(uiImage: UIImage(contentsOfFile: fileURL.path) ?? UIImage())
                    .resizable()
                    .clipShape(.rect(cornerRadius: 5))
            } else {
                Image(systemName: "square")
                    .resizable()
                    .opacity(0)
            }
        }
        .scaledToFit()
        .frame(width: size, height: size)
    }
    
}
