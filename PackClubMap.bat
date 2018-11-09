pushd "%~dp0"
Set /P _version=<version 
rm -f -r output\windows\Release_Qt
D:\Qt\5.11.2\msvc2017_64\bin\windeployqt.exe --qmldir clubmap --dir output\windows\Release_Qt output\windows\Release\ClubMap.exe
cp output\windows\Release\ClubMap.exe output\windows\Release_Qt\
cd output\windows\
rm -f ClubMapQt-release*.7z
"C:\Program Files (x86)\7-Zip\7z.exe" a ClubMapQt-release-%_version%.7z Release_Qt
rm -f -r Release_Qt
cd ..\..

rm -f -r output\windows\CryptoComm\Debug_Qt
D:\Qt\5.11.2\msvc2017_64\bin\windeployqt.exe --qmldir clubmap --dir output\windows\Debug_Qt output\windows\Debug\ClubMap.exe
cp output\windows\Debug\ClubMap.exe output\windows\Debug_Qt\
cd output\windows\
rm -f ClubMapQt-debug*.7z
"C:\Program Files (x86)\7-Zip\7z.exe" a ClubMapQt-debug-%_version%.7z Debug_Qt
rm -f -r Debug_Qt
cd ..\..\..\..

popd
