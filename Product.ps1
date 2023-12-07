Function Encipher([string]$key, [string]$plaintext) {
  $cipherText = [string]::Empty

  $substitutions = @('A', 'D', 'F', 'G', 'V', 'X')
  $matrix = @(
    @('C', 'O', '8', 'X', 'F', '4'),
    @('M', 'K', '3', 'A', 'Z', '9'),
    @('N', 'W', 'L', '0', 'J', 'D'),
    @('5', 'S', 'I', 'Y', 'H', 'U'),
    @('P', '1', 'V', 'B', '6', 'R'),
    @('E', 'Q', '7', 'T', '2', 'G')
  )

  $keyWithUniqueCharacters = New-Object System.Collections.Generic.HashSet[char]
  for ($keyIndex = 0; $keyIndex -lt $key.Length; ++$keyIndex) {
    $character = [char]::ToUpper($key[$keyIndex])
    if ($keyWithUniqueCharacters.Add($character)) {
      Write-Host -NoNewline "$character"
    }
  }
  Write-Host
  Write-Host

  # PrintMatrix($matrix)

  $intermediateCipherText = [string]::Empty

  $characterColumnIndex = -1
  $characterIndex = -1
  $characterRowIndex = -1
  # $textBetween = [string]::Empty

  for ($plaintextIndex = 0; $plaintextIndex -lt $plaintext.Length; ++$plaintextIndex) {
    $character = $plaintext[$plaintextIndex]

    # Write-Host "$character $($character.GetType())"

    $isLowerCase = $false
    $isUpperCase = $false
    if ([char]::isLower($character)) {
      $isLowerCase = $true
    }
    elseif ([char]::IsUpper($character)) {
      $isUpperCase = $true
    }

    # Write-Host "isLowerCase $isLowerCase isUpperCase $isUpperCase"

    if ($isLowerCase -or $isUpperCase) {
      $location = FindCharacter -character $character -matrix $matrix

      $substitutionCharacters = "$($substitutions[$location[0]])$($substitutions[$location[1]])"
      $intermediateCipherText += $substitutionCharacters

      Write-Host -NoNewline "$substitutionCharacters "
    }
  }
  Write-Host
  Write-Host

  $transpositionMatrixLength = [int]($plaintext.Length / $keyWithUniqueCharacters.Count) + 20

  $transpositionMatrix = [System.Collections.Generic.List[System.Collections.Generic.List[char]]]::new($keyWithUniqueCharacters.Count)
  for ($transpositionMatrixIndex = 0; $transpositionMatrixIndex -lt $keyWithUniqueCharacters.Count; ++$transpositionMatrixIndex) {
    $transpositionMatrix.Add([System.Collections.Generic.List[char]]::new($transpositionMatrixLength))
  }

  $transpositionMatrixColumnIndex = 0
  $transpositionMatrixRowIndex = 0
  for ($intermediateCipherTextIndex = 0; $intermediateCipherTextIndex -lt $intermediateCipherText.Length; ++$intermediateCipherTextIndex) {
    $character = $intermediateCipherText[$intermediateCipherTextIndex]

    # Write-Host "transpositionMatrixRowIndex $transpositionMatrixRowIndex transpositionMatrixColumnIndex $transpositionMatrixColumnIndex"

    $transpositionMatrix[$transpositionMatrixRowIndex].Add($character)

    Write-Host -NoNewline "$character "

    ++$transpositionMatrixRowIndex
    if ($transpositionMatrixRowIndex -eq $keyWithUniqueCharacters.Count) {
      $transpositionMatrixRowIndex = 0
      ++$transpositionMatrixColumnIndex

      Write-Host
    }
  }
  Write-Host
  Write-Host

  # for ($transpositionMatrixIndex = 0; $transpositionMatrixIndex -lt $transpositionMatrixLength; ++$transpositionMatrixIndex) {
  $cipherText += "$($transpositionMatrix[0]) "
  # }
  $cipherText += [System.Environment]::NewLine

  # for ($transpositionMatrixIndex = 0; $transpositionMatrixIndex -lt $transpositionMatrixLength; ++$transpositionMatrixIndex) {
  $cipherText += "$($transpositionMatrix[3]) "
  # }
  $cipherText += [System.Environment]::NewLine

  # for ($transpositionMatrixIndex = 0; $transpositionMatrixIndex -lt $transpositionMatrixLength; ++$transpositionMatrixIndex) {
  $cipherText += "$($transpositionMatrix[4]) "
  # }
  $cipherText += [System.Environment]::NewLine

  # for ($transpositionMatrixIndex = 0; $transpositionMatrixIndex -lt $transpositionMatrixLength; ++$transpositionMatrixIndex) {
  $cipherText += "$($transpositionMatrix[1]) "
  # }
  $cipherText += [System.Environment]::NewLine

  # for ($transpositionMatrixIndex = 0; $transpositionMatrixIndex -lt $transpositionMatrixLength; ++$transpositionMatrixIndex) {
  $cipherText += "$($transpositionMatrix[2]) "
  # }
  $cipherText += [System.Environment]::NewLine

  return $cipherText
}

Function FindCharacter($character, $matrix) {
  if ([char]::ToUpper($character) -eq 'J') {
    $character = 'I'
  }

  for ($rowIndex = 0; $rowIndex -le 5; ++$rowIndex) {
    for ($columnIndex = 0; $columnIndex -lt 5; ++$columnIndex) {
      if ($matrix[$rowIndex][$columnIndex] -eq [char]::ToUpper($character)) {
        break;
      }
    }

    if ($matrix[$rowIndex][$columnIndex] -eq [char]::ToUpper($character)) {
      break;
    }
  }

  return @($rowIndex, $columnIndex)
}

Function PrintMatrix($matrix) {
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
}

$plaintext = Read-Host "Please provide the text to encipher"
$key = Read-Host "Please provide the key"
$cipherText = Encipher -key $key -plainText $plaintext

# Note I'm intentionally outputing this in a form to make it easier to decipher
Write-Host $cipherText