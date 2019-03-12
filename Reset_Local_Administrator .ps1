

$Computers = Get-Content -Path "path to txt file with servers" # type full path to txt file

$password = Read-Host -Prompt "Enter password" -AsSecureString
$confirmpassword = Read-Host "Confirm the Password" -AsSecureString

$password1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$password2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmpassword))

if($password1 -ne $password2){
    Write-Error "The Passwords did not match, please re-run the script and type them in correctly - Terminating"
    EXIT
}



foreach ($Computer in $Computers) {

    $Computer
    $User = [ADSI]"WinNT://$Computer/Admninistrator,User" # please be aware if you renamed your admin account to rename it here as well
    $User.SetPassword($decodedpassword)
    $User.SetInfo()

}
