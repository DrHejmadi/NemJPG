import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var converter: ImageConverter

    var body: some View {
        Form {
            Section(String(localized: "Output")) {
                Picker(String(localized: "Default format"), selection: $converter.outputFormat) {
                    ForEach(OutputFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }

                if converter.outputFormat == .jpeg {
                    Picker(String(localized: "JPEG quality"), selection: $converter.qualityPreset) {
                        ForEach(QualityPreset.allCases) { preset in
                            Text(preset.displayName).tag(preset)
                        }
                    }
                }

                Toggle(String(localized: "Save in subfolder"), isOn: $converter.useOutputFolder)
                if converter.useOutputFolder {
                    TextField(String(localized: "Folder name"), text: $converter.outputFolderName)
                }
            }

            Section(String(localized: "Resize")) {
                HStack {
                    Text("Max width (px)", comment: "Resize setting label")
                    TextField(String(localized: "0 = none"), value: $converter.maxWidth, format: .number)
                        .frame(width: 100)
                }
                HStack {
                    Text("Max height (px)", comment: "Resize setting label")
                    TextField(String(localized: "0 = none"), value: $converter.maxHeight, format: .number)
                        .frame(width: 100)
                }
                Text("0 = no resize. Aspect ratio is always preserved.", comment: "Resize help text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(String(localized: "Transparency")) {
                HStack {
                    Text("Background color", comment: "Transparency setting label")
                    Spacer()
                    ColorPicker("", selection: Binding(
                        get: { Color(nsColor: converter.backgroundColor) },
                        set: { converter.backgroundColor = NSColor($0) }
                    ))
                }
            }

            Section(String(localized: "Advanced")) {
                Toggle(String(localized: "Include subfolders"), isOn: $converter.includeSubfolders)
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 420)
        .padding()
    }
}
