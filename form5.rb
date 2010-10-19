#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'hr_util.rb'
require 'res_util.rb'

allnil = Array.new

c = CGI::new

f5year = c['f5year'].to_s
f5pname = c['f5pname'].to_s
f5pcode = c['f5pcode'].to_s
f5hname = c['f5hname'].to_s
f5hcode  = c['f5hcode'].to_s
f501001 = c['f501001'].to_s.tr('-,','')
allnil.push(f501001)
f501001 = '0' if (f501001.to_s.length == 0)
f501002 = c['f501002'].to_s.tr('-,','')
allnil.push(f501002)
f501002 = '0' if (f501002.to_s.length == 0)
f501003 = c['f501003'].to_s.tr('-,','')
allnil.push(f501003)
f501003 = '0' if (f501003.to_s.length == 0)
f501004 = c['f501004'].to_s.tr('-,','')
allnil.push(f501004)
f501004 = '0' if (f501004.to_s.length == 0)
f502001 = c['f502001'].to_s.tr('-,','')
allnil.push(f502001)
f502001 = '0' if (f502001.to_s.length == 0)
f502002 = c['f502002'].to_s.tr('-,','')
allnil.push(f502002)
f502002 = '0' if (f502002.to_s.length == 0)
f502003 = c['f502003'].to_s.tr('-,','')
allnil.push(f502003)
f502003 = '0' if (f502003.to_s.length == 0)
f502004 = c['f502004'].to_s.tr('-,','')
allnil.push(f502004)
f502004 = '0' if (f502004.to_s.length == 0)
f503001 = c['f503001'].to_s.tr('-,','')
allnil.push(f503001)
f503001 = '0' if (f503001.to_s.length == 0)
f503002 = c['f503002'].to_s.tr('-,','')
allnil.push(f503002)
f503002 = '0' if (f503002.to_s.length == 0)
f503003 = c['f503003'].to_s.tr('-,','')
allnil.push(f503003)
f503003 = '0' if (f503003.to_s.length == 0)
f503004 = c['f503004'].to_s.tr('-,','')
allnil.push(f503004)
f503004 = '0' if (f503004.to_s.length == 0)
f504001 = c['f504001'].to_s.tr('-,','')
allnil.push(f504001)
f504001 = '0' if (f504001.to_s.length == 0)
f504002 = c['f504002'].to_s.tr('-,','')
allnil.push(f504002)
f504002 = '0' if (f504002.to_s.length == 0)
f504003 = c['f504003'].to_s.tr('-,','')
allnil.push(f504003)
f504003 = '0' if (f504003.to_s.length == 0)
f504004 = c['f504004'].to_s.tr('-,','')
allnil.push(f504004)
f504004 = '0' if (f504004.to_s.length == 0)
f505001 = c['f505001'].to_s.tr('-,','')
allnil.push(f505001)
f505001 = '0' if (f505001.to_s.length == 0)
f505002 = c['f505002'].to_s.tr('-,','')
allnil.push(f505002)
f505002 = '0' if (f505002.to_s.length == 0)
f505003 = c['f505003'].to_s.tr('-,','')
allnil.push(f505003)
f505003 = '0' if (f505003.to_s.length == 0)
f505004 = c['f505004'].to_s.tr('-,','')
allnil.push(f505004)
f505004 = '0' if (f505004.to_s.length == 0)
f506001 = c['f506001'].to_s.tr('-,','')
allnil.push(f506001)
f506001 = '0' if (f506001.to_s.length == 0)
f506002 = c['f506002'].to_s.tr('-,','')
allnil.push(f506002)
f506002 = '0' if (f506002.to_s.length == 0)
f506003 = c['f506003'].to_s.tr('-,','')
allnil.push(f506003)
f506003 = '0' if (f506003.to_s.length == 0)
f506004 = c['f506004'].to_s.tr('-,','')
allnil.push(f506004)
f506004 = '0' if (f506004.to_s.length == 0)
f507001 = c['f507001'].to_s.tr('-,','')
allnil.push(f507001)
f507001 = '0' if (f507001.to_s.length == 0)
f507002 = c['f507002'].to_s.tr('-,','')
allnil.push(f507002)
f507002 = '0' if (f507002.to_s.length == 0)
f507003 = c['f507003'].to_s.tr('-,','')
allnil.push(f507003)
f507003 = '0' if (f507003.to_s.length == 0)
f507004 = c['f507004'].to_s.tr('-,','')
allnil.push(f507004)
f507004 = '0' if (f507004.to_s.length == 0)
f508001 = c['f508001'].to_s.tr('-,','')
allnil.push(f508001)
f508001 = '0' if (f508001.to_s.length == 0)
f508002 = c['f508002'].to_s.tr('-,','')
allnil.push(f508002)
f508002 = '0' if (f508002.to_s.length == 0)
f508003 = c['f508003'].to_s.tr('-,','')
allnil.push(f508003)
f508003 = '0' if (f508003.to_s.length == 0)
f508004 = c['f508004'].to_s.tr('-,','')
allnil.push(f508004)
f508004 = '0' if (f508004.to_s.length == 0)
f509001 = c['f509001'].to_s.tr('-,','')
allnil.push(f509001)
f509001 = '0' if (f509001.to_s.length == 0)
f509002 = c['f509002'].to_s.tr('-,','')
allnil.push(f509002)
f509002 = '0' if (f509002.to_s.length == 0)
f509003 = c['f509003'].to_s.tr('-,','')
allnil.push(f509003)
f509003 = '0' if (f509003.to_s.length == 0)
f509004 = c['f509004'].to_s.tr('-,','')
allnil.push(f509004)
f509004 = '0' if (f509004.to_s.length == 0)
f510001 = c['f510001'].to_s.tr('-,','')
allnil.push(f510001)
f510001 = '0' if (f510001.to_s.length == 0)
f510002 = c['f510002'].to_s.tr('-,','')
allnil.push(f510002)
f510002 = '0' if (f510002.to_s.length == 0)
f510003 = c['f510003'].to_s.tr('-,','')
allnil.push(f510003)
f510003 = '0' if (f510003.to_s.length == 0)
f510004 = c['f510004'].to_s.tr('-,','')
allnil.push(f510004)
f510004 = '0' if (f510004.to_s.length == 0)
f511001 = c['f511001'].to_s.tr('-,','')
allnil.push(f511001)
f511001 = '0' if (f511001.to_s.length == 0)
f511002 = c['f511002'].to_s.tr('-,','')
allnil.push(f511002)
f511002 = '0' if (f511002.to_s.length == 0)
f511003 = c['f511003'].to_s.tr('-,','')
allnil.push(f511003)
f511003 = '0' if (f511003.to_s.length == 0)
f511004 = c['f511004'].to_s.tr('-,','')
allnil.push(f511004)
f511004 = '0' if (f511004.to_s.length == 0)
f512001 = c['f512001'].to_s.tr('-,','')
allnil.push(f512001)
f512001 = '0' if (f512001.to_s.length == 0)
f512002 = c['f512002'].to_s.tr('-,','')
allnil.push(f512002)
f512002 = '0' if (f512002.to_s.length == 0)
f512003 = c['f512003'].to_s.tr('-,','')
allnil.push(f512003)
f512003 = '0' if (f512003.to_s.length == 0)
f512004 = c['f512004'].to_s.tr('-,','')
allnil.push(f512004)
f512004 = '0' if (f512004.to_s.length == 0)
f513001 = c['f513001'].to_s.tr('-,','')
allnil.push(f513001)
f513001 = '0' if (f513001.to_s.length == 0)
f513002 = c['f513002'].to_s.tr('-,','')
allnil.push(f513002)
f513002 = '0' if (f513002.to_s.length == 0)
f513003 = c['f513003'].to_s.tr('-,','')
allnil.push(f513003)
f513003 = '0' if (f513003.to_s.length == 0)
f513004 = c['f513004'].to_s.tr('-,','')
allnil.push(f513004)
f513004 = '0' if (f513004.to_s.length == 0)
f514001 = c['f514001'].to_s.tr('-,','')
allnil.push(f514001)
f514001 = '0' if (f514001.to_s.length == 0)
f514002 = c['f514002'].to_s.tr('-,','')
allnil.push(f514002)
f514002 = '0' if (f514002.to_s.length == 0)
f514003 = c['f514003'].to_s.tr('-,','')
allnil.push(f514003)
f514003 = '0' if (f514003.to_s.length == 0)
f514004 = c['f514004'].to_s.tr('-,','')
allnil.push(f514004)
f514004 = '0' if (f514004.to_s.length == 0)
f515001 = c['f515001'].to_s.tr('-,','')
allnil.push(f515001)
f515001 = '0' if (f515001.to_s.length == 0)
f515002 = c['f515002'].to_s.tr('-,','')
allnil.push(f515002)
f515002 = '0' if (f515002.to_s.length == 0)
f515003 = c['f515003'].to_s.tr('-,','')
allnil.push(f515003)
f515003 = '0' if (f515003.to_s.length == 0)
f515004 = c['f515004'].to_s.tr('-,','')
allnil.push(f515004)
f515004 = '0' if (f515004.to_s.length == 0)
f516001 = c['f516001'].to_s.tr('-,','')
allnil.push(f516001)
f516001 = '0' if (f516001.to_s.length == 0)
f516002 = c['f516002'].to_s.tr('-,','')
allnil.push(f516002)
f516002 = '0' if (f516002.to_s.length == 0)
f516003 = c['f516003'].to_s.tr('-,','')
allnil.push(f516003)
f516003 = '0' if (f516003.to_s.length == 0)
f516004 = c['f516004'].to_s.tr('-,','')
allnil.push(f516004)
f516004 = '0' if (f516004.to_s.length == 0)
f517001 = c['f517001'].to_s.tr('-,','')
allnil.push(f517001)
f517001 = '0' if (f517001.to_s.length == 0)
f517002 = c['f517002'].to_s.tr('-,','')
allnil.push(f517002)
f517002 = '0' if (f517002.to_s.length == 0)
f517003 = c['f517003'].to_s.tr('-,','')
allnil.push(f517003)
f517003 = '0' if (f517003.to_s.length == 0)
f517004 = c['f517004'].to_s.tr('-,','')
allnil.push(f517004)
f517004 = '0' if (f517004.to_s.length == 0)
f518001 = c['f518001'].to_s.tr('-,','')
allnil.push(f518001)
f518001 = '0' if (f518001.to_s.length == 0)
f518002 = c['f518002'].to_s.tr('-,','')
allnil.push(f518002)
f518002 = '0' if (f518002.to_s.length == 0)
f518003 = c['f518003'].to_s.tr('-,','')
allnil.push(f518003)
f518003 = '0' if (f518003.to_s.length == 0)
f518004 = c['f518004'].to_s.tr('-,','')
allnil.push(f518004)
f518004 = '0' if (f518004.to_s.length == 0)
f519001 = c['f519001'].to_s.tr('-,','')
allnil.push(f519001)
f519001 = '0' if (f519001.to_s.length == 0)
f519002 = c['f519002'].to_s.tr('-,','')
allnil.push(f519002)
f519002 = '0' if (f519002.to_s.length == 0)
f519003 = c['f519003'].to_s.tr('-,','')
allnil.push(f519003)
f519003 = '0' if (f519003.to_s.length == 0)
f519004 = c['f519004'].to_s.tr('-,','')
allnil.push(f519004)
f519004 = '0' if (f519004.to_s.length == 0)
f520001 = c['f520001'].to_s.tr('-,','')
allnil.push(f520001)
f520001 = '0' if (f520001.to_s.length == 0)
f520002 = c['f520002'].to_s.tr('-,','')
allnil.push(f520002)
f520002 = '0' if (f520002.to_s.length == 0)
f520003 = c['f520003'].to_s.tr('-,','')
allnil.push(f520003)
f520003 = '0' if (f520003.to_s.length == 0)
f520004 = c['f520004'].to_s.tr('-,','')
allnil.push(f520004)
f520004 = '0' if (f520004.to_s.length == 0)
f521001 = c['f521001'].to_s.tr('-,','')
allnil.push(f521001)
f521001 = '0' if (f521001.to_s.length == 0)
f521002 = c['f521002'].to_s.tr('-,','')
allnil.push(f521002)
f521002 = '0' if (f521002.to_s.length == 0)
f521003 = c['f521003'].to_s.tr('-,','')
allnil.push(f521003)
f521003 = '0' if (f521003.to_s.length == 0)
f521004 = c['f521004'].to_s.tr('-,','')
allnil.push(f521004)
f521004 = '0' if (f521004.to_s.length == 0)
f522001 = c['f522001'].to_s.tr('-,','')
allnil.push(f522001)
f522001 = '0' if (f522001.to_s.length == 0)
f522002 = c['f522002'].to_s.tr('-,','')
allnil.push(f522002)
f522002 = '0' if (f522002.to_s.length == 0)
f522003 = c['f522003'].to_s.tr('-,','')
allnil.push(f522003)
f522003 = '0' if (f522003.to_s.length == 0)
f522004 = c['f522004'].to_s.tr('-,','')
allnil.push(f522004)
f522004 = '0' if (f522004.to_s.length == 0)
f523001 = c['f523001'].to_s.tr('-,','')
allnil.push(f523001)
f523001 = '0' if (f523001.to_s.length == 0)
f523002 = c['f523002'].to_s.tr('-,','')
allnil.push(f523002)
f523002 = '0' if (f523002.to_s.length == 0)
f523003 = c['f523003'].to_s.tr('-,','')
allnil.push(f523003)
f523003 = '0' if (f523003.to_s.length == 0)
f523004 = c['f523004'].to_s.tr('-,','')
allnil.push(f523004)
f523004 = '0' if (f523004.to_s.length == 0)
f524001 = c['f524001'].to_s.tr('-,','')
allnil.push(f524001)
f524001 = '0' if (f524001.to_s.length == 0)
f524002 = c['f524002'].to_s.tr('-,','')
allnil.push(f524002)
f524002 = '0' if (f524002.to_s.length == 0)
f524003 = c['f524003'].to_s.tr('-,','')
allnil.push(f524003)
f524003 = '0' if (f524003.to_s.length == 0)
f524004 = c['f524004'].to_s.tr('-,','')
allnil.push(f524004)
f524004 = '0' if (f524004.to_s.length == 0)
f525001 = c['f525001'].to_s.tr('-,','')
allnil.push(f525001)
f525001 = '0' if (f525001.to_s.length == 0)
f525002 = c['f525002'].to_s.tr('-,','')
allnil.push(f525002)
f525002 = '0' if (f525002.to_s.length == 0)
f525003 = c['f525003'].to_s.tr('-,','')
allnil.push(f525003)
f525003 = '0' if (f525003.to_s.length == 0)
f525004 = c['f525004'].to_s.tr('-,','')
allnil.push(f525004)
f525004 = '0' if (f525004.to_s.length == 0)
f526001 = c['f526001'].to_s.tr('-,','')
allnil.push(f526001)
f526001 = '0' if (f526001.to_s.length == 0)
f526002 = c['f526002'].to_s.tr('-,','')
allnil.push(f526002)
f526002 = '0' if (f526002.to_s.length == 0)
f526003 = c['f526003'].to_s.tr('-,','')
allnil.push(f526003)
f526003 = '0' if (f526003.to_s.length == 0)
f526004 = c['f526004'].to_s.tr('-,','')
allnil.push(f526004)
f526004 = '0' if (f526004.to_s.length == 0)
f527001 = c['f527001'].to_s.tr('-,','')
allnil.push(f527001)
f527001 = '0' if (f527001.to_s.length == 0)
f527002 = c['f527002'].to_s.tr('-,','')
allnil.push(f527002)
f527002 = '0' if (f527002.to_s.length == 0)
f527003 = c['f527003'].to_s.tr('-,','')
allnil.push(f527003)
f527003 = '0' if (f527003.to_s.length == 0)
f527004 = c['f527004'].to_s.tr('-,','')
allnil.push(f527004)
f527004 = '0' if (f527004.to_s.length == 0)
f528001 = c['f528001'].to_s.tr('-,','')
allnil.push(f528001)
f528001 = '0' if (f528001.to_s.length == 0)
f528002 = c['f528002'].to_s.tr('-,','')
allnil.push(f528002)
f528002 = '0' if (f528002.to_s.length == 0)
f528003 = c['f528003'].to_s.tr('-,','')
allnil.push(f528003)
f528003 = '0' if (f528003.to_s.length == 0)
f528004 = c['f528004'].to_s.tr('-,','')
allnil.push(f528004)
f528004 = '0' if (f528004.to_s.length == 0)
f529001 = c['f529001'].to_s.tr('-,','')
allnil.push(f529001)
f529001 = '0' if (f529001.to_s.length == 0)
f529002 = c['f529002'].to_s.tr('-,','')
allnil.push(f529002)
f529002 = '0' if (f529002.to_s.length == 0)
f529003 = c['f529003'].to_s.tr('-,','')
allnil.push(f529003)
f529003 = '0' if (f529003.to_s.length == 0)
f529004 = c['f529004'].to_s.tr('-,','')
allnil.push(f529004)
f529004 = '0' if (f529004.to_s.length == 0)
f530001 = c['f530001'].to_s.tr('-,','')
allnil.push(f530001)
f530001 = '0' if (f530001.to_s.length == 0)
f530002 = c['f530002'].to_s.tr('-,','')
allnil.push(f530002)
f530002 = '0' if (f530002.to_s.length == 0)
f530003 = c['f530003'].to_s.tr('-,','')
allnil.push(f530003)
f530003 = '0' if (f530003.to_s.length == 0)
f530004 = c['f530004'].to_s.tr('-,','')
allnil.push(f530004)
f530004 = '0' if (f530004.to_s.length == 0)
f531001 = c['f531001'].to_s.tr('-,','')
allnil.push(f531001)
f531001 = '0' if (f531001.to_s.length == 0)
f531002 = c['f531002'].to_s.tr('-,','')
allnil.push(f531002)
f531002 = '0' if (f531002.to_s.length == 0)
f531003 = c['f531003'].to_s.tr('-,','')
allnil.push(f531003)
f531003 = '0' if (f531003.to_s.length == 0)
f531004 = c['f531004'].to_s.tr('-,','')
allnil.push(f531004)
f531004 = '0' if (f531004.to_s.length == 0)
f532001 = c['f532001'].to_s.tr('-,','')
allnil.push(f532001)
f532001 = '0' if (f532001.to_s.length == 0)
f532002 = c['f532002'].to_s.tr('-,','')
allnil.push(f532002)
f532002 = '0' if (f532002.to_s.length == 0)
f532003 = c['f532003'].to_s.tr('-,','')
allnil.push(f532003)
f532003 = '0' if (f532003.to_s.length == 0)
f532004 = c['f532004'].to_s.tr('-,','')
allnil.push(f532004)
f532004 = '0' if (f532004.to_s.length == 0)
f533001 = c['f533001'].to_s.tr('-,','')
allnil.push(f533001)
f533001 = '0' if (f533001.to_s.length == 0)
f533002 = c['f533002'].to_s.tr('-,','')
allnil.push(f533002)
f533002 = '0' if (f533002.to_s.length == 0)
f533003 = c['f533003'].to_s.tr('-,','')
allnil.push(f533003)
f533003 = '0' if (f533003.to_s.length == 0)
f533004 = c['f533004'].to_s.tr('-,','')
allnil.push(f533004)
f533004 = '0' if (f533004.to_s.length == 0)
f534001 = c['f534001'].to_s.tr('-,','')
allnil.push(f534001)
f534001 = '0' if (f534001.to_s.length == 0)
f534002 = c['f534002'].to_s.tr('-,','')
allnil.push(f534002)
f534002 = '0' if (f534002.to_s.length == 0)
f534003 = c['f534003'].to_s.tr('-,','')
allnil.push(f534003)
f534003 = '0' if (f534003.to_s.length == 0)
f534004 = c['f534004'].to_s.tr('-,','')
allnil.push(f534004)
f534004 = '0' if (f534004.to_s.length == 0)
f535001 = c['f535001'].to_s.tr('-,','')
allnil.push(f535001)
f535001 = '0' if (f535001.to_s.length == 0)
f535002 = c['f535002'].to_s.tr('-,','')
allnil.push(f535002)
f535002 = '0' if (f535002.to_s.length == 0)
f535003 = c['f535003'].to_s.tr('-,','')
allnil.push(f535003)
f535003 = '0' if (f535003.to_s.length == 0)
f535004 = c['f535004'].to_s.tr('-,','')
allnil.push(f535004)
f535004 = '0' if (f535004.to_s.length == 0)
f536001 = c['f536001'].to_s.tr('-,','')
allnil.push(f536001)
f536001 = '0' if (f536001.to_s.length == 0)
f536002 = c['f536002'].to_s.tr('-,','')
allnil.push(f536002)
f536002 = '0' if (f536002.to_s.length == 0)
f536003 = c['f536003'].to_s.tr('-,','')
allnil.push(f536003)
f536003 = '0' if (f536003.to_s.length == 0)
f536004 = c['f536004'].to_s.tr('-,','')
allnil.push(f536004)
f536004 = '0' if (f536004.to_s.length == 0)
f537001 = c['f537001'].to_s.tr('-,','')
allnil.push(f537001)
f537001 = '0' if (f537001.to_s.length == 0)
f537002 = c['f537002'].to_s.tr('-,','')
allnil.push(f537002)
f537002 = '0' if (f537002.to_s.length == 0)
f537003 = c['f537003'].to_s.tr('-,','')
allnil.push(f537003)
f537003 = '0' if (f537003.to_s.length == 0)
f537004 = c['f537004'].to_s.tr('-,','')
allnil.push(f537004)
f537004 = '0' if (f537004.to_s.length == 0)
f538001 = c['f538001'].to_s.tr('-,','')
allnil.push(f538001)
f538001 = '0' if (f538001.to_s.length == 0)
f538002 = c['f538002'].to_s.tr('-,','')
allnil.push(f538002)
f538002 = '0' if (f538002.to_s.length == 0)
f538003 = c['f538003'].to_s.tr('-,','')
allnil.push(f538003)
f538003 = '0' if (f538003.to_s.length == 0)
f538004 = c['f538004'].to_s.tr('-,','')
allnil.push(f538004)
f538004 = '0' if (f538004.to_s.length == 0)
f539001 = c['f539001'].to_s.tr('-,','')
allnil.push(f539001)
f539001 = '0' if (f539001.to_s.length == 0)
f539002 = c['f539002'].to_s.tr('-,','')
allnil.push(f539002)
f539002 = '0' if (f539002.to_s.length == 0)
f539003 = c['f539003'].to_s.tr('-,','')
allnil.push(f539003)
f539003 = '0' if (f539003.to_s.length == 0)
f539004 = c['f539004'].to_s.tr('-,','')
allnil.push(f539004)
f539004 = '0' if (f539004.to_s.length == 0)
f540001 = c['f540001'].to_s.tr('-,','')
allnil.push(f540001)
f540001 = '0' if (f540001.to_s.length == 0)
f540002 = c['f540002'].to_s.tr('-,','')
allnil.push(f540002)
f540002 = '0' if (f540002.to_s.length == 0)
f540003 = c['f540003'].to_s.tr('-,','')
allnil.push(f540003)
f540003 = '0' if (f540003.to_s.length == 0)
f540004 = c['f540004'].to_s.tr('-,','')
allnil.push(f540004)
f540004 = '0' if (f540004.to_s.length == 0)

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

