using System;
using System.Diagnostics;
using System.IO;

namespace NemJPG
{
    class Program
    {
        static int Main(string[] args)
        {
            string appDir = AppDomain.CurrentDomain.BaseDirectory;
            string scriptPath = Path.Combine(appDir, "nemjpg.ps1");
            string iniPath = Path.Combine(appDir, "nemjpg.ini");

            // If no arguments, show info and run installer
            if (args.Length == 0)
            {
                // Run the installer batch to register context menu
                string installerPath = Path.Combine(appDir, "Installer NemJPG.bat");
                if (File.Exists(installerPath))
                {
                    var psi = new ProcessStartInfo
                    {
                        FileName = "cmd.exe",
                        Arguments = "/c \"" + installerPath + "\"",
                        UseShellExecute = true,
                        WorkingDirectory = appDir
                    };
                    Process.Start(psi);
                }
                return 0;
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
    }
}
