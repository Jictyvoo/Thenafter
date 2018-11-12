cd src
luastatic main.lua controllers/ParserBNF.lua controllers/FirstGenerator.lua models/business/GenerateJava.lua models/business/GenerateLua.lua models/business/GeneratePython.lua /usr/lib/x86_64-linux-gnu/liblua5.3.a -I/usr/include/lua5.3
mv main ../
