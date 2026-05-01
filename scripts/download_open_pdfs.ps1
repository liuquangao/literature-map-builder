param(
  [Parameter(Mandatory = $true)]
  [string]$CsvPath,

  [Parameter(Mandatory = $true)]
  [string]$OutputDir,

  [string]$ManifestPath = ""
)

$ErrorActionPreference = "Continue"

function Convert-ToSafeFileName {
  param([Parameter(Mandatory = $true)][string]$Title)
  $safe = $Title -replace '[\\/:*?"<>|]', ''
  $safe = $safe -replace '\s+', ' '
  $safe = $safe.Trim()
  if ($safe.Length -gt 170) {
    $safe = $safe.Substring(0, 170).Trim()
  }
  return $safe
}

function Test-PdfHeader {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  if ((Get-Item -LiteralPath $Path).Length -lt 10000) { return $false }
  $stream = [System.IO.File]::OpenRead($Path)
  try {
    $buffer = New-Object byte[] 4
    [void]$stream.Read($buffer, 0, 4)
    $head = [System.Text.Encoding]::ASCII.GetString($buffer)
    return $head -eq "%PDF"
  } finally {
    $stream.Close()
  }
}

if (-not (Test-Path -LiteralPath $CsvPath)) {
  throw "CSV path does not exist: $CsvPath"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

if (-not $ManifestPath) {
  $ManifestPath = Join-Path $OutputDir "download-manifest.csv"
}

$rows = Import-Csv -LiteralPath $CsvPath
$results = @()

foreach ($row in $rows) {
  $title = [string]$row.Title
  $url = [string]$row.Url
  $category = [string]$row.Category

  if (-not $title -or -not $url) {
    $results += [pscustomobject]@{
      Status = "skipped"
      Category = $category
      Title = $title
      Url = $url
      FileName = ""
      SizeBytes = 0
      Error = "Missing Title or Url"
    }
    continue
  }

  $fileName = (Convert-ToSafeFileName -Title $title) + ".pdf"
  $path = Join-Path $OutputDir $fileName

  if (Test-PdfHeader -Path $path) {
    $item = Get-Item -LiteralPath $path
    $results += [pscustomobject]@{
      Status = "exists"
      Category = $category
      Title = $title
      Url = $url
      FileName = $fileName
      SizeBytes = $item.Length
      Error = ""
    }
    continue
  }

  try {
    Invoke-WebRequest -Uri $url -OutFile $path -Headers @{ "User-Agent" = "Mozilla/5.0" } -TimeoutSec 90
    if (-not (Test-PdfHeader -Path $path)) {
      throw "Downloaded file is not a valid PDF"
    }
    $item = Get-Item -LiteralPath $path
    $results += [pscustomobject]@{
      Status = "downloaded"
      Category = $category
      Title = $title
      Url = $url
      FileName = $fileName
      SizeBytes = $item.Length
      Error = ""
    }
  } catch {
    if (Test-Path -LiteralPath $path) {
      Remove-Item -LiteralPath $path -Force
    }
    $results += [pscustomobject]@{
      Status = "failed"
      Category = $category
      Title = $title
      Url = $url
      FileName = $fileName
      SizeBytes = 0
      Error = $_.Exception.Message
    }
  }
}

$results | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $ManifestPath
$results | Format-Table -AutoSize

$pdfCount = ($results | Where-Object { $_.Status -in @("downloaded", "exists") }).Count
$failedCount = ($results | Where-Object { $_.Status -eq "failed" }).Count
Write-Host "PDFs available: $pdfCount"
Write-Host "Failed downloads: $failedCount"
Write-Host "Manifest: $ManifestPath"
