cd src
luastatic main.lua controllers/ParserBNF.lua controllers/FirstGenerator.lua controllers/FollowGenerator.lua models/business/GenerateJava.lua models/business/GenerateLua.lua models/business/GeneratePython.lua /usr/lib/x86_64-linux-gnu/liblua5.3.a -I/usr/include/lua5.3
mv main ../

CC=x86_64-w64-mingw32-gcc luastatic main.lua controllers/ParserBNF.lua controllers/FirstGenerator.lua controllers/FollowGenerator.lua models/business/GenerateJava.lua models/business/GenerateLua.lua models/business/GeneratePython.lua ../lua5.3-lib/windows/liblua.a -I/usr/include/lua5.3 -lpthread
strip main.exe
mv main.exe ../
