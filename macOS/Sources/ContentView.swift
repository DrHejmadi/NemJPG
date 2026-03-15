import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var converter: ImageConverter
    @State private var isDragging = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar

            // Main content
            if converter.droppedFiles.isEmpty {
                dropZone
            } else if converter.isConverting || !converter.results.isEmpty {
                resultsView
            } else {
                fileListView
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.title2)
                .foregroundStyle(.blue)

            Text("NemJPG")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            // Format picker
            Picker("Format", selection: $converter.outputFormat) {
                ForEach(OutputFormat.allCases) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 240)

            // Quality picker
            if converter.outputFormat == .jpeg {
                Picker("", selection: $converter.qualityPreset) {
                    ForEach(QualityPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .frame(width: 180)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Drop Zone

    private var dropZone: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isDragging ? Color.blue : Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 3, dash: [12, 8])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isDragging ? Color.blue.opacity(0.05) : Color.clear)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 16) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(isDragging ? .blue : .secondary)
                        .scaleEffect(isDragging ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isDragging)

                    Text("Traek billeder eller mapper hertil")
                        .font(.title3)
                        .fontWeight(.medium)

                    Text("PNG, BMP, GIF, TIFF, WebP, HEIC, RAW og mange flere")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Button(action: openFilePicker) {
                        Label("Vaelg filer...", systemImage: "folder")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(30)
            .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                handleDrop(providers)
                return true
            }

            // Options row
            HStack(spacing: 20) {
                Toggle("Gem i undermappe", isOn: $converter.useOutputFolder)
                Toggle("Inkluder undermapper", isOn: $converter.includeSubfolders)
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 16)
        }
    }

    // MARK: - File List

    private var fileListView: some View {
        VStack(spacing: 0) {
            // Info bar
            HStack {
                Image(systemName: "photo.stack")
                Text("\(converter.droppedFiles.count) billede(r) klar til konvertering")
                    .fontWeight(.medium)
                Spacer()

                Button("Ryd") {
                    converter.clearFiles()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button(action: openFilePicker) {
                    Label("Tilfoej flere", systemImage: "plus")
                }

                Button(action: {
                    Task { await converter.convert() }
                }) {
                    Label("Konverter til \(converter.outputFormat.rawValue)", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)

            // File list
            List {
                ForEach(converter.droppedFiles, id: \.path) { url in
                    HStack {
                        Image(systemName: "photo")
                            .foregroundStyle(.blue)
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                        Text(url.pathExtension.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                handleDrop(providers)
                return true
            }

            // Options
            HStack(spacing: 20) {
                Toggle("Gem i undermappe", isOn: $converter.useOutputFolder)
                Toggle("Inkluder undermapper", isOn: $converter.includeSubfolders)

                if converter.maxWidth > 0 {
                    Text("Max: \(converter.maxWidth)px")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(spacing: 0) {
            // Progress
            if converter.isConverting {
                VStack(spacing: 8) {
                    ProgressView(value: converter.progress)
                        .progressViewStyle(.linear)
                    Text("Konverterer... \(Int(converter.progress * 100))%")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }

            // Summary bar
            if !converter.results.isEmpty {
                HStack(spacing: 24) {
                    Label("\(converter.totalConverted) konverteret", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    if converter.totalSkipped > 0 {
                        Label("\(converter.totalSkipped) sprunget over", systemImage: "arrow.right.circle.fill")
                            .foregroundStyle(.orange)
                    }
                    if converter.totalErrors > 0 {
                        Label("\(converter.totalErrors) fejl", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    if converter.totalSavedBytes > 0 {
                        Text("Sparet: \(formatBytes(converter.totalSavedBytes))")
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }

                    Button("Ny konvertering") {
                        converter.clearFiles()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }

            // Results list
            List {
                ForEach(converter.results) { result in
                    HStack {
                        if result.success {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else if result.skipped {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundStyle(.orange)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }

                        Text(result.sourceURL.lastPathComponent)
                            .lineLimit(1)

                        Spacer()

                        if result.success {
                            Text("\(formatBytes(result.originalSize)) → \(formatBytes(result.newSize))")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text("-\(result.savedPercent)%")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        } else if result.skipped {
                            Text("Sprunget over")
                                .font(.callout)
                                .foregroundStyle(.orange)
                        } else {
                            Text(result.error ?? "Ukendt fejl")
                                .font(.callout)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowedContentTypes = [.image]
        panel.message = "Vaelg billeder eller mapper der skal konverteres"

        if panel.runModal() == .OK {
            converter.addFiles(panel.urls)
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, _ in
                guard let data = data as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                DispatchQueue.main.async {
                    converter.addFiles([url])
                }
            }
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
