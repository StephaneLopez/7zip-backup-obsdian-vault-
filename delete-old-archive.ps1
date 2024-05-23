<#
.SYNOPSIS
Script pour gérer les archives Obsidian-HM en conservant les plus récentes et en supprimant les autres.

.DESCRIPTION
Ce script PowerShell analyse les archives du dossier spécifié contenant les fichiers Obsidian-HM au format YYYY-MM-DD.7z.
Il conserve un nombre défini d'archives les plus récentes et supprime les archives excédentaires.

.PARAMETER ArchiveFolder
Le chemin complet vers le dossier contenant les archives.

.PARAMETER ArchivesToKeep
Le nombre d'archives à conserver. Les archives les plus récentes seront conservées, les autres seront supprimées.

.EXAMPLE
.\delete-old-archive.ps1 -ArchiveFolder "C:\Chemin\Vers\Le\Dossier" -ArchivesToKeep 5 -ArchiveBaseName "Nom de l'archive"

.NOTES
Auteur : Stéphane Lopez (avec chatGPT)
Date de création : 2023-08-28
Version : 1.0
#>

# Base du nom de l'archive
$archiveBaseName = "Obsidian-HM-"

# Chemin vers le dossier contenant les archives
$archiveFolder = "C:\Users\s.lopez\OneDrive\50-HM\Mes notes"

# Nombre d'archives à conserver
$archivesToKeep = 5

# Liste toutes les archives dans le dossier
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

    }
} else {
    Write-Host "Nombre d'archives insuffisant. Aucune suppression nécessaire."
}