chk = checkDup("form5", "f5year", "f5hcode", f5year, f5hcode)
  chkDigit('f501001',f501001)
  chkDigit('f501002',f501002)
  chkDigit('f501003',f501003)
  chkDigit('f501004',f501004)
  chkDigit('f502001',f502001)
  chkDigit('f502002',f502002)
  chkDigit('f502003',f502003)
  chkDigit('f502004',f502004)
  chkDigit('f503001',f503001)
  chkDigit('f503002',f503002)
  chkDigit('f503003',f503003)
  chkDigit('f503004',f503004)
  chkDigit('f504001',f504001)
  chkDigit('f504002',f504002)
  chkDigit('f504003',f504003)
  chkDigit('f504004',f504004)
  chkDigit('f505001',f505001)
  chkDigit('f505002',f505002)
  chkDigit('f505003',f505003)
  chkDigit('f505004',f505004)
  chkDigit('f506001',f506001)
  chkDigit('f506002',f506002)
  chkDigit('f506003',f506003)
  chkDigit('f506004',f506004)
  chkDigit('f507001',f507001)
  chkDigit('f507002',f507002)
  chkDigit('f507003',f507003)
  chkDigit('f507004',f507004)
  chkDigit('f508001',f508001)
  chkDigit('f508002',f508002)
  chkDigit('f508003',f508003)
  chkDigit('f508004',f508004)
  chkDigit('f509001',f509001)
  chkDigit('f509002',f509002)
  chkDigit('f509003',f509003)
  chkDigit('f509004',f509004)
  chkDigit('f510001',f510001)
  chkDigit('f510002',f510002)
  chkDigit('f510003',f510003)
  chkDigit('f510004',f510004)
  chkDigit('f511001',f511001)
  chkDigit('f511002',f511002)
  chkDigit('f511003',f511003)
  chkDigit('f511004',f511004)
  chkDigit('f512001',f512001)
  chkDigit('f512002',f512002)
  chkDigit('f512003',f512003)
  chkDigit('f512004',f512004)
  chkDigit('f513001',f513001)
  chkDigit('f513002',f513002)
  chkDigit('f513003',f513003)
  chkDigit('f513004',f513004)
  chkDigit('f514001',f514001)
  chkDigit('f514002',f514002)
  chkDigit('f514003',f514003)
  chkDigit('f514004',f514004)
  chkDigit('f515001',f515001)
  chkDigit('f515002',f515002)
  chkDigit('f515003',f515003)
  chkDigit('f515004',f515004)
  chkDigit('f516001',f516001)
  chkDigit('f516002',f516002)
  chkDigit('f516003',f516003)
  chkDigit('f516004',f516004)
  chkDigit('f517001',f517001)
  chkDigit('f517002',f517002)
  chkDigit('f517003',f517003)
  chkDigit('f517004',f517004)
  chkDigit('f518001',f518001)
  chkDigit('f518002',f518002)
  chkDigit('f518003',f518003)
  chkDigit('f518004',f518004)
  chkDigit('f519001',f519001)
  chkDigit('f519002',f519002)
  chkDigit('f519003',f519003)
  chkDigit('f519004',f519004)
  chkDigit('f520001',f520001)
  chkDigit('f520002',f520002)
  chkDigit('f520003',f520003)
  chkDigit('f520004',f520004)
  chkDigit('f521001',f521001)
  chkDigit('f521002',f521002)
  chkDigit('f521003',f521003)
  chkDigit('f521004',f521004)
  chkDigit('f522001',f522001)
  chkDigit('f522002',f522002)
  chkDigit('f522003',f522003)
  chkDigit('f522004',f522004)
  chkDigit('f523001',f523001)
  chkDigit('f523002',f523002)
  chkDigit('f523003',f523003)
  chkDigit('f523004',f523004)
  chkDigit('f524001',f524001)
  chkDigit('f524002',f524002)
  chkDigit('f524003',f524003)
  chkDigit('f524004',f524004)
  chkDigit('f525001',f525001)
  chkDigit('f525002',f525002)
  chkDigit('f525003',f525003)
  chkDigit('f525004',f525004)
  chkDigit('f526001',f526001)
  chkDigit('f526002',f526002)
  chkDigit('f526003',f526003)
  chkDigit('f526004',f526004)
  chkDigit('f527001',f527001)
  chkDigit('f527002',f527002)
  chkDigit('f527003',f527003)
  chkDigit('f527004',f527004)
  chkDigit('f528001',f528001)
  chkDigit('f528002',f528002)
  chkDigit('f528003',f528003)
  chkDigit('f528004',f528004)
  chkDigit('f529001',f529001)
  chkDigit('f529002',f529002)
  chkDigit('f529003',f529003)
  chkDigit('f529004',f529004)
  chkDigit('f530001',f530001)
  chkDigit('f530002',f530002)
  chkDigit('f530003',f530003)
  chkDigit('f530004',f530004)
  chkDigit('f531001',f531001)
  chkDigit('f531002',f531002)
  chkDigit('f531003',f531003)
  chkDigit('f531004',f531004)
  chkDigit('f532001',f532001)
  chkDigit('f532002',f532002)
  chkDigit('f532003',f532003)
  chkDigit('f532004',f532004)
  chkDigit('f533001',f533001)
  chkDigit('f533002',f533002)
  chkDigit('f533003',f533003)
  chkDigit('f533004',f533004)
  chkDigit('f534001',f534001)
  chkDigit('f534002',f534002)
  chkDigit('f534003',f534003)
  chkDigit('f534004',f534004)
  chkDigit('f535001',f535001)
  chkDigit('f535002',f535002)
  chkDigit('f535003',f535003)
  chkDigit('f535004',f535004)
  chkDigit('f536001',f536001)
  chkDigit('f536002',f536002)
  chkDigit('f536003',f536003)
  chkDigit('f536004',f536004)
  chkDigit('f537001',f537001)
  chkDigit('f537002',f537002)
  chkDigit('f537003',f537003)
  chkDigit('f537004',f537004)
  chkDigit('f538001',f538001)
  chkDigit('f538002',f538002)
  chkDigit('f538003',f538003)
  chkDigit('f538004',f538004)
  chkDigit('f539001',f539001)
  chkDigit('f539002',f539002)
  chkDigit('f539003',f539003)
  chkDigit('f539004',f539004)
  chkDigit('f540001',f540001)
  chkDigit('f540002',f540002)
  chkDigit('f540003',f540003)
  chkDigit('f540004',f540004)

