# Exports web-sized JPEG copies of source images (for example, finished marketing covers).
# Usage: powershell -File tools/export-images.ps1 -OutDir <folder> -Widths 1600,800 <image> [<image> ...]
# Each image is written as <name>-<width>.jpg; images are never enlarged.
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory)] [string] $OutDir,
    [string] $Widths = '1600,800',
    [int] $Quality = 82,
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)] [string[]] $Images
)

Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutDir | Out-Null
$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$params = New-Object System.Drawing.Imaging.EncoderParameters 1
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$Quality)

foreach ($path in $Images) {
    $src = [System.Drawing.Image]::FromFile((Resolve-Path $path))
    try {
        $name = [IO.Path]::GetFileNameWithoutExtension($path).ToLowerInvariant() -replace '[^a-z0-9]+', '-'
        foreach ($w in ($Widths -split ',' | ForEach-Object { [int]$_ })) {
            $w = [Math]::Min($w, $src.Width)
            $h = [int][Math]::Round($src.Height * $w / $src.Width)
            $bmp = New-Object System.Drawing.Bitmap $w, $h
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode = 'HighQualityBicubic'
            $g.PixelOffsetMode = 'HighQuality'
            $g.CompositingQuality = 'HighQuality'
            $g.Clear([System.Drawing.Color]::Black)
            $g.DrawImage($src, 0, 0, $w, $h)
            $out = Join-Path $OutDir "$name-$w.jpg"
            $bmp.Save($out, $jpeg, $params)
            $g.Dispose(); $bmp.Dispose()
            "{0} ({1}x{2}, {3:N0} KB)" -f $out, $w, $h, ((Get-Item $out).Length / 1KB)
        }
    } finally { $src.Dispose() }
}
