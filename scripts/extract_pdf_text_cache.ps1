param(
  [Parameter(Mandatory = $true)]
  [string]$PdfDir,

  [Parameter(Mandatory = $true)]
  [string]$TextDir,

  [int]$FirstPage = 1,

  [int]$LastPage = 8
)

$ErrorActionPreference = "Continue"

if (-not (Test-Path -LiteralPath $PdfDir)) {
  throw "PDF directory does not exist: $PdfDir"
}

$pdfToText = Get-Command pdftotext -ErrorAction SilentlyContinue
if (-not $pdfToText) {
  throw "pdftotext was not found on PATH. Install Poppler/MiKTeX tools or use another PDF text extractor."
}

New-Item -ItemType Directory -Force -Path $TextDir | Out-Null

$results = @()
foreach ($pdf in Get-ChildItem -File -LiteralPath $PdfDir -Filter *.pdf) {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($pdf.Name)
  $txt = Join-Path $TextDir ($base + ".txt")
  try {
    & $pdfToText.Source -enc UTF-8 -layout -f $FirstPage -l $LastPage $pdf.FullName $txt 2>$null
    $len = if (Test-Path -LiteralPath $txt) { (Get-Item -LiteralPath $txt).Length } else { 0 }
    if ($len -le 0) { throw "No text extracted" }
    $results += [pscustomobject]@{
      Status = "ok"
      Pdf = $pdf.Name
      TextFile = [System.IO.Path]::GetFileName($txt)
      TextBytes = $len
      Error = ""
    }
  } catch {
    if (Test-Path -LiteralPath $txt) { Remove-Item -LiteralPath $txt -Force }
    $results += [pscustomobject]@{
      Status = "failed"
      Pdf = $pdf.Name
      TextFile = ""
      TextBytes = 0
      Error = $_.Exception.Message
    }
  }
}

$manifest = Join-Path $TextDir "text-cache-manifest.csv"
$results | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $manifest
$results | Format-Table -AutoSize
Write-Host "PDFs processed: $($results.Count)"
Write-Host "Text files created: $(($results | Where-Object { $_.Status -eq 'ok' }).Count)"
Write-Host "Manifest: $manifest"
