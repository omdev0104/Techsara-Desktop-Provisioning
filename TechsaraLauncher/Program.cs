using System.Diagnostics;
using System.Windows.Forms;

namespace TechsaraLauncher;

internal static class Program
{
    [STAThread]
    static void Main()
    {
        try
        {
            string? root = FindTechsaraRoot();

            if (root == null)
            {
                MessageBox.Show(
                    "Techsara Deployment Tool could not find Build.ps1.\n\n" +
                    "Make sure the launcher is located inside the Techsara deployment project.",
                    "Techsara Desktop Provisioning Utility",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );

                return;
            }

            string buildScript = Path.Combine(root, "Build.ps1");

            var startInfo = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                WorkingDirectory = root,
                UseShellExecute = false,
                CreateNoWindow = false
            };

            startInfo.ArgumentList.Add("-NoProfile");
            startInfo.ArgumentList.Add("-ExecutionPolicy");
            startInfo.ArgumentList.Add("Bypass");
            startInfo.ArgumentList.Add("-File");
            startInfo.ArgumentList.Add(buildScript);

            using Process? process = Process.Start(startInfo);

            if (process == null)
            {
                throw new Exception("Unable to start PowerShell.");
            }

            process.WaitForExit();

            if (process.ExitCode != 0)
            {
                MessageBox.Show(
                    $"The Techsara deployment process exited with code {process.ExitCode}.",
                    "Techsara Deployment Tool",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning
                );
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                "Techsara Deployment Tool encountered an error.\n\n" +
                ex.Message,
                "Techsara Desktop Provisioning Utility",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
        }
    }

    private static string? FindTechsaraRoot()
    {
        DirectoryInfo? directory =
            new DirectoryInfo(AppContext.BaseDirectory);

        while (directory != null)
        {
            string buildScript =
                Path.Combine(directory.FullName, "Build.ps1");

            if (File.Exists(buildScript))
            {
                return directory.FullName;
            }

            directory = directory.Parent;
        }

        return null;
    }
}