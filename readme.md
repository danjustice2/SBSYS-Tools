# SBSYS Kun Én Instans

Dette repository indeholder PowerShell-scripts designet til at administrere og overvåge SBSYS-applikationen, så kun én instans af applikationen kører ad gangen, samt til at levere backup-funktionalitet til kladder.

## Funktioner

### 1. `sbsys-kun-een.ps1`
- Sikrer, at kun én instans af SBSYS-applikationen kører.
- Viser advarselsmeddelelser, hvis flere instanser opdages.
- Starter SBSYS-applikationen, hvis den ikke allerede kører.
- Kan valgfrit køre et ekstra script, der angives som et argument.

### 2. `backup_watcher.ps1`
- Overvåger en specificeret mappe for filændringer.
- Opretter automatisk tidsstemplede backups af ændrede eller nyoprettede filer.
- Logger alle aktiviteter i en logfil til revisionsformål.
- Stopper overvågning, hvis SBSYS-applikationen ikke kører.
- Tilføjer en genvej til backup-mappen på brugerens skrivebord for nem adgang.

### 3. `daily_cleanup.ps1`
- Fjerner automatisk gamle filer (ældre end 7 dage) fra backup-mappen.
- Rydder op i tomme mapper for at holde backup-strukturen ren og organiseret.

## Brug

### Kørsel af `sbsys-kun-een.ps1`
1. Åbn PowerShell.
2. Naviger til mappen, der indeholder scriptet.
3. Kør scriptet:
   ```powershell
   .\sbsys-kun-een.ps1
   ```
4. Angiv eventuelt en ekstra scriptsti som et argument:
   ```powershell
   .\sbsys-kun-een.ps1 "sti\til\ekstra\script.ps1"
   ```

### Kørsel af `backup_watcher.ps1`
1. Åbn PowerShell.
2. Naviger til mappen, der indeholder scriptet.
3. Kør scriptet:
   ```powershell
   .\backup_watcher.ps1
   ```

### Kørsel af `daily_cleanup.ps1`
1. Åbn PowerShell.
2. Naviger til mappen, der indeholder scriptet.
3. Kør scriptet:
   ```powershell
   .\daily_cleanup.ps1
   ```

## Konfiguration

### `sbsys-kun-een.ps1`
- Opdater variablerne `$exePath` og `$parameters` til at matche dit SBSYS-miljø.
- Tilpas `$timestampFile` og `$minimumIntervalSeconds` efter behov.

### `backup_watcher.ps1`
- Indstil variablerne `$sourceFolder` og `$backupRoot` til de ønskede kilde- og backup-mapper.
- Opdater `$sbsysExePath` til stien til SBSYS-applikationens eksekverbare fil.

## Logning

Begge scripts genererer logfiler til sporing af deres aktiviteter:
- `sbsys-kun-een.ps1` bruger en tidsstempelfil til at forhindre flere hurtige eksekveringer.
- `backup_watcher.ps1` logger alle filændringer og backup-aktiviteter i en logfil i samme mappe.

## Licens

Dette projekt er tilgængeligt under MIT-licensen. Se LICENSE-filen for flere detaljer.

## Bidrag

Hvis du synes der mangler noget er du velkommen til at skrive om på koden! Fork repo'et og indsend en pull request med dine ændringer.

Hvis du ikke kender så meget til kode er du også velkommen til at skrive under fanen 'Issues', eller sende en mail til darju -snabel-a- toender.dk.