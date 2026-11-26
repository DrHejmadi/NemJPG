using System.IO;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace NemJPG;

public class Converter
{
    private static readonly HashSet<string> SupportedExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".png", ".bmp", ".gif", ".tiff", ".tif", ".webp",
        ".ico", ".heic", ".heif", ".avif", ".wdp", ".hdp",
        ".dng", ".cr2", ".nef", ".arw", ".orf", ".rw2", ".raw"
    };

    public static bool IsSupported(string path) =>
        SupportedExtensions.Contains(Path.GetExtension(path));

    public ConversionResult ConvertToJpg(string sourcePath, int quality = 100)
    {
        var source = new FileInfo(sourcePath);
        if (!source.Exists)
            return ConversionResult.Fail("Filen findes ikke");

        if (!SupportedExtensions.Contains(source.Extension))
            return ConversionResult.Fail("Formatet understøttes ikke");

        var baseName = Path.GetFileNameWithoutExtension(source.Name);
        var outPath = Path.Combine(source.DirectoryName!, $"{baseName}.jpg");

        if (File.Exists(outPath))
            return ConversionResult.Skip(outPath);

        try
        {
            BitmapFrame frame;
            using (var stream = File.OpenRead(sourcePath))
            {
                var decoder = BitmapDecoder.Create(
                    stream,
                    BitmapCreateOptions.PreservePixelFormat,
                    BitmapCacheOption.OnLoad);
                frame = decoder.Frames[0];
            }

            var dv = new DrawingVisual();
            using (var dc = dv.RenderOpen())
            {
                var rect = new System.Windows.Rect(0, 0, frame.PixelWidth, frame.PixelHeight);
                dc.DrawRectangle(Brushes.White, null, rect);
                dc.DrawImage(frame, rect);
            }

            var rtb = new RenderTargetBitmap(
                frame.PixelWidth, frame.PixelHeight, 96, 96, PixelFormats.Pbgra32);
            rtb.Render(dv);

            var encoder = new JpegBitmapEncoder { QualityLevel = quality };
            encoder.Frames.Add(BitmapFrame.Create(rtb));

            using var outStream = File.Create(outPath);
            encoder.Save(outStream);

            return ConversionResult.Ok(sourcePath, outPath, source.Length, new FileInfo(outPath).Length);
        }
        catch (Exception ex)
        {
            return ConversionResult.Fail(ex.Message);
        }
    }
}

public record ConversionResult(
    bool Success,
    bool Skipped,
    string? Error,
    string? SourcePath,
    string? OutputPath,
    long OriginalSize,
    long NewSize)
{
    public static ConversionResult Ok(string src, string out_, long origSize, long newSize) =>
        new(true, false, null, src, out_, origSize, newSize);

    public static ConversionResult Skip(string out_) =>
        new(false, true, "Filen eksisterer allerede", null, out_, 0, 0);

    public static ConversionResult Fail(string error) =>
        new(false, false, error, null, null, 0, 0);

    public string SizeSummary =>
        OriginalSize > 0
            ? $"{FormatSize(OriginalSize)} → {FormatSize(NewSize)} ({Saving}% sparet)"
            : string.Empty;

    public int Saving =>
        OriginalSize > 0 ? (int)(100.0 - (double)NewSize / OriginalSize * 100.0) : 0;

    private static string FormatSize(long bytes) => bytes switch
    {
        >= 1_048_576 => $"{bytes / 1_048_576.0:N2} MB",
        >= 1024 => $"{bytes / 1024.0:N1} KB",
        _ => $"{bytes} B"
    };
}
