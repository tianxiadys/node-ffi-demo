del /F /Q /S "..\node\deps\libffi"
xcopy /S /Y ".\src" "..\node"
rem cmd /C "..\node\vcbuild.bat debug ffi"
