# YubiKey Remote Access Guide

This document provides comprehensive guidance for using YubiKey hardware authentication in remote access scenarios with the ykpiv_desktop Flutter plugin.

## Table of Contents

1. [Overview](#overview)
2. [Remote Access Scenarios](#remote-access-scenarios)
3. [RDP Solutions](#rdp-solutions)
4. [SSH-Based Solutions](#ssh-based-solutions)
5. [USB over IP Solutions](#usb-over-ip-solutions)
6. [Troubleshooting](#troubleshooting)
7. [Security Considerations](#security-considerations)

## Overview

The ykpiv_desktop plugin requires direct access to YubiKey hardware through the yubico-piv-tool library. This creates challenges when working in remote environments where the YubiKey is physically located on a different machine than where the application needs to run.

### Key Principle

**The YubiKey must be physically connected to the machine where cryptographic operations occur.** The ykpiv_desktop Flutter plugin interfaces directly with hardware through FFI bindings, requiring local USB access.

## Remote Access Scenarios

### Scenario 1: YubiKey on Windows, Remote Access via RDP

**Problem:** YubiKey is physically connected to Windows machine, but RDP session cannot access it.

**Root Cause:** RDP by design blocks remote smart card access for security reasons.

### Scenario 2: YubiKey on Windows, Access from macOS

**Problem:** Need to use YubiKey operations from a remote macOS machine.

**Solution:** SSH agent forwarding or API wrapper approach.

### Scenario 3: Virtual Machine Environments

**Problem:** YubiKey access within VM while host retains USB control.

**Solution:** USB passthrough configuration.

## RDP Solutions

### Solution 1: YubiKey Smart Card Minidriver (Recommended)

The official Yubico solution for RDP environments.

#### Installation Steps

1. **Install minidriver with Legacy Node flag:**
   ```powershell
   # On Windows machine (where YubiKey is connected)
   msiexec /i YubiKey-Minidriver-4.1.1.210-x64.msi INSTALL_LEGACY_NODE=1
   ```

2. **Configure Windows Services:**
   ```powershell
   # Enable Plug and Play service
   sc config PlugPlay start= auto
   sc start PlugPlay
   
   # Enable Smart Card service
   sc config SCardSvr start= auto
   sc start SCardSvr
   ```

3. **Enable RDP Smart Card Redirection:**
   - **RDP Client:** Enable "Smart cards" in Local Resources tab
   - **Windows Server:** Enable Smart Card redirection via Group Policy:
     ```
     Computer Configuration > Policies > Administrative Templates > 
     Windows Components > Remote Desktop Services > Remote Desktop Session Host > 
     Device and Resource Redirection > Do not allow smart card device redirection = Disabled
     ```

4. **Restart the system** to ensure all changes take effect.

#### Verification

```cmd
# In RDP session, verify YubiKey detection
certutil -scinfo
# Should show: "Identity Device (NIST SP 800-73 [PIV])"

# Check certificate store
certlm.msc
# Look for YubiKey certificate under Personal/Certificates
```

### Solution 2: Manual Hardware Addition

If automatic detection fails:

1. Open **Device Manager** in RDP session
2. **Action > Add legacy hardware**
3. Select **Install the hardware that I manually select**
4. Choose **Smart Cards**
5. Select **Yubico** manufacturer, **YubiKey Smart Card Minidriver** model

## SSH-Based Solutions

### SSH Agent Forwarding

When YubiKey is on Windows and you need access from remote Unix systems:

```bash
# Configure SSH client
Host windows-machine
    Hostname your-windows-ip
    ForwardAgent yes
    PKCS11Provider /path/to/libykcs11.so
    IdentityFile ~/.ssh/yubikey_rsa.pub

# Connect with agent forwarding
ssh -A user@windows-machine
```

### SSH ProxyJump Configuration

```bash
# ~/.ssh/config
Host target-machine
    Hostname target-ip
    ProxyJump windows-yubikey-host
    PKCS11Provider /path/to/libykcs11.so
```

## USB over IP Solutions

For scenarios where direct USB redirection is needed:

### Commercial Solutions

#### USB Network Gate

**Features:**
- Encrypted USB tunneling
- RDP auto-connect functionality
- Cross-platform support (Windows/macOS/Linux)
- Single device access per session

**Setup:**
```powershell
# Install on YubiKey host machine
# Install client on remote machine
# Share YubiKey device through interface
# Connect from RDP session
```

#### Donglify

**Features:**
- Specializes in USB dongles
- Multiple simultaneous connections
- 2048-bit SSL encryption
- Cloud service compatibility

#### FlexiHub

**Features:**
- Universal USB & COM device sharing
- Tunnel server support
- Per-session device isolation
- Works through firewalls

### Open Source Alternatives

#### USB/IP (Linux/Windows)

```bash
# On host machine (where YubiKey is connected)
sudo modprobe usbip-host
sudo usbip list -l
sudo usbip bind -b [bus-id]
sudo usbipd -D

# On client machine
sudo modprobe vhci-hcd
sudo usbip attach -r [host-ip] -b [bus-id]
```

## Alternative Remote Access Methods

### VNC Instead of RDP

VNC bypasses RDP's smart card limitations by providing direct desktop access:

#### Installation and Setup

**Option 1: TightVNC (Recommended)**

```powershell
# Install via Chocolatey
choco install tightvnc

# Or download from https://www.tightvnc.com/
# Run installer as Administrator
```

**Option 2: UltraVNC**

```powershell
# Install via Chocolatey
choco install ultravnc

# Or download from https://www.uvnc.com/
```

**Option 3: RealVNC**

```powershell
# Install via Chocolatey  
choco install vnc-viewer vnc-connect

# Or download from https://www.realvnc.com/
```

#### Configuration Steps

**1. Configure VNC Server (Windows machine with YubiKey):**

```powershell
# For TightVNC - Configure via Control Panel
# Or edit registry directly:

# Set password (required)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v Password /t REG_BINARY /d [encrypted_password]

# Set port (default 5900)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v RfbPort /t REG_DWORD /d 5900

# Enable service auto-start
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v UseService /t REG_DWORD /d 1

# Allow connections
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v AcceptRfbConnections /t REG_DWORD /d 1
```

**2. Configure Windows Firewall:**

```powershell
# Allow VNC through Windows Firewall
New-NetFirewallRule -DisplayName "VNC Server" -Direction Inbound -Port 5900 -Protocol TCP -Action Allow

# For specific IP ranges only (recommended)
New-NetFirewallRule -DisplayName "VNC Server Restricted" -Direction Inbound -Port 5900 -Protocol TCP -RemoteAddress "192.168.1.0/24" -Action Allow
```

**3. Start VNC Service:**

```powershell
# Start TightVNC service
net start tvnserver

# Or start manually
"C:\Program Files\TightVNC\tvnserver.exe" -run
```

**4. Configure VNC for Security:**

```powershell
# Enable view-only access for demonstration
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v AcceptRfbConnections /t REG_DWORD /d 1

# Disable file transfers (optional)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v DisableFileTransfers /t REG_DWORD /d 1

# Set encryption (if supported by VNC variant)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v RequireAuth /t REG_DWORD /d 1
```

#### Client Connection

**From macOS:**
```bash
# Install VNC client
brew install --cask vnc-viewer

# Connect to Windows machine
open vnc://[windows-ip]:5900
```

**From Linux:**
```bash
# Install VNC client
sudo apt install remmina  # Ubuntu/Debian
sudo dnf install remmina  # Fedora

# Or use built-in VNC viewer
vncviewer [windows-ip]:5900
```

**From Windows:**
```powershell
# Install VNC Viewer
choco install vnc-viewer

# Connect via GUI or command line
"C:\Program Files\RealVNC\VNC Viewer\vncviewer.exe" [windows-ip]:5900
```

#### Advanced Configuration

**Enable SSL/TLS Encryption (UltraVNC):**

```powershell
# Generate SSL certificate
# Configure UltraVNC with SSL plugin
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ORL\WinVNC3" /v UsePlugin /t REG_DWORD /d 1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ORL\WinVNC3" /v Plugin /t REG_SZ /d "SecureVNCPlugin.dsm"
```

**Performance Optimization:**

```powershell
# Reduce color depth for better performance
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v PixelFormat /t REG_SZ /d "bgr233"

# Enable desktop effects optimization
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v RemoveWallpaper /t REG_DWORD /d 1
```

#### Troubleshooting VNC

**Common Issues:**

1. **Connection Refused:**
   ```powershell
   # Check if service is running
   Get-Service | Where-Object {$_.Name -like "*vnc*"}
   
   # Check port binding
   netstat -an | findstr :5900
   ```

2. **Black Screen:**
   ```powershell
   # Disable User Account Control prompts
   reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0
   
   # Configure service to interact with desktop
   sc config tvnserver type= interact
   ```

3. **Authentication Failed:**
   ```powershell
   # Reset VNC password via registry
   reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\TightVNC\Server" /v Password /f
   
   # Reconfigure via GUI
   "C:\Program Files\TightVNC\tvnserver.exe" -controlapp
   ```

#### Security Considerations for VNC

**Network Security:**
```powershell
# Use SSH tunnel for encrypted connection
ssh -L 5900:localhost:5900 user@windows-machine

# Then connect VNC client to localhost:5900
```

**Access Control:**
- Limit connections to specific IP addresses
- Use strong passwords (12+ characters)
- Consider VPN for internet connections
- Disable when not in use

**Benefits over RDP:**
- Direct USB access without redirection
- No smart card driver complications  
- Full hardware compatibility
- Works with any USB device
- No Windows licensing restrictions

## Architecture Solutions for ykpiv_desktop

### Service Wrapper Approach (Recommended)

Create a Windows service that manages YubiKey operations:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────┐
│   RDP Session   │───▶│  Service Wrapper │───▶│   YubiKey   │
│                 │    │  (Local Machine) │    │ (USB Port)  │
│ ykpiv_desktop   │    │                  │    │             │
│    Client       │    │  FFI → libykpiv  │    │   Hardware  │
└─────────────────┘    └──────────────────┘    └─────────────┘
```

**Implementation Steps:**

1. **Create Windows Service:**
   ```csharp
   // Service manages YubiKey operations
   // Exposes REST API or named pipes
   // Runs with LocalSystem privileges
   ```

2. **Modify Flutter Plugin:**
   ```dart
   // Add network client for remote operations
   // Fallback to local FFI when available
   // Maintain same API interface
   ```

3. **Communication Layer:**
   ```
   Options:
   - Named Pipes (Windows-specific, high performance)
   - REST API (cross-platform, easier debugging)
   - gRPC (type-safe, efficient)
   ```

### REST API Wrapper

```dart
// Example API endpoints
POST /piv/authenticate    // PIN verification
POST /piv/sign           // Sign operation
GET  /piv/certificates   // List certificates
POST /piv/generate       // Generate key pair
```

## Troubleshooting

### Common Issues

#### "Smart card not found" in RDP

**Solution:**
1. Verify INSTALL_LEGACY_NODE=1 was used
2. Check Smart Card service is running
3. Restart both machines
4. Try manual hardware addition

#### "Access denied" errors

**Solution:**
1. Run RDP as Administrator
2. Check Group Policy settings
3. Verify certificate store permissions

#### Application cannot access YubiKey

**Solution:**
1. Test with `certutil -scinfo`
2. Check if other applications can access
3. Consider service wrapper approach

#### USB Network Gate connection fails

**Solution:**
1. Check firewall settings
2. Verify network connectivity
3. Try different encryption settings
4. Check USB device permissions

### Debugging Commands

```cmd
# Check smart card status
certutil -scinfo

# List available certificates
certutil -store -user my

# Test PIV tool access
yubico-piv-tool -a status

# Check USB devices
Get-PnpDevice -Class SmartCardReader
```

### Logging

Enable detailed logging in your Flutter application:

```dart
// Add logging to YkpivDesktop operations
Logger.root.level = Level.ALL;
Logger.root.onRecord.listen((record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
});
```

## Security Considerations

### Risk Assessment

| Solution | Security Level | Complexity | Reliability |
|----------|---------------|------------|-------------|
| Smart Card Minidriver | High | Low | Medium |
| USB Network Gate | Medium | Medium | High |
| SSH Agent Forwarding | High | Low | High |
| VNC | Medium | Low | High |
| Service Wrapper | High | High | High |

### Best Practices

1. **Use encrypted connections** for all remote access
2. **Limit network exposure** of USB sharing services
3. **Implement audit logging** for all YubiKey operations
4. **Use certificate pinning** for API communications
5. **Enable touch policies** on YubiKey for additional security

### Network Security

```powershell
# Configure Windows Firewall for USB Network Gate
New-NetFirewallRule -DisplayName "USB Network Gate" -Direction Inbound -Port 33901 -Protocol TCP -Action Allow

# Restrict to specific IP ranges
New-NetFirewallRule -DisplayName "USB Network Gate Restricted" -Direction Inbound -Port 33901 -Protocol TCP -RemoteAddress "192.168.1.0/24" -Action Allow
```

## Performance Considerations

### Latency Impact

- **Local USB:** ~1ms operations
- **RDP Smart Card:** ~10-50ms additional latency
- **USB Network Gate:** ~50-200ms depending on network
- **VNC:** ~5-20ms additional latency

### Optimization Tips

1. **Use persistent connections** to reduce handshake overhead
2. **Implement connection pooling** for multiple operations
3. **Cache certificates** to reduce hardware queries
4. **Use compression** for network-based solutions

## Conclusion

For production environments, the recommended approach depends on your specific requirements:

- **High Security + Local Network:** Smart Card Minidriver with RDP
- **High Security + Internet:** SSH Agent Forwarding
- **Ease of Use + Reliability:** USB Network Gate
- **Custom Integration:** Service Wrapper approach

The ykpiv_desktop plugin can be adapted to work with any of these solutions through appropriate architectural changes.

## References

- [Yubico PIV Documentation](https://developers.yubico.com/PIV/)
- [Microsoft RDP Smart Card Redirection](https://docs.microsoft.com/en-us/azure/virtual-desktop/redirection-configure-smart-cards)
- [yubico-piv-tool Repository](https://github.com/Yubico/yubico-piv-tool)
- [Project README](./README.md)