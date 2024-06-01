<#
.SYNOPSIS
Script de compression utilisant 7zip pour créer une archive à partir de plusieurs dossiers.  

.DESCRIPTION
Ce script PowerShell utilise l'outil 7zip pour compresser les contenus de plusieurs dossiers
dans une archive au format 7z. L'archive porte un nom basé sur la date de création du script.
Le script peut vérifier les archives créées et supprimer les archives les plus anciennes et en conserver un nombre max

.PARAMETER FolderPaths
Les chemins vers les dossiers à compresser.

.EXAMPLE
.\archive-obsidian.ps1 -FolderPaths @("C:\Chemin\Vers\DossierA", "C:\Chemin\Vers\DossierB")

.NOTES
Auteur : Stéphane Lopez avec l'aide de chatGPT
Date de création : 2023-08-28
Date de maj : 2024-05
Version : 2.0
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$BackupName = "Obsidian-Backup",
    [string[]]$FolderPaths = @("C:\SourceFolder1\To\Save"),
    [string]$ArchiveFolder = "C:\Target\Backup\Folder",
    [string]$7zipPath = (Get-Command 7z.exe).Source,
    [int]$ArchivesToKeep = 3,
    [bool]$Verif = $true,
    [bool]$Log = $true,
    [string]$FolderLog = "C:\Obsidian\Vault\Log Backup Folder\"
)

# Nom des archives générées
$archiveDate = Get-Date -Format "yyyy-MM-dd"
$archiveName = "$archiveDate-$BackupName.7z"
$archivePath = Join-Path -Path $ArchiveFolder -ChildPath $archiveName

# Log des opérations
$logNote = "Obsidian-backup-log.md"
$logLastBackupFile = "LastBackupLog.md"
$logPathTasks = Join-Path -Path $FolderLog -ChildPath $logNote
$lastBackupLogFile = Join-Path -Path $FolderLog -ChildPath $logLastBackupFile

# Vérifier si les dossiers existent
foreach ($folderPath in $FolderPaths) {
    if (-Not (Test-Path -Path $folderPath -PathType Container)) {
        Write-Error "Le dossier $folderPath n'existe pas."
        exit 1
    }
}

# Compresser les dossiers dans une archive au format 7z
$logLastBackup = & $7zipPath a -t7z $archivePath $FolderPaths

if ($?) {
    $logstring = "- [x] 🤖 [[$archiveDate]] - Backup de [$archiveName](file:\\$archivePath) 🆗|[[$logLastBackupFile|🗒️]]"
} else {
    $logstring = "- [-] 🤖 [[$archiveDate]] - Backup de [$archiveName](file:\\$archivePath) ❌|[[$logLastBackupFile|🗒️]]"
}

# Vérification de l'archive créée
if ($Verif) {
    & $7zipPath t $archivePath
    if ($?) {
        $logstring += " | Vérification 🆗"
    } else {
        $logstring += " | Vérification ❌"
    }
}

Write-Host $logLastBackup
Write-Host "Archive créée : $archivePath"
Write-Host $logstring

# Suppression des anciennes archives
$archives = Get-ChildItem -Path $ArchiveFolder -Filter "*.7z" | Sort-Object LastWriteTime -Descending

if ($archives.Count -gt $ArchivesToKeep) {
    $archivesToDelete = $archives.Count - $ArchivesToKeep

    for ($i = 0; $i -lt $archivesToDelete; $i++) {
        $archiveToDelete = $archives[$ArchivesToKeep + $i]
        Remove-Item -Path $archiveToDelete.FullName -Force
        Write-Host "Archive supprimée : $($archiveToDelete.Name)"
        $logLastBackup += "Archive supprimée : $($archiveToDelete.Name)"
    }

    $logstring += "suppression de $i / $($archives.Count)  ✅ $archiveDate `n"
} else {
    $logstring += "| suppression de 0 / $($archives.Count)  ✅ $archiveDate `n"
    Write-Host "Nombre d'archives insuffisant. Aucune suppression nécessaire."
}

if ($Log) {
    Add-Content -Path $logPathTasks -Value $logstring
    Add-Content -Path $lastBackupLogFile -Value $logLastBackup
}



