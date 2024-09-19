//
//  ProfileEditView.swift
//  Snail Trail
//
//  Created by Logan Gutknecht on 9/19/24.
//

import SwiftUI

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String
    @State private var bio: String
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    
    init(profile: Binding<UserProfile>) {
        self._profile = profile
        _username = State(initialValue: profile.wrappedValue.username)
        _bio = State(initialValue: profile.wrappedValue.bio)
        if let imageData = profile.wrappedValue.profilePicture {
            _image = State(initialValue: UIImage(data: imageData))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    Button("Choose Picture") {
                        showingImagePicker = true
                    }
                }
                
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                }
                
                Section(header: Text("Bio")) {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            profile.username = username
            profile.bio = bio
            if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
                profile.profilePicture = imageData
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
