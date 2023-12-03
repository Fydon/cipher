Function Encipher([int]$numberOfRows, [string]$plaintext) {
  [string]$cipherText = [string]::Empty
  [string[]]$characterRows = New-Object string[] $numberOfRows

  for ($index = 0; $index -lt $plaintext.Length; ++$index) {
    $characterRows[$index % $numberOfRows] += $plaintext[$index]
  }

  for ($index = 0; $index -lt $numberOfRows; ++$index) {
    $cipherText += $characterRows[$index]

    # Write-Host "Row $index $($characterRows[$index])"
  }

  return $cipherText
}

$plaintext = Read-Host "Please provide the plaintext"
$numberOfRows = Read-Host "Please provide the number of rows"
$cipherText = Encipher -numberOfRows $numberOfRows -plainText $plaintext

Write-Host "cipher text: $cipherText"