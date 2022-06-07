function Update-LastWriteTime {
  Param($File)
  if (Test-Path -Path $File) {
    (Get-Item $File).LastWriteTime = Get-Date
  }
}

function UpdateMany-LastWriteTime {
  Param($Files)
  foreach ($File in $Files) {
    Update-LastWriteTime $File
  }
}

function Update-LastAccessTime {
  Param($File)
  if (Test-Path -Path $File) {
    (Get-Item $File).LastAccessTime = Get-Date
  }
}

function UpdateMany-LastAccessTime {
  Param($Files)
  foreach ($File in $Files) {
    Update-LastAccessTime $File
  }
}

function Create-File {
  Param($File)
  if (Test-Path -Path $File) {
    Update-LastWriteTime $File
    Update-LastAccessTime $File
    return
  }
  Set-Content -Path ($File) -Value ($null)
}

function CreateMany-File {
  Param($Files)
  foreach ($File in $Files) {
    Create-File $File
  }
}


function touch { 
  $version = "1.0.0"
  $files = @()
  $arguments = @()
  $validArguments = @("--help", "--version", "-a", "-c", "--no-create", "-m")
  foreach ($arg in $args) {
    if ($arg[0] -eq "-" -and $arg[1] -eq "-") {
      if ($validArguments.Contains($arg) -eq $false) {
        Write-Error -Message "unrecognized option `'$arg`'"
        Write-Output "Try 'touch --help' for more information."
        return
      }
      $arguments += $arg
      continue
    }
    if ($arg[0] -eq "-") {
      if ($validArguments.Contains($arg) -eq $false) {
        $option = $arg.substring(1)
        Write-Error -Message "invalid option -- `'$option`'"
        Write-Output "Try 'touch --help' for more information."
        return
      }
      $arguments += $arg
      continue
    }

    if ($arg -Match '[\/:*"<>|]') {
      Write-Error -Message "FILE Argument `'$arg'` contains an illegal character.`nA file name can't contain any of the following characters: \ / : * `" < > |" 
      return
    }

    $files += $arg
  }

  if ($arguments.Contains("--help")) {
    Write-Output "Usage: touch [OPTION]... FILE..."
    Write-Output "Update the access and modification times of each FILE to the current time."
    Write-Output ""
    Write-Output "A FILE argument that does not exist is created empty, unless -c is supplied."
    Write-Output ""
    Write-Output "Mandatory arguments to long options are mandatory for short options too."
    Write-Output "  -a                    change only the access time"
    Write-Output "  -c, --no-create       do not create any files"
    Write-Output "  -m                    change only the modification time"
    Write-Output "      --help    display this help and exit"
    Write-Output "      --version output version information and exit"
    return
  }

  if ($arguments.Contains("--version")) {
    Write-Output "touch $version"
    Write-Output "This is a free script that rebuilds the GNU coreutil touch in powershell 7."
    Write-Output ""
    Write-Output "Written by DariusCorvus."
    return
  }

  if ($null -eq $args[0]) {
    Write-Error -Message "missing file operand"
    Write-Output "Try 'touch --help' for more information."
    return
  }

  $noCreate = ($arguments.Contains("-c") -or $arguments.Contains("--no-create"))

  if ($arguments.Contains("-a")) {
    UpdateMany-LastAccessTime $files
    if ($noCreate) {
      return
    }
    CreateMany-File $files
    return
  }

  if ($arguments.Contains("-m")) {
    UpdateMany-LastWriteTime $files
    if ($noCreate) {
      return
    }
    CreateMany-File $files
    return
  }

  if ($noCreate) {
    UpdateMany-LastWriteTime $files
    UpdateMany-LastAccessTime $files
    return
  }

  CreateMany-File $files
}
