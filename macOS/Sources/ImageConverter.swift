import AppKit
import UniformTypeIdentifiers

enum OutputFormat: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case png = "PNG"
    case tiff = "TIFF"
    case bmp = "BMP"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .png: return "png"
        case .tiff: return "tiff"
        case .bmp: return "bmp"
        }
    }

    var bitmapType: NSBitmapImageRep.FileType {
        switch self {
        case .jpeg: return .jpeg
        case .png: return .png
        case .tiff: return .tiff
        case .bmp: return .bmp
        }
    }
}

enum QualityPreset: String, CaseIterable, Identifiable {
    case high = "Hoej kvalitet (95%)"
    case medium = "Medium (80%)"
    case web = "Web-optimeret (70%)"
    case low = "Komprimeret (50%)"

    var id: String { rawValue }

    var quality: Double {
        switch self {
        case .high: return 0.95
        case .medium: return 0.80
        case .web: return 0.70
        case .low: return 0.50
        }
    }
}

struct ConversionResult: Identifiable {
    let id = UUID()
    let sourceURL: URL
    let outputURL: URL?
    let originalSize: Int64
    let newSize: Int64
    let success: Bool
    let error: String?
    let skipped: Bool

    var savedPercent: Int {
        guard newSize > 0, originalSize > 0 else { return 0 }
        return Int(100.0 - (Double(newSize) / Double(originalSize) * 100.0))
    }
}

@MainActor
class ImageConverter: ObservableObject {
    @Published var outputFormat: OutputFormat = .jpeg
    @Published var qualityPreset: QualityPreset = .high
    @Published var maxWidth: Int = 0
    @Published var maxHeight: Int = 0
    @Published var useOutputFolder: Bool = true
    @Published var outputFolderName: String = "NemJPG_output"
    @Published var backgroundColor: NSColor = .white
    @Published var includeSubfolders: Bool = false
    @Published var isConverting: Bool = false
    @Published var progress: Double = 0
    @Published var results: [ConversionResult] = []
    @Published var droppedFiles: [URL] = []

    static let supportedExtensions: Set<String> = [
        "png", "bmp", "gif", "tiff", "tif", "webp", "heic", "heif",
        "avif", "ico", "jp2", "psd", "raw", "cr2", "cr3", "nef",
        "arw", "dng", "orf", "rw2", "raf", "srw", "pef"
    ]

    var totalConverted: Int { results.filter { $0.success }.count }
    var totalSkipped: Int { results.filter { $0.skipped }.count }
    var totalErrors: Int { results.filter { !$0.success && !$0.skipped }.count }
    var totalSavedBytes: Int64 {
        results.filter { $0.success }.reduce(0) { $0 + ($1.originalSize - $1.newSize) }
    }

    func addFiles(_ urls: [URL]) {
        let imageURLs = urls.flatMap { url -> [URL] in
            if url.hasDirectoryPath {
                return findImages(in: url)
            } else if Self.supportedExtensions.contains(url.pathExtension.lowercased()) {
                return [url]
            }
            return []
        }
        let existing = Set(droppedFiles.map { $0.path })
        let newFiles = imageURLs.filter { !existing.contains($0.path) }
        droppedFiles.append(contentsOf: newFiles)
    }

    func clearFiles() {
        droppedFiles.removeAll()
        results.removeAll()
        progress = 0
    }

    func convert() async {
        guard !droppedFiles.isEmpty else { return }
        isConverting = true
        results.removeAll()
        progress = 0

        let total = droppedFiles.count
        for (index, url) in droppedFiles.enumerated() {
            let result = convertSingleFile(url)
            results.append(result)
            progress = Double(index + 1) / Double(total)
        }

        isConverting = false
    }

    private func findImages(in directory: URL) -> [URL] {
        let fm = FileManager.default
        var options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        if !includeSubfolders {
            options.insert(.skipsSubdirectoryDescendants)
        }
        guard let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: options
        ) else { return [] }

