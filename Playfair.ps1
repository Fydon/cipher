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

      [void]$alphabet.Remove($character)
      ++$columnIndex

      if ($character -eq [char]'I') {
        [void]$alphabet.Remove([char]'J')
      }

      if ($character -eq [char]'J') {
        [void]$alphabet.Remove([char]'I')
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

  # PrintMatrix($matrix)

  $firstCharacterColumnIndex = -1
  $firstCharacterIndex = -1
  $firstCharacterRowIndex = -1
  $secondCharacterColumnIndex = -1
  $secondCharacterIndex = -1
  $secondCharacterRowIndex = -1
  $textBetween = [string]::Empty

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
      if ($firstCharacterIndex -eq -1) {
        $firstCharacterIndex = $plaintextIndex
      }
      else {
        $secondCharacterIndex = $plaintextIndex

        $firstCharacter = $plaintext[$firstCharacterIndex]
        $secondCharacter = $plaintext[$secondCharacterIndex]

        if ([char]::ToUpper($firstCharacter) -eq [char]::ToUpper($secondCharacter)) {
          if ([char]::IsUpper($secondCharacter)) {
            $secondCharacter = 'Q'
          }
          else {
            $secondCharacter = 'q'
          }
        }

        $characters = ProcessCharacters -firstCharacter $firstCharacter -secondCharacter $secondCharacter
        $cipherText += "$($characters[0])$textBetween$($characters[1])"

        $firstCharacterIndex = -1
        $secondCharacterIndex = -1
        $textBetween = [string]::Empty
      }
    }
    else {
      if ($firstCharacterIndex -eq -1) {
        $cipherText += $character
      }
      else {
        $textBetween += $character
      }
    }
  }

  if ($firstCharacterIndex -ne -1) {
    $firstCharacter = $plaintext[$firstCharacterIndex]
    $secondCharacter = 'x'

    $characters = ProcessCharacters -firstCharacter $firstCharacter -secondCharacter $secondCharacter
    $cipherText += "$($characters[0])$textBetween$($characters[1])"
  }

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

Function ProcessCharacters($firstCharacter, $secondCharacter) {
  $characterLocation = FindCharacter -character $firstCharacter -matrix $matrix
  $firstCharacterColumnIndex = $characterLocation[1]
  $firstCharacterRowIndex = $characterLocation[0]

  $characterLocation = FindCharacter -character $secondCharacter -matrix $matrix
  $secondCharacterColumnIndex = $characterLocation[1]
  $secondCharacterRowIndex = $characterLocation[0]

  $isSameColumn = $firstCharacterColumnIndex -eq $secondCharacterColumnIndex
  $isSameRow = $firstCharacterRowIndex -eq $secondCharacterRowIndex

  $newFirstCharacter = [string]::Empty
  $newFirstCharacterColumnIndex = -1
  $newFirstCharacterRowIndex = -1
  $newSecondCharacter = [string]::Empty
  $newSecondCharacterColumnIndex = -1
  $newSecondCharacterRowIndex = -1
  if (!$isSameColumn -and !$isSameRow) {
    $newFirstCharacterColumnIndex = $secondCharacterColumnIndex
    $newFirstCharacterRowIndex = $firstCharacterRowIndex
    $newFirstCharacter = $matrix[$newFirstCharacterRowIndex][$newFirstCharacterColumnIndex]

    $newSecondCharacterColumnIndex = $firstCharacterColumnIndex
    $newSecondCharacterRowIndex = $secondCharacterRowIndex
    $newSecondCharacter = $matrix[$newSecondCharacterRowIndex][$newSecondCharacterColumnIndex]
  }
  elseif ($isSameRow) {
    $newFirstCharacterColumnIndex = ($firstCharacterColumnIndex + 1) % 5
    $newFirstCharacterRowIndex = $firstCharacterRowIndex
    $newFirstCharacter = $matrix[$newFirstCharacterRowIndex][$newFirstCharacterColumnIndex]

    $newSecondCharacterColumnIndex = ($secondCharacterColumnIndex + 1) % 5
    $newSecondCharacterRowIndex = $secondCharacterRowIndex
    $newSecondCharacter = $matrix[$newSecondCharacterRowIndex][$newSecondCharacterColumnIndex]
  }
  else {
    $newFirstCharacterColumnIndex = $firstCharacterColumnIndex
    $newFirstCharacterRowIndex = ($firstCharacterRowIndex + 1) % 5
    $newFirstCharacter = $matrix[$newFirstCharacterRowIndex][$newFirstCharacterColumnIndex]

    $newSecondCharacterColumnIndex = $secondCharacterColumnIndex
    $newSecondCharacterRowIndex = ($secondCharacterRowIndex + 1) % 5
    $newSecondCharacter = $matrix[$newSecondCharacterRowIndex][$newSecondCharacterColumnIndex]
  }

  if ([char]::IsLower($firstCharacter)) {
    $newFirstCharacter = [char]::ToLower($newFirstCharacter)
  }

  if ([char]::IsLower($secondCharacter)) {
    $newSecondCharacter = [char]::ToLower($newSecondCharacter)
  }

  # Write-Host "$firstCharacter ($firstCharacterRowIndex, $firstCharacterColumnIndex) $secondCharacter -> $secondCharacter ($secondCharacterRowIndex, $secondCharacterColumnIndex) isSameColumn $isSameColumn isSameRow $isSameRow $newFirstCharacter ($newFirstCharacterRowIndex, $newFirstCharacterColumnIndex) $newSecondCharacter ($newSecondCharacterColumnIndex, $newSecondCharacterColumnIndex)"

  return @($newFirstCharacter, $newSecondCharacter)
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