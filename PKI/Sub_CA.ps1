### Create CAPolicy.inf for Enterprise Root CA
New-Item -Path C:\Windows -Name CAPolicy.inf -ItemType File -Force
$content1={[Version]
Signature=”$Windows NT$”
[PolicyStatementExtension]
Policies=InternalPolicy
[InternalPolicy]
OID= 1.2.3.4.1455.67.89.5
[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=10
LoadDefaultTemplates=0 }

Add-Content -Value $content1 -Path C:\Windows\CAPolicy.inf

New-Item -Path C:\ -Name Script.ps1 -ItemType File -Force

$content2={### Publish the Root CA Certificate and CRL
certutil -f -dspublish "A:\CA01_Fabrikam Root CA.crt" RootCA
certutil -f -dspublish "A:\Fabrikam Root CA.crl" RootCA

### To add  Root CA Certificate and CRL in local store
certutil -addstore -f root "CA01_Itoutbreak Root CA.crt"
certutil -addstore -f root "Itoutbreak Root CA.crl"


### Perform Post Installation Configuration Tasks on the Subordinate Issuing CA

Certutil -setreg CA\CRLPeriodUnits 1
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 1
Certutil -setreg CA\CRLDeltaPeriod "Days"
### Define CRL overlap settings by running the following command from an administrative command prompt:
Certutil -setreg CA\CRLOverlapPeriodUnits 12
Certutil -setreg CA\CRLOverlapPeriod "Hours"

Certutil -setreg CA\ValidityPeriodUnits 5
Certutil -setreg CA\ValidityPeriod "Years"}

Add-Content -Value $content2 C:\Script.ps1 -Force