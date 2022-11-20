$Servers = '172.18.3.39','172.18.3.40'

foreach ( $Server in $Servers ) 
{ping -a $Server -n 1 }


