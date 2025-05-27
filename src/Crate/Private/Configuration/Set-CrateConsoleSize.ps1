<#
.SYNOPSIS
    Sets the PowerShell console window size for optimal Crate module display.

.DESCRIPTION
    Configures the PowerShell console window size in columns and rows to ensure
    the Crate menu interface displays properly. Includes error handling and
    fallback options for different console hosts.

.PARAMETER Width
    The width of the console window in columns. Default is 140.

.PARAMETER Height
    The height of the console window in rows. Default is 35.

.PARAMETER PixelWidth
    Optional width in pixels (requires Windows API calls).

.PARAMETER PixelHeight
    Optional height in pixels (requires Windows API calls).

.PARAMETER SaveOriginal
    Whether to save the original console size for restoration later.

.EXAMPLE
    Set-CrateConsoleSize
    Sets the console to default size (140x35).

.EXAMPLE
    Set-CrateConsoleSize -Width 120 -Height 30
    Sets the console to 120 columns by 30 rows.

.EXAMPLE
    Set-CrateConsoleSize -PixelWidth 1200 -PixelHeight 800
    Sets the console to specific pixel dimensions.

.NOTES
    Name:        Set-CrateConsoleSize.ps1
    Author:      Mickaël CHAVE
    Created:     27/05/2025
    Version:     25.5.26.1
    Repository:  https://github.com/mchave3/Crate
    License:     MIT License

    This function only works in the console host, not in ISE or other environments.
#>
function Set-CrateConsoleSize {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [int]$Width = 140,

        [Parameter()]
        [int]$Height = 35,

        [Parameter()]
        [int]$PixelWidth,

        [Parameter()]
        [int]$PixelHeight,

        [Parameter()]
        [switch]$SaveOriginal
    )

    begin {
        # Store original console size if requested
        $script:OriginalConsoleSize = $null

        # Windows API definitions for pixel-based resizing
        if ($PixelWidth -or $PixelHeight) {
            try {
                Add-Type -TypeDefinition @"
                    using System;
                    using System.Runtime.InteropServices;
                    public class WindowAPI {
                        [DllImport("kernel32.dll", SetLastError = true)]
                        public static extern IntPtr GetConsoleWindow();

                        [DllImport("user32.dll", SetLastError = true)]
                        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter,
                            int X, int Y, int cx, int cy, uint uFlags);

                        [DllImport("user32.dll", SetLastError = true)]
                        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                        [StructLayout(LayoutKind.Sequential)]
                        public struct RECT {
                            public int Left;
                            public int Top;
                            public int Right;
                            public int Bottom;
                        }
                    }
"@ -ErrorAction SilentlyContinue
            }
            catch {
                Write-Warning "Could not load Windows API types for pixel-based resizing."
            }
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("PowerShell Console", "Resize console window to ${Width}x${Height}")) {
            try {
                # Check if we're running in a supported console host
                if ($Host.Name -ne "ConsoleHost") {
                    Write-Warning "Console resizing is only supported in PowerShell Console Host."
                    Write-Host "Current host: $($Host.Name)" -ForegroundColor Yellow
                    return
                }

                # Save original size if requested
                if ($SaveOriginal) {
                    try {
                        $script:OriginalConsoleSize = @{
                            WindowSize = $Host.UI.RawUI.WindowSize
                            BufferSize = $Host.UI.RawUI.BufferSize
                        }
                        Write-Verbose "Original console size saved: $($script:OriginalConsoleSize.WindowSize.Width)x$($script:OriginalConsoleSize.WindowSize.Height)"
                    }
                    catch {
                        Write-Verbose "Could not save original console size: $($_.Exception.Message)"
                    }
                }

                # Method 1: Pixel-based resizing (Windows API)
                if ($PixelWidth -or $PixelHeight) {
                    try {
                        $consoleHandle = [WindowAPI]::GetConsoleWindow()
                        if ($consoleHandle -ne [IntPtr]::Zero) {
                            # Get current position
                            $rect = New-Object WindowAPI+RECT
                            [WindowAPI]::GetWindowRect($consoleHandle, [ref]$rect) | Out-Null

                            $newWidth = if ($PixelWidth) { $PixelWidth } else { $rect.Right - $rect.Left }
                            $newHeight = if ($PixelHeight) { $PixelHeight } else { $rect.Bottom - $rect.Top }

                            # SWP_NOMOVE (0x0002) - don't move the window, just resize
                            $result = [WindowAPI]::SetWindowPos($consoleHandle, [IntPtr]::Zero, 0, 0, $newWidth, $newHeight, 0x0002)

                            if ($result) {
                                Write-Host "Console resized to ${newWidth}x${newHeight} pixels" -ForegroundColor Green
                            }
                            else {
                                throw "SetWindowPos failed"
                            }
                        }
                    }
                    catch {
                        Write-Warning "Pixel-based resizing failed: $($_.Exception.Message)"
                        Write-Host "Falling back to column/row based resizing..." -ForegroundColor Yellow
                    }
                }

                # Method 2: Column/Row based resizing (PowerShell native)
                if (-not ($PixelWidth -or $PixelHeight) -or $?) {
                    try {
                        # Validate dimensions
                        $maxSize = $Host.UI.RawUI.MaxWindowSize
                        if ($Width -gt $maxSize.Width) {
                            Write-Warning "Requested width ($Width) exceeds maximum ($($maxSize.Width)). Using maximum."
                            $Width = $maxSize.Width
                        }
                        if ($Height -gt $maxSize.Height) {
                            Write-Warning "Requested height ($Height) exceeds maximum ($($maxSize.Height)). Using maximum."
                            $Height = $maxSize.Height
                        }

                        # Create new size objects
                        $newWindowSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
                        $newBufferSize = New-Object System.Management.Automation.Host.Size($Width, [Math]::Max($Height, 9999))

                        # Set buffer size first (required before window size)
                        $Host.UI.RawUI.BufferSize = $newBufferSize

                        # Then set window size
                        $Host.UI.RawUI.WindowSize = $newWindowSize

                        Write-Host "Console resized to ${Width}x${Height} columns/rows" -ForegroundColor Green
                        Write-Verbose "Buffer size set to: $($newBufferSize.Width)x$($newBufferSize.Height)"
                    }
                    catch {
                        Write-Warning "Column/row based resizing failed: $($_.Exception.Message)"
                        Write-Host "Console size adjustment not supported in this environment." -ForegroundColor Yellow
                    }
                }
            }
            catch {
                Write-Error "Failed to set console size: $($_.Exception.Message)"
            }
        }
    }
}
