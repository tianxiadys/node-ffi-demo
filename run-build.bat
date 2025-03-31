del /F /Q /S "..\node\deps\libffi"
xcopy /S /Y ".\src" "..\node"
cmd /C "..\node\vcbuild.bat debug ffi"
