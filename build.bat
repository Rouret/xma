@echo off
setlocal enabledelayedexpansion

:: Chemins
set LOVE_PATH="C:\Program Files\LOVE"
set OUTPUT_DIR=dist
set GAME_NAME=xma
set VERSION_FILE=version.txt
set TEMP_LOVE_FILE=%GAME_NAME%.love


:: Créer le dossier de distribution
if not exist %OUTPUT_DIR% (
    mkdir %OUTPUT_DIR%
)

:: Vérifier le fichier version.txt
if not exist %VERSION_FILE% (
    echo 1.0.0 > %VERSION_FILE%
)

:: Lire et incrémenter la version
set /p VERSION=<%VERSION_FILE%
echo Version actuelle : %VERSION%

:: Créer un fichier ZIP en tant que .love
echo Compression des fichiers dans %TEMP_LOVE_FILE%...

"C:\Program Files\7-Zip\7z.exe" a -tzip ./%TEMP_LOVE_FILE% *

if not exist %TEMP_LOVE_FILE% (
    echo [ERREUR] Echec de la création du fichier .love.
    exit /b 1
)

:: Combiner LÖVE et le fichier .love pour créer un exécutable
echo Création de l'exécutable...
echo %LOVE_PATH%\love.exe+%TEMP_LOVE_FILE% %OUTPUT_DIR%\%GAME_NAME%_%VERSION%.exe
copy /b %LOVE_PATH%\love.exe+%TEMP_LOVE_FILE% %OUTPUT_DIR%\%GAME_NAME%_%VERSION%.exe >nul

if not exist %OUTPUT_DIR%\%GAME_NAME%_%VERSION%.exe (
    echo [ERREUR] Echec de la création de l'exécutable.
    exit /b 1
)

:: Copier les DLL nécessaires
echo Copie des bibliothèques nécessaires...
copy %LOVE_PATH%\*.dll %OUTPUT_DIR% >nul

:: Supprimer le fichier temporaire .love
del %TEMP_LOVE_FILE%

:: Incrémenter la version
echo Incrémentation de la version...
for /f "tokens=1-3 delims=." %%a in ("%VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

:: Augmenter le numéro de patch
set /a PATCH+=1
set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!
echo Nouvelle version : %NEW_VERSION%
echo %NEW_VERSION% > %VERSION_FILE%

echo [SUCCÈS] Build terminé. Exécutable : %OUTPUT_DIR%\%GAME_NAME%_%VERSION%.exe
exit /b 0
