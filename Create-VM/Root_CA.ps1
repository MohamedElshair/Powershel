### Create a CAPolicy.inf for the standalone offline root CA

New-Item -Path C:\Windows -Name CAPolicy.inf -ItemType File -Force

$content={[Version]
Signature=”$Windows NT$”
[PolicyStatementExtension]
Policies=InternalPolicy
[InternalPolicy]
OID= 1.2.3.4.1455.67.89.5
[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=20
CRLPeriod=Years
CRLPeriodUnits=20
CRLDeltaPeriod=Days
CRLDeltaPeriodUnits=0
LoadDefaultTemplates=0}

Add-Content -Value $content -Path C:\Windows\CAPolicy.inf

### To define Active Directory Configuration Partition Distinguished Name ###
Certutil -setreg CA\DSConfigDN "CN=Configuration,DC=Itoutbreak,DC=net"
Certutil -setreg CA\DSDomain "dc=itoutbreak,dc=net"

### To define CRL Overlap Period Units and CRL Overlap Period ###
Certutil -setreg CA\CRLOverlapPeriodUnits 3
Certutil -setreg CA\CRLOverlapPeriod "Weeks"

### To define Validity Period Units for all issued certificates by this CA ###
Certutil -setreg CA\ValidityPeriodUnits 10
Certutil -setreg CA\ValidityPeriod "Years"