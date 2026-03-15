import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var converter: ImageConverter

    var body: some View {
        Form {
            Section("Output") {
                Picker("Standardformat", selection: $converter.outputFormat) {
                    ForEach(OutputFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }

                if converter.outputFormat == .jpeg {
                    Picker("JPEG-kvalitet", selection: $converter.qualityPreset) {
                        ForEach(QualityPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                }

                Toggle("Gem i undermappe", isOn: $converter.useOutputFolder)
                if converter.useOutputFolder {
                    TextField("Mappenavn", text: $converter.outputFolderName)
                }
            }

            Section("Resize") {
                HStack {
                    Text("Max bredde (px)")
                    TextField("0 = ingen", value: $converter.maxWidth, format: .number)
                        .frame(width: 100)
                }
                HStack {
                    Text("Max hoejde (px)")
                    TextField("0 = ingen", value: $converter.maxHeight, format: .number)
                        .frame(width: 100)
                }
                Text("0 = ingen resize. Aspect ratio bevares altid.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Transparens") {
                HStack {
                    Text("Baggrundsfarve")
                    Spacer()
                    ColorPicker("", selection: Binding(
                        get: { Color(nsColor: converter.backgroundColor) },
                        set: { converter.backgroundColor = NSColor($0) }
                    ))
                }
            }

            Section("Avanceret") {
                Toggle("Inkluder undermapper", isOn: $converter.includeSubfolders)
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 420)
        .padding()
    }
}
