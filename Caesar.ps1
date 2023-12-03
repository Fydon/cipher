Function Encipher([int]$numberOfCharactersToShift, [string]$plaintext) {
  [string]$cipherText = [string]::Empty

  [char]$character
  for ($index = 0; $index -lt $plaintext.Length; ++$index) {
    $character = $plaintext[$index]

    $isLowerCase = $false
    $isUpperCase = $false
    # $isNumerical = $false
    if ([char]::isLower($character)) {
      $isLowerCase = $true
    }
    elseif ([char]::IsUpper($character)) {
      $isUpperCase = $true
    }
    # elseif ([char]::isNumber($character)) {
    #   $isNumerical = $true
    # }

    if ($isLowerCase -or $isUpperCase) {
      # -or $isNumerical
      $character = [char]([byte][char]$character + $numberOfCharactersToShift)

      if ($isLowerCase) {
        if (($character.CompareTo([char]'a')) -lt 0) {
          $character = [char]([byte][char]'z' + ([byte][char]$character - [byte][char]'a') + 1)
        }
        elseif ($character.CompareTo([char]'z') -gt 0) {
          $character = [char]([byte][char]'a' + ([byte][char]$character - [byte][char]'z') - 1)
        }
      }
      elseif ($isUpperCase) {
        if (($character.CompareTo([char]'A')) -lt 0) {
          $character = [char]([byte][char]'Z' + ([byte][char]$character - [byte][char]'A') + 1)
        }
        elseif ($character.CompareTo([char]'Z') -gt 0) {
          $character = [char]([byte][char]'A' + ([byte][char]$character - [byte][char]'Z') - 1)
        }
      }
      # elseif ($isNumerical) {
      #   if (($character.CompareTo([char]'0')) -lt 0) {
      #     $character = [char]([byte][char]'9' + ([byte][char]$character - [byte][char]'0') + 1)
      #   }
      #   elseif ($character.CompareTo([char]'9') -gt 0) {
      #     $character = [char]([byte][char]'0' + ([byte][char]$character - [byte][char]'9') - 1)
      #   }
      # }
    }
    # Write-Host "$($plaintext[$index]) isLowerCase $isLowerCase isUpperCase $isUpperCase and becomes $character"
    # isNumerical $isNumerical

    $cipherText += $character
  }

  return $cipherText
}

$plaintext = Read-Host "Please provide the plaintext"
$numberOfCharactersToShift = Read-Host "Please provide the number of characters to shift by"
$cipherText = Encipher -numberOfCharactersToShift $numberOfCharactersToShift -plainText $plaintext

Write-Host "cipher text: $cipherText"