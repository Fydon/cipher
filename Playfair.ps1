Function Encipher([string]$key, [string]$plaintext) {
  $cipherText = [string]::Empty
  $alphabet = [System.Collections.Generic.HashSet[char]] @('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')

  $matrix = New-Object char[][] 5, 5

  $columnIndex = 0
  $rowIndex = 0

  [char]$character
  for ($keyIndex = 0; $keyIndex -lt $key.Length; ++$keyIndex) {
    $character = [char]::ToUpper($key[$keyIndex])

    if ($alphabet.Contains($character)) {
      $matrix[$rowIndex][$columnIndex] = $character

      $alphabet.Remove($character)
      ++$columnIndex

      if ($character -eq [char]'I') {
        $alphabet.Remove([char]'J')
      }

      if ($character -eq [char]'J') {
        $alphabet.Remove([char]'I')
      }

      if ($columnIndex -eq 5) {
        $columnIndex = 0
        ++$rowIndex
      }
    }
  }

  $restOfAlphabet = New-Object char[] 26
  $alphabet.CopyTo($restOfAlphabet)

  $restOfAlphabetIndex = 0
  for (; $rowIndex -lt 5; ++$rowIndex) {
    for (; $columnIndex -lt 5; ++$columnIndex) {
      $matrix[$rowIndex][$columnIndex] = $restOfAlphabet[$restOfAlphabetIndex++]

      # I and J are in the same block
      if ($restOfAlphabet[$restOfAlphabetIndex] -eq [char]'J') {
        ++$restOfAlphabetIndex
      }
    }

    $columnIndex = 0
  }

  for ($rowIndex = 0; $rowIndex -lt 5; ++$rowIndex) {
    for ($columnIndex = 0; $columnIndex -lt 5; ++$columnIndex) {
      if ($matrix[$rowIndex][$columnIndex] -ne [char]'I' -and $matrix[$rowIndex][$columnIndex] -ne [char]'J') {
        Write-Host -NoNewline "$($matrix[$rowIndex][$columnIndex])   "
      }
      else {
        Write-Host -NoNewline "I/J "
      }

    }
    Write-Host
  }

  return $cipherText
}

$plaintext = Read-Host "Please provide the text to encipher"
$key = Read-Host "Please provide the key"
$cipherText = Encipher -key $key -plainText $plaintext

Write-Host $cipherText