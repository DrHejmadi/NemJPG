using System;
using System.Diagnostics;
using System.IO;
using Microsoft.Win32;

namespace NemJPG
{
    class Program
    {
        static int Main(string[] args)
        {
            string appDir = AppDomain.CurrentDomain.BaseDirectory;
            string scriptPath = Path.Combine(appDir, "nemjpg.ps1");

            // If no arguments, register context menu and show confirmation
            if (args.Length == 0)
            {
                return Install(appDir, scriptPath);
            }

            // Parse arguments: -Action <action> -Path <path>
            string action = null;
            string path = null;

            for (int i = 0; i < args.Length; i++)
            {
                if (args[i].Equals("-Action", StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length)
                {
                    action = args[++i];
                }
                else if (args[i].Equals("-Path", StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length)
                {
                    path = args[++i];
                }
            }

            if (action != null && action.Equals("uninstall", StringComparison.OrdinalIgnoreCase))
            {
                return Uninstall();
            }

            if (string.IsNullOrEmpty(action) || string.IsNullOrEmpty(path))
            {
                Console.WriteLine("Usage: NemJPG.exe -Action <action> -Path <path>");
                return 1;
            }

            // Launch PowerShell with the script
            var psArgs = string.Format(
                "-NoProfile -NoLogo -ExecutionPolicy Bypass -File \"{0}\" -Action {1} -Path \"{2}\"",
                scriptPath, action, path);

            var startInfo = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = psArgs,
                UseShellExecute = true,
                WorkingDirectory = Path.GetDirectoryName(path)
            };

            var process = Process.Start(startInfo);
            process.WaitForExit();
            return process.ExitCode;
        }

        static int Install(string appDir, string scriptPath)
        {
            try
            {
                // Determine install location: copy script to %LOCALAPPDATA%\NemJPG
                string installDir = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "NemJPG");

                Directory.CreateDirectory(installDir);

                string installedScript = Path.Combine(installDir, "nemjpg.ps1");
                string installedIni = Path.Combine(installDir, "nemjpg.ini");

                // Copy PowerShell script
                if (File.Exists(scriptPath))
                {
                    File.Copy(scriptPath, installedScript, true);
                }
                else
                {
                    Console.WriteLine("FEJL: nemjpg.ps1 ikke fundet i: " + appDir);
                    Console.ReadKey();
                    return 1;
                }

                // Copy ini if exists
                string iniPath = Path.Combine(appDir, "nemjpg.ini");
                if (File.Exists(iniPath))
                {
                    File.Copy(iniPath, installedIni, true);
                }

                // Build the PowerShell command prefix
                string psCmd = "powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -WindowStyle Normal -Command";

                // Register context menu for image files
                string imgBase = @"Software\Classes\SystemFileAssociations\image\shell\NemJPG";
                RegisterContextMenu(imgBase, installedScript, psCmd);

                // Register context menu for directories
                string dirBase = @"Software\Classes\Directory\shell\NemJPG";
                RegisterContextMenu(dirBase, installedScript, psCmd);

                Console.WriteLine();
                Console.WriteLine("============================================");
                Console.WriteLine("  NemJPG er installeret!");
                Console.WriteLine("============================================");
                Console.WriteLine();
                Console.WriteLine("Script installeret i:");
                Console.WriteLine("  " + installDir);
                Console.WriteLine();
                Console.WriteLine("Hoejreklik paa en billedfil eller mappe");
                Console.WriteLine("for at bruge NemJPG.");
                Console.WriteLine();
                Console.WriteLine("Paa Windows 11: Vaelg 'Vis flere indstillinger'");
                Console.WriteLine("for at se NemJPG i kontekstmenuen.");
                Console.WriteLine();
                Console.WriteLine("Tryk en tast for at lukke...");
                Console.ReadKey();
                return 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("FEJL under installation: " + ex.Message);
                Console.ReadKey();
                return 1;
            }
        }

        static void RegisterContextMenu(string basePath, string scriptPath, string psCmd)
        {
            using (var baseKey = Registry.CurrentUser.CreateSubKey(basePath))
            {
                baseKey.SetValue("", "NemJPG");
                baseKey.SetValue("MUIVerb", "NemJPG");
                baseKey.SetValue("SubCommands", "");
                baseKey.SetValue("Icon", "imageres.dll,67");
            }

            // Menu items: key suffix, display name, action
            var items = new[]
            {
                new[] { "01_jpg95", "Konverter til JPG (Hoej kvalitet)", "jpg95" },
                new[] { "02_jpg80", "Konverter til JPG (Web)", "jpg80" },
                new[] { "03_jpgresize", "Konverter til JPG + Resize (1920px)", "jpgresize1920" },
                new[] { "04_png", "Konverter til PNG", "png" },
                new[] { "05_webp", "Konverter til WebP", "webp" },
            };

            foreach (var item in items)
            {
                string subKey = basePath + @"\shell\" + item[0];
                using (var key = Registry.CurrentUser.CreateSubKey(subKey))
                {
                    key.SetValue("", item[1]);
                    key.SetValue("Icon", "imageres.dll,67");
                }

                string cmdKey = subKey + @"\command";
                string cmdValue = string.Format(
                    "{0} \"& '{1}' -Action {2} -Path '%1'\"",
                    psCmd, scriptPath.Replace("'", "''"), item[2]);

                using (var key = Registry.CurrentUser.CreateSubKey(cmdKey))
                {
                    key.SetValue("", cmdValue);
                }
            }
        }

        static int Uninstall()
        {
            try
            {
                // Remove registry entries
                string[] paths = new[]
                {
                    @"Software\Classes\SystemFileAssociations\image\shell\NemJPG",
                    @"Software\Classes\Directory\shell\NemJPG",
                };

                foreach (var path in paths)
                {
                    try
                    {
                        Registry.CurrentUser.DeleteSubKeyTree(path, false);
                    }
                    catch { }
                }

                // Remove installed files
                string installDir = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "NemJPG");

                if (Directory.Exists(installDir))
                {
                    Directory.Delete(installDir, true);
                }

                Console.WriteLine();
                Console.WriteLine("NemJPG er afinstalleret.");
                Console.WriteLine("Kontekstmenu og filer er fjernet.");
                Console.WriteLine();
                Console.WriteLine("Tryk en tast for at lukke...");
                Console.ReadKey();
                return 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("FEJL under afinstallation: " + ex.Message);
                Console.ReadKey();
                return 1;
            }
        }
    }
}