        var images: [URL] = []
        for case let fileURL as URL in enumerator {
            if Self.supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                images.append(fileURL)
            }
        }
        return images.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func convertSingleFile(_ sourceURL: URL) -> ConversionResult {
        let originalSize = (try? FileManager.default.attributesOfItem(atPath: sourceURL.path)[.size] as? Int64) ?? 0

        // Determine output directory
        let outputDir: URL
        if useOutputFolder {
            outputDir = sourceURL.deletingLastPathComponent().appendingPathComponent(outputFolderName)
            try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        } else {
            outputDir = sourceURL.deletingLastPathComponent()
        }

        let outputName = sourceURL.deletingPathExtension().lastPathComponent + "." + outputFormat.fileExtension
        let outputURL = outputDir.appendingPathComponent(outputName)

        // Skip if already exists
        if FileManager.default.fileExists(atPath: outputURL.path) {
            return ConversionResult(
                sourceURL: sourceURL, outputURL: outputURL,
                originalSize: originalSize, newSize: 0,
                success: false, error: nil, skipped: true
            )
        }

        // Skip if source is already the target format
        if sourceURL.pathExtension.lowercased() == outputFormat.fileExtension {
            return ConversionResult(
                sourceURL: sourceURL, outputURL: nil,
                originalSize: originalSize, newSize: 0,
                success: false, error: nil, skipped: true
            )
        }

        guard let image = NSImage(contentsOf: sourceURL) else {
            return ConversionResult(
                sourceURL: sourceURL, outputURL: nil,
                originalSize: originalSize, newSize: 0,
                success: false, error: "Kunne ikke aabne billedet", skipped: false
            )
        }

        // Get image size
        var imageSize = image.size
        if let rep = image.representations.first {
            imageSize = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        }

        // Apply resize if needed
        var targetWidth = Int(imageSize.width)
        var targetHeight = Int(imageSize.height)

        if maxWidth > 0 && targetWidth > maxWidth {
            let ratio = Double(maxWidth) / Double(targetWidth)
            targetWidth = maxWidth
            targetHeight = Int(Double(targetHeight) * ratio)
        }
        if maxHeight > 0 && targetHeight > maxHeight {
            let ratio = Double(maxHeight) / Double(targetHeight)
            targetHeight = maxHeight
            targetWidth = Int(Double(targetWidth) * ratio)
        }

        // Render image on background color
        let targetSize = NSSize(width: targetWidth, height: targetHeight)
        let rendered = NSImage(size: targetSize)
        rendered.lockFocus()
        backgroundColor.setFill()
        NSRect(origin: .zero, size: targetSize).fill()
        image.draw(in: NSRect(origin: .zero, size: targetSize),
                   from: NSRect(origin: .zero, size: imageSize),
                   operation: .sourceOver, fraction: 1.0)
        rendered.unlockFocus()

        guard let tiffData = rendered.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return ConversionResult(
                sourceURL: sourceURL, outputURL: nil,
                originalSize: originalSize, newSize: 0,
                success: false, error: "Kunne ikke behandle billedet", skipped: false
            )
        }

        // Encode
        var properties: [NSBitmapImageRep.PropertyKey: Any] = [:]
        if outputFormat == .jpeg {
            properties[.compressionFactor] = qualityPreset.quality
        }

        guard let outputData = bitmapRep.representation(using: outputFormat.bitmapType, properties: properties) else {
            return ConversionResult(
                sourceURL: sourceURL, outputURL: nil,
                originalSize: originalSize, newSize: 0,
                success: false, error: "Kunne ikke kode billedet", skipped: false
            )
        }

        do {
            try outputData.write(to: outputURL)
            let newSize = Int64(outputData.count)
            return ConversionResult(
                sourceURL: sourceURL, outputURL: outputURL,
                originalSize: originalSize, newSize: newSize,
                success: true, error: nil, skipped: false
            )
        } catch {
            return ConversionResult(
                sourceURL: sourceURL, outputURL: nil,
                originalSize: originalSize, newSize: 0,
                success: false, error: error.localizedDescription, skipped: false
            )
        }
    }
}
