using System.IO;
using System.Windows;

namespace NemJPG;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        // Context menu mode: NemJPG.exe -convert "path\to\file.ext"
        if (e.Args.Length >= 2 && e.Args[0] == "-convert")
        {
            var filePath = e.Args[1];
            if (File.Exists(filePath))
            {
                var converter = new Converter();
                var result = converter.ConvertToJpg(filePath, quality: 100);

                if (!result.Success && !result.Skipped)
                    MessageBox.Show($"Kunne ikke konvertere:\n{result.Error}",
                        "NemJPG", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            Shutdown();
            return;
        }

        // Normal launch: show main window
        var window = new MainWindow();
        window.Show();
    }
}
