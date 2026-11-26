using System.Collections.ObjectModel;
using System.IO;
using System.Windows;
using System.Windows.Media;
using Microsoft.Win32;

namespace NemJPG;

public partial class MainWindow : Window
{
    private readonly ObservableCollection<ResultRow> _rows = [];
    private readonly Converter _converter = new();

    public MainWindow()
    {
        InitializeComponent();
        ResultsList.ItemsSource = _rows;
    }

    private void OnSelectFiles(object sender, RoutedEventArgs e)
    {
        var dlg = new OpenFileDialog
        {
            Multiselect = true,
            Title = "Vælg billeder til konvertering",
            Filter = "Billedfiler|*.png;*.bmp;*.gif;*.tiff;*.tif;*.webp;*.ico;*.heic;*.heif;*.avif;*.wdp;*.dng;*.cr2;*.nef;*.arw;*.orf;*.rw2;*.raw|Alle filer|*.*"
        };

        if (dlg.ShowDialog() == true)
            ConvertFiles(dlg.FileNames);
    }

    private void OnDragOver(object sender, DragEventArgs e)
    {
        e.Effects = e.Data.GetDataPresent(DataFormats.FileDrop)
            ? DragDropEffects.Copy
            : DragDropEffects.None;
        DropZone.BorderBrush = new SolidColorBrush(Color.FromRgb(94, 92, 230));
        e.Handled = true;
    }

    private void OnDragLeave(object sender, DragEventArgs e)
    {
        DropZone.BorderBrush = new SolidColorBrush(Color.FromRgb(42, 42, 66));
    }

    private void OnDrop(object sender, DragEventArgs e)
    {
        DropZone.BorderBrush = new SolidColorBrush(Color.FromRgb(42, 42, 66));

        if (!e.Data.GetDataPresent(DataFormats.FileDrop)) return;

        var paths = (string[])e.Data.GetData(DataFormats.FileDrop);
        var files = ExpandPaths(paths);
        ConvertFiles(files);
    }

    private static string[] ExpandPaths(string[] paths)
    {
        var files = new List<string>();
        foreach (var p in paths)
        {
            if (Directory.Exists(p))
                files.AddRange(Directory.GetFiles(p, "*", SearchOption.TopDirectoryOnly)
                    .Where(Converter.IsSupported));
            else if (File.Exists(p) && Converter.IsSupported(p))
                files.Add(p);
        }
        return [.. files];
    }

    private void ConvertFiles(IEnumerable<string> paths)
    {
        var fileList = paths.ToList();
        if (fileList.Count == 0) return;

        _rows.Clear();
        ShowResults();

        int ok = 0, skipped = 0, errors = 0;

        foreach (var path in fileList)
        {
            var result = _converter.ConvertToJpg(path, quality: 100);
            var fileName = Path.GetFileName(path);

            if (result.Success)
            {
                ok++;
                _rows.Add(new ResultRow("✓", fileName, result.SizeSummary, "#4ADE80"));
            }
            else if (result.Skipped)
            {
                skipped++;
                _rows.Add(new ResultRow("–", fileName, "findes allerede", "#666"));
            }
            else
            {
                errors++;
                _rows.Add(new ResultRow("✗", fileName, result.Error ?? "fejl", "#F87171"));
            }
        }

        var parts = new List<string>();
        if (ok > 0) parts.Add($"{ok} konverteret");
        if (skipped > 0) parts.Add($"{skipped} sprunget over");
        if (errors > 0) parts.Add($"{errors} fejl");
        StatusText.Text = string.Join(" · ", parts);
    }

    private void ShowResults()
    {
        EmptyState.Visibility = Visibility.Collapsed;
        ResultsPanel.Visibility = Visibility.Visible;
    }

    private void OnConvertMore(object sender, RoutedEventArgs e)
    {
        _rows.Clear();
        EmptyState.Visibility = Visibility.Visible;
        ResultsPanel.Visibility = Visibility.Collapsed;
    }
}

public record ResultRow(string Icon, string FileName, string? Summary, string Color);
