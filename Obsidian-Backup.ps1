<#
.SYNOPSIS
Script de compression utilisant 7zip pour créer une archive à partir de plusieurs dossiers.
Il 


.DESCRIPTION
Ce script PowerShell utilise l'outil 7zip pour compresser les contenus de plusieurs dossiers
dans une archive au format 7z. L'archive porte un nom basé sur la date de création du script.

.PARAMETER FolderPaths
Les chemins vers les dossiers à compresser.

.EXAMPLE
.\archive-obsidian.ps1 -FolderPaths @("C:\Chemin\Vers\DossierA", "C:\Chemin\Vers\DossierB")

.NOTES
Auteur : Stéphane Lopez avec l'aide de chatGPT
Date de création : 2023-08/28
Date de maj : 2024-05
Version : 2.0
#>

### Paramétrages obligatoires ###
# Chemins vers les dossiers que à compresser
$folderPaths = @("C:\Users\s.lopez\OneDrive\90-Documents - stephane@simplixite.fr\Obsidian-Test-Vault\Test de Vault")

# Chemin vers le dossier contenant les archives
$archiveFolder = "C:\Temp\backup\"

### Paramétrages facultatifs ### 
# Chemin vers l'exécutable 7zip dans le path (ou manuellement) 
$7zipPath = (Get-Command 7z.exe).source  # $7zipPath = "C:\path\to\7z.exe"

# Nom des archives générés
$archiveDate = Get-Date -Format "yyyy-MM-dd"
$archiveName = "Obsidian-Backup-$archiveDate.7z"

# Vérification de l'archive généré (ou pas) 
$verif = $true

# Nombre d'archives à conserver
$archivesToKeep = 3

# Log des opérations
$log = $true
$folderLog = "C:\Users\s.lopez\Documents\Partage-Obsidian\ZZZ-Test\Backup\"
$logNote = "Obsidian-backup-log.md"
$logLastBackupFile = "LastBackupLog.md"

# Concaténation des chemins 
$logPathTasks = $folderLog+ $logNote                    # Log regroupé pour le suivi dans Obsidian
$lastBackupLogFile = $folderLog+$logLastBackupFile      # Log du dernier job d'archivage pour savoir ce qui c'est passé en cas de souci
$archivePath = $archiveFolder + $archiveName            # Chemin complet vers l'emplacement où l'archive sera créée

### Compresser les dossiers dans une archive au format 7z
$logLastBackup = & $7zipPath a -t7z $archivePath $folderPaths  

if ($?  ){
    $logstring = "- [x] 🤖 [[$archiveDate]] - Backup de [$archiveName](file:\\$archivePath) 🆗|[[$logLastBackupFile|🗒️]]"
}else{
    $logstring = "- [-] 🤖 [[$archiveDate]] - Backup de [$archiveName](file:\\$archivePath) ❌|[[$logLastBackupFile|🗒️]]"
}


### Verification de l'archive créé
if ($verif){
    & $7zipPath t $archivePath
    if ($?){
        $logstring += " | Vérification 🆗"
    }else{
        $logstring += " | Vérification ❌"
    }
}

Write-Host $logLastBackup
Write-Host "Archive créée : $archivePath"
Write-Host $logstring



### Suppression des anciennes archives
# Liste toutes les archives dans le dossier d'archive
$archives = Get-ChildItem -Path $archiveFolder -Filter $archiveBaseName"*.7z" | Sort-Object LastWriteTime -Descending

# Vérifie s'il y a plus d'archives que celles à conserver
if ($archives.Count -gt $archivesToKeep) {
    # Calcule le nombre d'archives à supprimer
    $archivesToDelete = $archives.Count - $archivesToKeep

    # Supprime les archives excédentaires
    for ($i = 0; $i -lt $archivesToDelete; $i++) {
        $archiveToDelete = $archives[$archivesToKeep + $i]
        Remove-Item -Path $archiveToDelete.FullName -Force
        Write-Host "Archive supprimée : $($archiveToDelete.Name)"
        $logLastBackup += "Archive supprimée : $($archiveToDelete.Name)"

    }

    $logstring += "suppression de $i / $($archives.Count)  ✅ $archiveDate `n"

} else {
    $logstring += "| suppression de 0 / $($archives.Count)  ✅ $archiveDate `n"
    Write-Host "Nombre d'archives insuffisant. Aucune suppression nécessaire."
}

if ($log){
    Add-Content -Path $logPathTasks -Value $logstring
    Add-Content -Path $lastBackupLogFile -Value $logLastBackup
}
