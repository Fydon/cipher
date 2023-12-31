Function Encipher([string]$key, [string]$plaintext) {
  [string]$cipherText = [string]::Empty

  [char]$character
  $keyIndex = 0
  for ($textIndex = 0; $textIndex -lt $plaintext.Length; ++$textIndex) {
    $character = $plaintext[$textIndex]

    # Write-Host "$character $($character.GetType())"

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

    # Write-Host "isLowerCase $isLowerCase isUpperCase $isUpperCase"
    # isNumerical $isNumerical

    if ($isLowerCase -or $isUpperCase) {
      # -or $isNumerical
      $character = [char]([byte][char]$character + ([char]::ToLower($key[$keyIndex % $key.Length]) - [byte][char]'a'))

      # Write-Host "$character $($character.GetType())"

      if ($isLowerCase) {
        if (($character.CompareTo([char]'a')) -lt 0) {
          $character = [char]([byte][char]'z' + ([byte][char]$character - [byte][char]'a') + 1)
        }
        elseif ($character.CompareTo([char]'z') -gt 0) {
          $character = [char]([byte][char]'a' + ([byte][char]$character - [byte][char]'z') - 1)
        }

        # Write-Host "$([char]::ToLower($key[$keyIndex % $key.Length])) is an offset of $([char]::ToLower($key[$keyIndex % $key.Length]) - [byte][char]'a'). $($plaintext[$textIndex]) becomes $character"
        ++$keyIndex
      }
      elseif ($isUpperCase) {
        if (($character.CompareTo([char]'A')) -lt 0) {
          $character = [char]([byte][char]'Z' + ([byte][char]$character - [byte][char]'A') + 1)
        }
        elseif ($character.CompareTo([char]'Z') -gt 0) {
          $character = [char]([byte][char]'A' + ([byte][char]$character - [byte][char]'Z') - 1)
        }

        # Write-Host "$([char]::ToLower($key[$keyIndex % $key.Length])) is an offset of $([char]::ToLower($key[$keyIndex % $key.Length]) - [byte][char]'a'). $($plaintext[$textIndex]) becomes $character"
        ++$keyIndex
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

    $cipherText += $character
  }

  return $cipherText
}

$plaintext = Read-Host "Please provide the plaintext"
$key = Read-Host "Please provide the key"
$cipherText = Encipher -key $key -plainText $plaintext

Write-Host "cipher text: $cipherText"