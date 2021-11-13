@echo off

set baseURL=https://github.com/Butterstroke/project-templates/trunk/
set baseDIR=%~dp0

REM Can't have a project without a name.
set project-name="%1"

if %project-name%=="" ( goto define-all )
goto define-none

:define-all
    echo Project name is not given...
    set /p project-name="What would you like to call it? " 

    echo Project type is not given...
    set /p project-type=Template would you like? 

    set project-type="%project-type%/"

    echo Project not defined as private or public...
    set /p project-public=Should this be public? (y/n) 

    set project-public="%project-public%"

    goto verify-info
)

:define-none
    REM Must be of an existing project template
    set project-type="%2/"

    REM Will be set to private by default
    set project-public="%3"

    goto verify-info

:verify-info
    if %project-name%=="" (
        set error-message=Name not defined for project. Failed to continue.
        goto error-exit
    ) 

    if %project-type%=="" (
        set error-message=Type not defined for project. Failed to continue.
        goto error-exit   
    ) 

    set project-name=%project-name:"=%

    set valid-type="n"

    FOR /F "tokens=* USEBACKQ" %%g IN (`svn list %baseURL%`) do (
        if "%%g"==%project-type% ( set valid-type="y" )
    )

    if %valid-type%=="n" (
        set error-message=Type does not exist in repository. Failed to continue.
        goto error-exit
    )

    if %project-public%=="" ( set project-public="n" )
    if %project-public%=="public" ( set project-public="y" )
    if %project-public%=="private" ( set project-public="n" )

    if NOT %project-public%=="y" (
        if NOT %project-public%=="n" (
            set error-message=Invalid property for public argument. Failed to continue.
            goto error-exit
        )
    )

    goto process-project

:error-exit 
echo.
echo %error-message%
pause
exit /b 1 

:process-project
echo.
echo Running with these settings...
echo.
echo project-name: %project-name%
echo project-type: %project-type%
echo project-public: %project-public%

echo.
echo Current Directory: %~dp0
set repository-path=""
set /p repository-path=What directory should the new repository be in? (Leave blank for current directory) 

if %repository-path%=="" ( set repository-path=%~dp0 )

cd /d %repository-path%

echo Set target directory: %repository-path%
echo Downloading template: %project-type%

svn checkout %baseURL%%project-type%

echo Renaming template to %project-name%

RENAME %project-type% %project-name%

echo Template generated.

cd %project-name%

echo Removing SVN folder

IF EXIST .svn RMDIR /S /Q .svn

echo Removed SVN folder

echo Uploading repository to GitHub

if %project-public%=="y" (
    set project-public="--public"
)
if %project-public%=="n" (
    set project-public="--private"
)

set description=""
set /p description=Would you like to add a description? (Leave blank for no) 

if "%description%"=="" ( 
    set description=""
) else (
    set description="-d %description%"
)

git init -b stable

gh repo create %project-name% --enable-wiki=false %project-public% %description% -y

git add . && git commit -m "initial commit" && git push --set-upstream origin stable

echo Finished uploading to GitHub

cd %baseDIR%
echo Script Completed.