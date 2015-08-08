[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |  Out-Null

$ErrorActionPreference="SilentlyContinue"

Function Get-FileName($initialDirectory)
{   
	$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$OpenFileDialog.initialDirectory = $initialDirectory
	$OpenFileDialog.filter = "PowerShell Scripts (*.ps1)| *.ps1"
	$OpenFileDialog.ShowDialog() | Out-Null
	$OpenFileDialog.filename
 
}

$messageBox=[System.Windows.Forms.MessageBox]

$file=Get-FileName -initialDirectory "c:\"
$cert=get-childitem cert://CurrentUser/My -codesign
$timeStampServer="http://tsa.starfieldtech.com"

Set-AuthenticodeSignature $file $cert -timestampserver $timeStampServer | out-null

sleep 2

$SignerCertThumbprint=(Get-AuthenticodeSignature $file).SignerCertificate.Thumbprint
$TimeStamperCertThumbprint=(Get-AuthenticodeSignature $file).TimeStamperCertificate.Thumbprint
$Status=(Get-AuthenticodeSignature $file).Status

$SuccessValidMessage="Your script has been Signed and TimeStamped`n`nScript:`n     $file`n`nSigner Certificate Thumbprint:`n     $SignerCertThumbprint`n`nTimeStamper Certificate Thumbprint:`n     $TimeStamperCertThumbprint"
$SuccessValidTitle="Signing Successful, TimeStamped, Valid"

$FailedNotSignedMessage="Your script has not been Signed or TimeStamped.`n`nCould not find a Code-Signing Certificate in your certificate store.`n`nPlease import an existing Code-Signing certificate or request one from your Domain Administrator"
$FailedNotSignedTitle="Signing Failed, No Code-Signing Certificate Found"

$SuccessInvalideMessage="Your script has been Signed but could not be TimeStamped`n`nScript:`n     $file`n`nSigner Certificate Thumbprint:`n     $SignerCertThumbprint`n`nTimeStamper Certificate Thumbprint:`n     No TimeStamp`n`nPlease resolve.`nThe most probable cause is the TimeStamp server was unable to be contacted:`n     $timeStampServer"
$SuccessInvalideTitle="Signing Successful, Valid, No TimeStamp"

if($file -eq ""){

}
elseif($Status -eq "NotSigned"){

	$messageBox::Show($FailedNotSignedMessage,$FailedNotSignedTitle) | out-null

}
else{

	$messageBox::Show($SuccessValidMessage,$SuccessValidTitle) | out-null

}