if chk.to_s == 'NODUP'
  sql = "INSERT INTO form5(f5year,f5pname,f5pcode,f5hname,f5hcode,"
  sql = sql << "f501001,f501002,f501003,f501004,"
  sql = sql << "f502001,f502002,f502003,f502004,"
  sql = sql << "f503001,f503002,f503003,f503004,"
  sql = sql << "f504001,f504002,f504003,f504004,"
  sql = sql << "f505001,f505002,f505003,f505004,"
  sql = sql << "f506001,f506002,f506003,f506004,"
  sql = sql << "f507001,f507002,f507003,f507004,"
  sql = sql << "f508001,f508002,f508003,f508004,"
  sql = sql << "f509001,f509002,f509003,f509004,"
  sql = sql << "f510001,f510002,f510003,f510004,"
  sql = sql << "f511001,f511002,f511003,f511004,"
  sql = sql << "f512001,f512002,f512003,f512004,"
  sql = sql << "f513001,f513002,f513003,f513004,"
  sql = sql << "f514001,f514002,f514003,f514004,"
  sql = sql << "f515001,f515002,f515003,f515004,"
  sql = sql << "f516001,f516002,f516003,f516004,"
  sql = sql << "f517001,f517002,f517003,f517004,"
  sql = sql << "f518001,f518002,f518003,f518004,"
  sql = sql << "f519001,f519002,f519003,f519004,"
  sql = sql << "f520001,f520002,f520003,f520004,"
  sql = sql << "f521001,f521002,f521003,f521004,"
  sql = sql << "f522001,f522002,f522003,f522004,"
  sql = sql << "f523001,f523002,f523003,f523004,"
  sql = sql << "f524001,f524002,f524003,f524004,"
  sql = sql << "f525001,f525002,f525003,f525004,"
  sql = sql << "f526001,f526002,f526003,f526004,"
  sql = sql << "f527001,f527002,f527003,f527004,"
  sql = sql << "f528001,f528002,f528003,f528004,"
  sql = sql << "f529001,f529002,f529003,f529004,"
  sql = sql << "f530001,f530002,f530003,f530004,"
  sql = sql << "f531001,f531002,f531003,f531004,"
  sql = sql << "f532001,f532002,f532003,f532004,"
  sql = sql << "f533001,f533002,f533003,f533004,"
  sql = sql << "f534001,f534002,f534003,f534004,"
  sql = sql << "f535001,f535002,f535003,f535004,"
  sql = sql << "f536001,f536002,f536003,f536004,"
  sql = sql << "f537001,f537002,f537003,f537004,"
  sql = sql << "f538001,f538002,f538003,f538004,"
  sql = sql << "f539001,f539002,f539003,f539004,"
  sql = sql << "f540001,f540002,f540003,f540004) "
  sql = sql << "VALUES('#{f5year}','#{f5pname}','#{f5pcode}','#{f5hname}','#{f5hcode}',"
  sql = sql << "'#{f501001}','#{f501002}','#{f501003}','#{f501004}',"
  sql = sql << "'#{f502001}','#{f502002}','#{f502003}','#{f502004}',"
  sql = sql << "'#{f503001}','#{f503002}','#{f503003}','#{f503004}',"
  sql = sql << "'#{f504001}','#{f504002}','#{f504003}','#{f504004}',"
  sql = sql << "'#{f505001}','#{f505002}','#{f505003}','#{f505004}',"
  sql = sql << "'#{f506001}','#{f506002}','#{f506003}','#{f506004}',"
  sql = sql << "'#{f507001}','#{f507002}','#{f507003}','#{f507004}',"
  sql = sql << "'#{f508001}','#{f508002}','#{f508003}','#{f508004}',"
  sql = sql << "'#{f509001}','#{f509002}','#{f509003}','#{f509004}',"
  sql = sql << "'#{f510001}','#{f510002}','#{f510003}','#{f510004}',"
  sql = sql << "'#{f511001}','#{f511002}','#{f511003}','#{f511004}',"
  sql = sql << "'#{f512001}','#{f512002}','#{f512003}','#{f512004}',"
  sql = sql << "'#{f513001}','#{f513002}','#{f513003}','#{f513004}',"
  sql = sql << "'#{f514001}','#{f514002}','#{f514003}','#{f514004}',"
  sql = sql << "'#{f515001}','#{f515002}','#{f515003}','#{f515004}',"
  sql = sql << "'#{f516001}','#{f516002}','#{f516003}','#{f516004}',"
  sql = sql << "'#{f517001}','#{f517002}','#{f517003}','#{f517004}',"
  sql = sql << "'#{f518001}','#{f518002}','#{f518003}','#{f518004}',"
  sql = sql << "'#{f519001}','#{f519002}','#{f519003}','#{f519004}',"
  sql = sql << "'#{f520001}','#{f520002}','#{f520003}','#{f520004}',"
  sql = sql << "'#{f521001}','#{f521002}','#{f521003}','#{f521004}',"
  sql = sql << "'#{f522001}','#{f522002}','#{f522003}','#{f522004}',"
  sql = sql << "'#{f523001}','#{f523002}','#{f523003}','#{f523004}',"
  sql = sql << "'#{f524001}','#{f524002}','#{f524003}','#{f524004}',"
  sql = sql << "'#{f525001}','#{f525002}','#{f525003}','#{f525004}',"
  sql = sql << "'#{f526001}','#{f526002}','#{f526003}','#{f526004}',"
  sql = sql << "'#{f527001}','#{f527002}','#{f527003}','#{f527004}',"
  sql = sql << "'#{f528001}','#{f528002}','#{f528003}','#{f528004}',"
  sql = sql << "'#{f529001}','#{f529002}','#{f529003}','#{f529004}',"
  sql = sql << "'#{f530001}','#{f530002}','#{f530003}','#{f530004}',"
  sql = sql << "'#{f531001}','#{f531002}','#{f531003}','#{f531004}',"
  sql = sql << "'#{f532001}','#{f532002}','#{f532003}','#{f532004}',"
  sql = sql << "'#{f533001}','#{f533002}','#{f533003}','#{f533004}',"
  sql = sql << "'#{f534001}','#{f534002}','#{f534003}','#{f534004}',"
  sql = sql << "'#{f535001}','#{f535002}','#{f535003}','#{f535004}',"
  sql = sql << "'#{f536001}','#{f536002}','#{f536003}','#{f536004}',"
  sql = sql << "'#{f537001}','#{f537002}','#{f537003}','#{f537004}',"
  sql = sql << "'#{f538001}','#{f538002}','#{f538003}','#{f538004}',"
  sql = sql << "'#{f539001}','#{f539002}','#{f539003}','#{f539004}',"
  sql = sql << "'#{f540001}','#{f540002}','#{f540003}','#{f540004}')"
  res = con.exec(sql)
