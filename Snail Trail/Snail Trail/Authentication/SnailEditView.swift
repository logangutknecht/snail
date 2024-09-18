import SwiftUI

struct SnailEditView: View {
    @ObservedObject var snail: Snail
    @Binding var isPresented: Bool
    @State private var tempName: String
    @State private var tempColor: Color
    
    init(snail: Snail, isPresented: Binding<Bool>) {
        self._snail = ObservedObject(wrappedValue: snail)
        self._isPresented = isPresented
        self._tempName = State(initialValue: snail.name)
        self._tempColor = State(initialValue: snail.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Snail Preview")) {
                    HStack {
                        Spacer()
                        SnailIconView(color: tempColor)
                            .frame(width: 100, height: 100)
                        Spacer()
                    }
                }
                
                Section(header: Text("Snail Name")) {
                    TextField("Name", text: $tempName)
                }
                
                Section(header: Text("Snail Color")) {
                    ColorPicker("Choose a color", selection: $tempColor)
                }
            }
            .navigationTitle("Edit Snail")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    snail.name = tempName
                    snail.color = tempColor
                    isPresented = false
                }
            )
        }
    }
}