elsif chk == 'DUP'
  chkDigit('f501001',f501001)
  sql = "UPDATE form5 SET "
  sql = sql << "f501001='#{f501001.to_s}',f501002='#{f501002.to_s}',"
  sql = sql << "f501003='#{f501003.to_s}',f501004='#{f501004.to_s}',"
  sql = sql << "f502001='#{f502001.to_s}',f502002='#{f502002.to_s}',"
  sql = sql << "f502003='#{f502003.to_s}',f502004='#{f502004.to_s}',"
  sql = sql << "f503001='#{f503001.to_s}',f503002='#{f503002.to_s}',"
  sql = sql << "f503003='#{f503003.to_s}',f503004='#{f503004.to_s}',"
  sql = sql << "f504001='#{f504001.to_s}',f504002='#{f504002.to_s}',"
  sql = sql << "f504003='#{f504003.to_s}',f504004='#{f504004.to_s}',"
  sql = sql << "f505001='#{f505001.to_s}',f505002='#{f505002.to_s}',"
  sql = sql << "f505003='#{f505003.to_s}',f505004='#{f505004.to_s}',"
  sql = sql << "f506001='#{f506001.to_s}',f506002='#{f506002.to_s}',"
  sql = sql << "f506003='#{f506003.to_s}',f506004='#{f506004.to_s}',"
  sql = sql << "f507001='#{f507001.to_s}',f507002='#{f507002.to_s}',"
  sql = sql << "f507003='#{f507003.to_s}',f507004='#{f507004.to_s}',"
  sql = sql << "f508001='#{f508001.to_s}',f508002='#{f508002.to_s}',"
  sql = sql << "f508003='#{f508003.to_s}',f508004='#{f508004.to_s}',"
  sql = sql << "f509001='#{f509001.to_s}',f509002='#{f509002.to_s}',"
  sql = sql << "f509003='#{f509003.to_s}',f509004='#{f509004.to_s}',"
  sql = sql << "f510001='#{f510001.to_s}',f510002='#{f510002.to_s}',"
  sql = sql << "f510003='#{f510003.to_s}',f510004='#{f510004.to_s}',"
  sql = sql << "f511001='#{f511001.to_s}',f511002='#{f511002.to_s}',"
  sql = sql << "f511003='#{f511003.to_s}',f511004='#{f511004.to_s}',"
  sql = sql << "f512001='#{f512001.to_s}',f512002='#{f512002.to_s}',"
  sql = sql << "f512003='#{f512003.to_s}',f512004='#{f512004.to_s}',"
  sql = sql << "f513001='#{f513001.to_s}',f513002='#{f513002.to_s}',"
  sql = sql << "f513003='#{f513003.to_s}',f513004='#{f513004.to_s}',"
  sql = sql << "f514001='#{f514001.to_s}',f514002='#{f514002.to_s}',"
  sql = sql << "f514003='#{f514003.to_s}',f514004='#{f514004.to_s}',"
  sql = sql << "f515001='#{f515001.to_s}',f515002='#{f515002.to_s}',"
  sql = sql << "f515003='#{f515003.to_s}',f515004='#{f515004.to_s}',"
  sql = sql << "f516001='#{f516001.to_s}',f516002='#{f516002.to_s}',"
  sql = sql << "f516003='#{f516003.to_s}',f516004='#{f516004.to_s}',"
  sql = sql << "f517001='#{f517001.to_s}',f517002='#{f517002.to_s}',"
  sql = sql << "f517003='#{f517003.to_s}',f517004='#{f517004.to_s}',"
  sql = sql << "f518001='#{f518001.to_s}',f518002='#{f518002.to_s}',"
  sql = sql << "f518003='#{f518003.to_s}',f518004='#{f518004.to_s}',"
  sql = sql << "f519001='#{f519001.to_s}',f519002='#{f519002.to_s}',"
  sql = sql << "f519003='#{f519003.to_s}',f519004='#{f519004.to_s}',"
  sql = sql << "f520001='#{f520001.to_s}',f520002='#{f520002.to_s}',"
  sql = sql << "f520003='#{f520003.to_s}',f520004='#{f520004.to_s}',"
  sql = sql << "f521001='#{f521001.to_s}',f521002='#{f521002.to_s}',"
  sql = sql << "f521003='#{f521004.to_s}',f521004='#{f521004.to_s}',"
  sql = sql << "f522001='#{f522001.to_s}',f522002='#{f522002.to_s}',"
  sql = sql << "f522003='#{f522003.to_s}',f522004='#{f522004.to_s}',"
  sql = sql << "f523001='#{f523001.to_s}',f523002='#{f523002.to_s}',"
  sql = sql << "f523003='#{f523003.to_s}',f523004='#{f523004.to_s}',"
  sql = sql << "f524001='#{f524001.to_s}',f524002='#{f524002.to_s}',"
  sql = sql << "f524003='#{f524003.to_s}',f524004='#{f524004.to_s}',"
  sql = sql << "f525001='#{f525001.to_s}',f525002='#{f525002.to_s}',"
  sql = sql << "f525003='#{f525003.to_s}',f525004='#{f525004.to_s}',"
  sql = sql << "f526001='#{f526001.to_s}',f526002='#{f526002.to_s}',"
  sql = sql << "f526003='#{f526003.to_s}',f526004='#{f526004.to_s}',"
  sql = sql << "f527001='#{f527001.to_s}',f527002='#{f527002.to_s}',"
  sql = sql << "f527003='#{f527003.to_s}',f527004='#{f527004.to_s}',"
  sql = sql << "f528001='#{f528001.to_s}',f528002='#{f528002.to_s}',"
  sql = sql << "f528003='#{f528003.to_s}',f528004='#{f528004.to_s}',"
  sql = sql << "f529001='#{f529001.to_s}',f529002='#{f529002.to_s}',"
  sql = sql << "f529003='#{f529003.to_s}',f529004='#{f529004.to_s}',"
  sql = sql << "f530001='#{f530001.to_s}',f530002='#{f530002.to_s}',"
  sql = sql << "f530003='#{f530003.to_s}',f530004='#{f530004.to_s}',"
  sql = sql << "f531001='#{f531001.to_s}',f531002='#{f531002.to_s}',"
  sql = sql << "f531003='#{f531003.to_s}',f531004='#{f531004.to_s}',"
  sql = sql << "f532001='#{f532001.to_s}',f532002='#{f532002.to_s}',"
  sql = sql << "f532003='#{f532003.to_s}',f532004='#{f532004.to_s}',"
  sql = sql << "f533001='#{f533001.to_s}',f533002='#{f533002.to_s}',"
  sql = sql << "f533003='#{f533003.to_s}',f533004='#{f533004.to_s}',"
  sql = sql << "f534001='#{f534001.to_s}',f534002='#{f534002.to_s}',"
  sql = sql << "f534003='#{f534003.to_s}',f534004='#{f534004.to_s}',"
  sql = sql << "f535001='#{f535001.to_s}',f535002='#{f535002.to_s}',"
  sql = sql << "f535003='#{f535003.to_s}',f535004='#{f535004.to_s}',"
  sql = sql << "f536001='#{f536001.to_s}',f536002='#{f536002.to_s}',"
  sql = sql << "f536003='#{f536003.to_s}',f536004='#{f536004.to_s}',"
  sql = sql << "f537001='#{f537001.to_s}',f537002='#{f537002.to_s}',"
  sql = sql << "f537003='#{f537003.to_s}',f537004='#{f537004.to_s}',"
  sql = sql << "f538001='#{f538001.to_s}',f538002='#{f538002.to_s}',"
  sql = sql << "f538003='#{f538003.to_s}',f538004='#{f538004.to_s}',"
  sql = sql << "f539001='#{f539001.to_s}',f539002='#{f539002.to_s}',"
  sql = sql << "f539003='#{f539003.to_s}',f539004='#{f539004.to_s}',"
  sql = sql << "f540001='#{f540001.to_s}',f540002='#{f540002.to_s}',"
  sql = sql << "f540003='#{f540003.to_s}',f540004='#{f540004.to_s}' "
  sql = sql << "WHERE f5year='#{f5year}' and f5hcode='#{f5hcode}' "
  res = con.exec(sql)
end

con.close

updateReportMon(f5hcode,f5year,"form5")

#check X for FORM5 if mdtotal = 0
mdtotal = f501001.to_i + f501002.to_i + f501003.to_i + f501004.to_i
comment = "<h3>โปรดบันทึกแบบฟอร์มที่ 2 ต่อไป</h3>"

if (mdtotal == 0)
  checkXForm6(f5hcode)
  comment = "<h3>ไม่ต้องบันทึก Form 2 โปรดข้ามไปบันทึก Form 3 ต่อไป</h3>"
end

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f5hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<!-- src: form5.rb -->
<body text='blue'>
<center>
<h3>บันทึกแบบฟอร์ม 1 สำหรับ #{ f5hname.to_s }(#{ f5hcode.to_s }) 
เรียบร้อยแล้ว</h3>
#{comment}
<p>
<input type='button' value='Back' onClick='history.back();' />
</center>
</body>
</html>
EOF

