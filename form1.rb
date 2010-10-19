#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'hr_util.rb'
require 'res_util.rb'

allnil = Array.new
c = CGI::new
f1year = c['f1year'].to_s
f1pname = c['f1pname'].to_s
f1pcode = c['f1pcode'].to_s
f1hname = c['f1hname'].to_s
f1hcode  = c['f1hcode'].to_s
f101001 = c['f101001'].to_s.tr('-,','')
allnil.push(f101001)
f101001 = '0' if (f101001.to_s.length == 0)
f101002 = c['f101002'].to_s.tr('-,','')
allnil.push(f101002)
f101002 = '0' if (f101002.to_s.length == 0)
f101003 = c['f101003'].to_s.tr('-,','')
allnil.push(f101003)
f101003 = '0' if (f101003.to_s.length == 0)
f101004 = c['f101004'].to_s.tr('-,','')
allnil.push(f101004)
f101004 = '0' if (f101004.to_s.length == 0)
f102001 = c['f102001'].to_s.tr('-,','')
allnil.push(f102001)
f102001 = '0' if (f102001.to_s.length == 0)
f102002 = c['f102002'].to_s.tr('-,','')
allnil.push(f102002)
f102002 = '0' if (f102002.to_s.length == 0)
f102003 = c['f102003'].to_s.tr('-,','')
allnil.push(f102003)
f102003 = '0' if (f102003.to_s.length == 0)
f102004 = c['f102004'].to_s.tr('-,','')
allnil.push(f102004)
f102004 = '0' if (f102004.to_s.length == 0)
f103001 = c['f103001'].to_s.tr('-,','')
allnil.push(f103001)
f103001 = '0' if (f103001.to_s.length == 0)
f103002 = c['f103002'].to_s.tr('-,','')
allnil.push(f103002)
f103002 = '0' if (f103002.to_s.length == 0)
f103003 = c['f103003'].to_s.tr('-,','')
allnil.push(f103003)
f103003 = '0' if (f103003.to_s.length == 0)
f103004 = c['f103004'].to_s.tr('-,','')
allnil.push(f103004)
f103004 = '0' if (f103004.to_s.length == 0)
f104001 = c['f104001'].to_s.tr('-,','')
allnil.push(f104001)
f104001 = '0' if (f104001.to_s.length == 0)
f104002 = c['f104002'].to_s.tr('-,','')
allnil.push(f104002)
f104002 = '0' if (f104002.to_s.length == 0)
f104003 = c['f104003'].to_s.tr('-,','')
allnil.push(f104003)
f104003 = '0' if (f104003.to_s.length == 0)
f104004 = c['f104004'].to_s.tr('-,','')
allnil.push(f104004)
f104004 = '0' if (f104004.to_s.length == 0)
f105001 = c['f105001'].to_s.tr('-,','')
allnil.push(f105001)
f105001 = '0' if (f105001.to_s.length == 0)
f105002 = c['f105002'].to_s.tr('-,','')
allnil.push(f105002)
f105002 = '0' if (f105002.to_s.length == 0)
f105003 = c['f105003'].to_s.tr('-,','')
allnil.push(f105003)
f105003 = '0' if (f105003.to_s.length == 0)
f105004 = c['f105004'].to_s.tr('-,','')
allnil.push(f105004)
f105004 = '0' if (f105004.to_s.length == 0)
f106001 = c['f106001'].to_s.tr('-,','')
allnil.push(f106001)
f106001 = '0' if (f106001.to_s.length == 0)
f106002 = c['f106002'].to_s.tr('-,','')
allnil.push(f106002)
f106002 = '0' if (f106002.to_s.length == 0)
f106003 = c['f106003'].to_s.tr('-,','')
allnil.push(f106003)
f106003 = '0' if (f106003.to_s.length == 0)
f106004 = c['f106004'].to_s.tr('-,','')
allnil.push(f106004)
f106004 = '0' if (f106004.to_s.length == 0)
f107001 = c['f107001'].to_s.tr('-,','')
allnil.push(f107001)
f107001 = '0' if (f107001.to_s.length == 0)
f107002 = c['f107002'].to_s.tr('-,','')
allnil.push(f107002)
f107002 = '0' if (f107002.to_s.length == 0)
f107003 = c['f107003'].to_s.tr('-,','')
allnil.push(f107003)
f107003 = '0' if (f107003.to_s.length == 0)
f107004 = c['f107004'].to_s.tr('-,','')
allnil.push(f107004)
f107004 = '0' if (f107004.to_s.length == 0)
f108001 = c['f108001'].to_s.tr('-,','')
allnil.push(f108001)
f108001 = '0' if (f108001.to_s.length == 0)
f108002 = c['f108002'].to_s.tr('-,','')
allnil.push(f108002)
f108002 = '0' if (f108002.to_s.length == 0)
f108003 = c['f108003'].to_s.tr('-,','')
allnil.push(f108003)
f108003 = '0' if (f108003.to_s.length == 0)
f108004 = c['f108004'].to_s.tr('-,','')
allnil.push(f108004)
f108004 = '0' if (f108004.to_s.length == 0)
f109001 = c['f109001'].to_s.tr('-,','')
allnil.push(f109001)
f109001 = '0' if (f109001.to_s.length == 0)
f109002 = c['f109002'].to_s.tr('-,','')
allnil.push(f109002)
f109002 = '0' if (f109002.to_s.length == 0)
f109003 = c['f109003'].to_s.tr('-,','')
allnil.push(f109003)
f109003 = '0' if (f109003.to_s.length == 0)
f109004 = c['f109004'].to_s.tr('-,','')
allnil.push(f109004)
f109004 = '0' if (f109004.to_s.length == 0)
f110001 = c['f110001'].to_s.tr('-,','')
allnil.push(f110001)
f110001 = '0' if (f110001.to_s.length == 0)
f110002 = c['f110002'].to_s.tr('-,','')
allnil.push(f110002)
f110002 = '0' if (f110002.to_s.length == 0)
f110003 = c['f110003'].to_s.tr('-,','')
allnil.push(f110003)
f110003 = '0' if (f110003.to_s.length == 0)
f110004 = c['f110004'].to_s.tr('-,','')
allnil.push(f110004)
f110004 = '0' if (f110004.to_s.length == 0)
f111001 = c['f111001'].to_s.tr('-,','')
allnil.push(f111001)
f111001 = '0' if (f111001.to_s.length == 0)
f111002 = c['f111002'].to_s.tr('-,','')
allnil.push(f111002)
f111002 = '0' if (f111002.to_s.length == 0)
f111003 = c['f111003'].to_s.tr('-,','')
allnil.push(f111003)
f111003 = '0' if (f111003.to_s.length == 0)
f111004 = c['f111004'].to_s.tr('-,','')
allnil.push(f111004)
f111004 = '0' if (f111004.to_s.length == 0)
f112001 = c['f112001'].to_s.tr('-,','')
allnil.push(f112001)
f112001 = '0' if (f112001.to_s.length == 0)
f112002 = c['f112002'].to_s.tr('-,','')
allnil.push(f112002)
f112002 = '0' if (f112002.to_s.length == 0)
f112003 = c['f112003'].to_s.tr('-,','')
allnil.push(f112003)
f112003 = '0' if (f112003.to_s.length == 0)
f112004 = c['f112004'].to_s.tr('-,','')
allnil.push(f112004)
f112004 = '0' if (f112004.to_s.length == 0)
f113001 = c['f113001'].to_s.tr('-,','')
allnil.push(f113001)
f113001 = '0' if (f113001.to_s.length == 0)
f113002 = c['f113002'].to_s.tr('-,','')
allnil.push(f113002)
f113002 = '0' if (f113002.to_s.length == 0)
f113003 = c['f113003'].to_s.tr('-,','')
allnil.push(f113003)
f113003 = '0' if (f113003.to_s.length == 0)
f113004 = c['f113004'].to_s.tr('-,','')
allnil.push(f113004)
f113004 = '0' if (f113004.to_s.length == 0)
f114001 = c['f114001'].to_s.tr('-,','')
allnil.push(f114001)
f114001 = '0' if (f114001.to_s.length == 0)
f114002 = c['f114002'].to_s.tr('-,','')
allnil.push(f114002)
f114002 = '0' if (f114002.to_s.length == 0)
f114003 = c['f114003'].to_s.tr('-,','')
allnil.push(f114003)
f114003 = '0' if (f114003.to_s.length == 0)
f114004 = c['f114004'].to_s.tr('-,','')
allnil.push(f114004)
f114004 = '0' if (f114004.to_s.length == 0)
f115001 = c['f115001'].to_s.tr('-,','')
allnil.push(f115001)
f115001 = '0' if (f115001.to_s.length == 0)
f115002 = c['f115002'].to_s.tr('-,','')
allnil.push(f115002)
f115002 = '0' if (f115002.to_s.length == 0)
f115003 = c['f115003'].to_s.tr('-,','')
allnil.push(f115003)
f115003 = '0' if (f115003.to_s.length == 0)
f115004 = c['f115004'].to_s.tr('-,','')
allnil.push(f115004)
f115004 = '0' if (f115004.to_s.length == 0)
f116001 = c['f116001'].to_s.tr('-,','')
allnil.push(f116001)
f116001 = '0' if (f116001.to_s.length == 0)
f116002 = c['f116002'].to_s.tr('-,','')
allnil.push(f116002)
f116002 = '0' if (f116002.to_s.length == 0)
f116003 = c['f116003'].to_s.tr('-,','')
allnil.push(f116003)
f116003 = '0' if (f116003.to_s.length == 0)
f116004 = c['f116004'].to_s.tr('-,','')
allnil.push(f116004)
f116004 = '0' if (f116004.to_s.length == 0)
f117001 = c['f117001'].to_s.tr('-,','')
allnil.push(f117001)
f117001 = '0' if (f117001.to_s.length == 0)
f117002 = c['f117002'].to_s.tr('-,','')
allnil.push(f117002)
f117002 = '0' if (f117002.to_s.length == 0)
f117003 = c['f117003'].to_s.tr('-,','')
allnil.push(f117003)
f117003 = '0' if (f117003.to_s.length == 0)
f117004 = c['f117004'].to_s.tr('-,','')
allnil.push(f117004)
f117004 = '0' if (f117004.to_s.length == 0)
f118001 = c['f118001'].to_s.tr('-,','')
allnil.push(f118001)
f118001 = '0' if (f118001.to_s.length == 0)
f118002 = c['f118002'].to_s.tr('-,','')
allnil.push(f118002)
f118002 = '0' if (f118002.to_s.length == 0)
f118003 = c['f118003'].to_s.tr('-,','')
allnil.push(f118003)
f118003 = '0' if (f118003.to_s.length == 0)
f118004 = c['f118004'].to_s.tr('-,','')
allnil.push(f118004)
f118004 = '0' if (f118004.to_s.length == 0)
f119001 = c['f119001'].to_s.tr('-,','')
allnil.push(f119001)
f119001 = '0' if (f119001.to_s.length == 0)
f119002 = c['f119002'].to_s.tr('-,','')
allnil.push(f119002)
f119002 = '0' if (f119002.to_s.length == 0)
f119003 = c['f119003'].to_s.tr('-,','')
allnil.push(f119003)
f119003 = '0' if (f119003.to_s.length == 0)
f119004 = c['f119004'].to_s.tr('-,','')
allnil.push(f119004)
f119004 = '0' if (f119004.to_s.length == 0)
f120001 = c['f120001'].to_s.tr('-,','')
allnil.push(f120001)
f120001 = '0' if (f120001.to_s.length == 0)
f120002 = c['f120002'].to_s.tr('-,','')
allnil.push(f120002)
f120002 = '0' if (f120002.to_s.length == 0)
f120003 = c['f120003'].to_s.tr('-,','')
allnil.push(f120003)
f120003 = '0' if (f120003.to_s.length == 0)
f120004 = c['f120004'].to_s.tr('-,','')
allnil.push(f120004)
f120004 = '0' if (f120004.to_s.length == 0)
f121001 = c['f121001'].to_s.tr('-,','')
allnil.push(f121001)
f121001 = '0' if (f121001.to_s.length == 0)
f121002 = c['f121002'].to_s.tr('-,','')
allnil.push(f121002)
f121002 = '0' if (f121002.to_s.length == 0)
f121003 = c['f121003'].to_s.tr('-,','')
allnil.push(f121003)
f121003 = '0' if (f121003.to_s.length == 0)
f121004 = c['f121004'].to_s.tr('-,','')
allnil.push(f121004)
f121004 = '0' if (f121004.to_s.length == 0)
f122001 = c['f122001'].to_s.tr('-,','')
allnil.push(f122001)
f122001 = '0' if (f122001.to_s.length == 0)
f122002 = c['f122002'].to_s.tr('-,','')
allnil.push(f122002)
f122002 = '0' if (f122002.to_s.length == 0)
f122003 = c['f122003'].to_s.tr('-,','')
allnil.push(f122003)
f122003 = '0' if (f122003.to_s.length == 0)
f122004 = c['f122004'].to_s.tr('-,','')
allnil.push(f122004)
f122004 = '0' if (f122004.to_s.length == 0)
f123001 = c['f123001'].to_s.tr('-,','')
allnil.push(f123001)
f123001 = '0' if (f123001.to_s.length == 0)
f123002 = c['f123002'].to_s.tr('-,','')
allnil.push(f123002)
f123002 = '0' if (f123002.to_s.length == 0)
f123003 = c['f123003'].to_s.tr('-,','')
allnil.push(f123003)
f123003 = '0' if (f123003.to_s.length == 0)
f123004 = c['f123004'].to_s.tr('-,','')
allnil.push(f123004)
f123004 = '0' if (f123004.to_s.length == 0)
f124001 = c['f124001'].to_s.tr('-,','')
allnil.push(f124001)
f124001 = '0' if (f124001.to_s.length == 0)
f124002 = c['f124002'].to_s.tr('-,','')
allnil.push(f124002)
f124002 = '0' if (f124002.to_s.length == 0)
f124003 = c['f124003'].to_s.tr('-,','')
allnil.push(f124003)
f124003 = '0' if (f124003.to_s.length == 0)
f124004 = c['f124004'].to_s.tr('-,','')
allnil.push(f124004)
f124004 = '0' if (f124004.to_s.length == 0)
f125001 = c['f125001'].to_s.tr('-,','')
allnil.push(f125001)
f125001 = '0' if (f125001.to_s.length == 0)
f125002 = c['f125002'].to_s.tr('-,','')
allnil.push(f125002)
f125002 = '0' if (f125002.to_s.length == 0)
f125003 = c['f125003'].to_s.tr('-,','')
allnil.push(f125003)
f125003 = '0' if (f125003.to_s.length == 0)
f125004 = c['f125004'].to_s.tr('-,','')
allnil.push(f125004)
f125004 = '0' if (f125004.to_s.length == 0)
f126001 = c['f126001'].to_s.tr('-,','')
allnil.push(f126001)
f126001 = '0' if (f126001.to_s.length == 0)
f126002 = c['f126002'].to_s.tr('-,','')
allnil.push(f126002)
f126002 = '0' if (f126002.to_s.length == 0)
f126003 = c['f126003'].to_s.tr('-,','')
allnil.push(f126003)
f126003 = '0' if (f126003.to_s.length == 0)
f126004 = c['f126004'].to_s.tr('-,','')
allnil.push(f126004)
f126004 = '0' if (f126004.to_s.length == 0)
f127001 = c['f127001'].to_s.tr('-,','')
allnil.push(f127001)
f127001 = '0' if (f127001.to_s.length == 0)
f127002 = c['f127002'].to_s.tr('-,','')
allnil.push(f127002)
f127002 = '0' if (f127002.to_s.length == 0)
f127003 = c['f127003'].to_s.tr('-,','')
allnil.push(f127003)
f127003 = '0' if (f127003.to_s.length == 0)
f127004 = c['f127004'].to_s.tr('-,','')
allnil.push(f127004)
f127004 = '0' if (f127004.to_s.length == 0)
f128001 = c['f128001'].to_s.tr('-,','')
allnil.push(f128001)
f128001 = '0' if (f128001.to_s.length == 0)
f128002 = c['f128002'].to_s.tr('-,','')
allnil.push(f128002)
f128002 = '0' if (f128002.to_s.length == 0)
f128003 = c['f128003'].to_s.tr('-,','')
allnil.push(f128003)
f128003 = '0' if (f128003.to_s.length == 0)
f128004 = c['f128004'].to_s.tr('-,','')
allnil.push(f128004)
f128004 = '0' if (f128004.to_s.length == 0)
f129001 = c['f129001'].to_s.tr('-,','')
allnil.push(f129001)
f129001 = '0' if (f129001.to_s.length == 0)
f129002 = c['f129002'].to_s.tr('-,','')
allnil.push(f129002)
f129002 = '0' if (f129002.to_s.length == 0)
f129003 = c['f129003'].to_s.tr('-,','')
allnil.push(f129003)
f129003 = '0' if (f129003.to_s.length == 0)
f129004 = c['f129004'].to_s.tr('-,','')
allnil.push(f129004)
f129004 = '0' if (f129004.to_s.length == 0)
f130001 = c['f130001'].to_s.tr('-,','')
allnil.push(f130001)
f130001 = '0' if (f130001.to_s.length == 0)
f130002 = c['f130002'].to_s.tr('-,','')
allnil.push(f130002)
f130002 = '0' if (f130002.to_s.length == 0)
f130003 = c['f130003'].to_s.tr('-,','')
allnil.push(f130003)
f130003 = '0' if (f130003.to_s.length == 0)
f130004 = c['f130004'].to_s.tr('-,','')
allnil.push(f130004)
f130004 = '0' if (f130004.to_s.length == 0)
f131001 = c['f131001'].to_s.tr('-,','')
allnil.push(f131001)
f131001 = '0' if (f131001.to_s.length == 0)
f131002 = c['f131002'].to_s.tr('-,','')
allnil.push(f131002)
f131002 = '0' if (f131002.to_s.length == 0)
f131003 = c['f131003'].to_s.tr('-,','')
allnil.push(f131003)
f131003 = '0' if (f131003.to_s.length == 0)
f131004 = c['f131004'].to_s.tr('-,','')
allnil.push(f131004)
f131004 = '0' if (f131004.to_s.length == 0)
f132001 = c['f132001'].to_s.tr('-,','')
allnil.push(f132001)
f132001 = '0' if (f132001.to_s.length == 0)
f132002 = c['f132002'].to_s.tr('-,','')
allnil.push(f132002)
f132002 = '0' if (f132002.to_s.length == 0)
f132003 = c['f132003'].to_s.tr('-,','')
allnil.push(f132003)
f132003 = '0' if (f132003.to_s.length == 0)
f132004 = c['f132004'].to_s.tr('-,','')
allnil.push(f132004)
f132004 = '0' if (f132004.to_s.length == 0)
f133001 = c['f133001'].to_s.tr('-,','')
allnil.push(f133001)
f133001 = '0' if (f133001.to_s.length == 0)
f133002 = c['f133002'].to_s.tr('-,','')
allnil.push(f133002)
f133002 = '0' if (f133002.to_s.length == 0)
f133003 = c['f133003'].to_s.tr('-,','')
allnil.push(f133003)
f133003 = '0' if (f133003.to_s.length == 0)
f133004 = c['f133004'].to_s.tr('-,','')
allnil.push(f133004)
f133004 = '0' if (f133004.to_s.length == 0)
f134001 = c['f134001'].to_s.tr('-,','')
allnil.push(f134001)
f134001 = '0' if (f134001.to_s.length == 0)
f134002 = c['f134002'].to_s.tr('-,','')
allnil.push(f134002)
f134002 = '0' if (f134002.to_s.length == 0)
f134003 = c['f134003'].to_s.tr('-,','')
allnil.push(f134003)
f134003 = '0' if (f134003.to_s.length == 0)
f134004 = c['f134004'].to_s.tr('-,','')
allnil.push(f134004)
f134004 = '0' if (f134004.to_s.length == 0)
f135001 = c['f135001'].to_s.tr('-,','')
allnil.push(f135001)
f135001 = '0' if (f135001.to_s.length == 0)
f135002 = c['f135002'].to_s.tr('-,','')
allnil.push(f135002)
f135002 = '0' if (f135002.to_s.length == 0)
f135003 = c['f135003'].to_s.tr('-,','')
allnil.push(f135003)
f135003 = '0' if (f135003.to_s.length == 0)
f135004 = c['f135004'].to_s.tr('-,','')
allnil.push(f135004)
f135004 = '0' if (f135004.to_s.length == 0)
f136001 = c['f136001'].to_s.tr('-,','')
allnil.push(f136001)
f136001 = '0' if (f136001.to_s.length == 0)
f136002 = c['f136002'].to_s.tr('-,','')
allnil.push(f136002)
f136002 = '0' if (f136002.to_s.length == 0)
f136003 = c['f136003'].to_s.tr('-,','')
allnil.push(f136003)
f136003 = '0' if (f136003.to_s.length == 0)
f136004 = c['f136004'].to_s.tr('-,','')
allnil.push(f136004)
f136004 = '0' if (f136004.to_s.length == 0)
f137001 = c['f137001'].to_s.tr('-,','')
allnil.push(f137001)
f137001 = '0' if (f137001.to_s.length == 0)
f137002 = c['f137002'].to_s.tr('-,','')
allnil.push(f137002)
f137002 = '0' if (f137002.to_s.length == 0)
f137003 = c['f137003'].to_s.tr('-,','')
allnil.push(f137003)
f137003 = '0' if (f137003.to_s.length == 0)
f137004 = c['f137004'].to_s.tr('-,','')
allnil.push(f137004)
f137004 = '0' if (f137004.to_s.length == 0)
f138001 = c['f138001'].to_s.tr('-,','')
allnil.push(f138001)
f138001 = '0' if (f138001.to_s.length == 0)
f138002 = c['f138002'].to_s.tr('-,','')
allnil.push(f138002)
f138002 = '0' if (f138002.to_s.length == 0)
f138003 = c['f138003'].to_s.tr('-,','')
allnil.push(f138003)
f138003 = '0' if (f138003.to_s.length == 0)
f138004 = c['f138004'].to_s.tr('-,','')
allnil.push(f138004)
f138004 = '0' if (f138004.to_s.length == 0)
f139001 = c['f139001'].to_s.tr('-,','')
allnil.push(f139001)
f139001 = '0' if (f139001.to_s.length == 0)
f139002 = c['f139002'].to_s.tr('-,','')
allnil.push(f139002)
f139002 = '0' if (f139002.to_s.length == 0)
f139003 = c['f139003'].to_s.tr('-,','')
allnil.push(f139003)
f139003 = '0' if (f139003.to_s.length == 0)
f139004 = c['f139004'].to_s.tr('-,','')
allnil.push(f139004)
f139004 = '0' if (f139004.to_s.length == 0)
f140001 = c['f140001'].to_s.tr('-,','')
allnil.push(f140001)
f140001 = '0' if (f140001.to_s.length == 0)
f140002 = c['f140002'].to_s.tr('-,','')
allnil.push(f140002)
f140002 = '0' if (f140002.to_s.length == 0)
f140003 = c['f140003'].to_s.tr('-,','')
allnil.push(f140003)
f140003 = '0' if (f140003.to_s.length == 0)
f140004 = c['f140004'].to_s.tr('-,','')
allnil.push(f140004)
f140004 = '0' if (f140004.to_s.length == 0)

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

chk = checkDup("form1", "f1year", "f1hcode", f1year, f1hcode)
  chkDigit('f101001',f101001)
  chkDigit('f101002',f101002)
  chkDigit('f101003',f101003)
  chkDigit('f101004',f101004)
  chkDigit('f102001',f102001)
  chkDigit('f102002',f102002)
  chkDigit('f102003',f102003)
  chkDigit('f102004',f102004)
  chkDigit('f103001',f103001)
  chkDigit('f103002',f103002)
  chkDigit('f103003',f103003)
  chkDigit('f103004',f103004)
  chkDigit('f104001',f104001)
  chkDigit('f104002',f104002)
  chkDigit('f104003',f104003)
  chkDigit('f104004',f104004)
  chkDigit('f105001',f105001)
  chkDigit('f105002',f105002)
  chkDigit('f105003',f105003)
  chkDigit('f105004',f105004)
  chkDigit('f106001',f106001)
  chkDigit('f106002',f106002)
  chkDigit('f106003',f106003)
  chkDigit('f106004',f106004)
  chkDigit('f107001',f107001)
  chkDigit('f107002',f107002)
  chkDigit('f107003',f107003)
  chkDigit('f107004',f107004)
  chkDigit('f108001',f108001)
  chkDigit('f108002',f108002)
  chkDigit('f108003',f108003)
  chkDigit('f108004',f108004)
  chkDigit('f109001',f109001)
  chkDigit('f109002',f109002)
  chkDigit('f109003',f109003)
  chkDigit('f109004',f109004)
  chkDigit('f110001',f110001)
  chkDigit('f110002',f110002)
  chkDigit('f110003',f110003)
  chkDigit('f110004',f110004)
  chkDigit('f111001',f111001)
  chkDigit('f111002',f111002)
  chkDigit('f111003',f111003)
  chkDigit('f111004',f111004)
  chkDigit('f112001',f112001)
  chkDigit('f112002',f112002)
  chkDigit('f112003',f112003)
  chkDigit('f112004',f112004)
  chkDigit('f113001',f113001)
  chkDigit('f113002',f113002)
  chkDigit('f113003',f113003)
  chkDigit('f113004',f113004)
  chkDigit('f114001',f114001)
  chkDigit('f114002',f114002)
  chkDigit('f114003',f114003)
  chkDigit('f114004',f114004)
  chkDigit('f115001',f115001)
  chkDigit('f115002',f115002)
  chkDigit('f115003',f115003)
  chkDigit('f115004',f115004)
  chkDigit('f116001',f116001)
  chkDigit('f116002',f116002)
  chkDigit('f116003',f116003)
  chkDigit('f116004',f116004)
  chkDigit('f117001',f117001)
  chkDigit('f117002',f117002)
  chkDigit('f117003',f117003)
  chkDigit('f117004',f117004)
  chkDigit('f118001',f118001)
  chkDigit('f118002',f118002)
  chkDigit('f118003',f118003)
  chkDigit('f118004',f118004)
  chkDigit('f119001',f119001)
  chkDigit('f119002',f119002)
  chkDigit('f119003',f119003)
  chkDigit('f119004',f119004)
  chkDigit('f120001',f120001)
  chkDigit('f120002',f120002)
  chkDigit('f120003',f120003)
  chkDigit('f120004',f120004)
  chkDigit('f121001',f121001)
  chkDigit('f121002',f121002)
  chkDigit('f121003',f121003)
  chkDigit('f121004',f121004)
  chkDigit('f122001',f122001)
  chkDigit('f122002',f122002)
  chkDigit('f122003',f122003)
  chkDigit('f122004',f122004)
  chkDigit('f123001',f123001)
  chkDigit('f123002',f123002)
  chkDigit('f123003',f123003)
  chkDigit('f123004',f123004)
  chkDigit('f124001',f124001)
  chkDigit('f124002',f124002)
  chkDigit('f124003',f124003)
  chkDigit('f124004',f124004)
  chkDigit('f125001',f125001)
  chkDigit('f125002',f125002)
  chkDigit('f125003',f125003)
  chkDigit('f125004',f125004)
  chkDigit('f126001',f126001)
  chkDigit('f126002',f126002)
  chkDigit('f126003',f126003)
  chkDigit('f126004',f126004)
  chkDigit('f127001',f127001)
  chkDigit('f127002',f127002)
  chkDigit('f127003',f127003)
  chkDigit('f127004',f127004)
  chkDigit('f128001',f128001)
  chkDigit('f128002',f128002)
  chkDigit('f128003',f128003)
  chkDigit('f128004',f128004)
  chkDigit('f129001',f129001)
  chkDigit('f129002',f129002)
  chkDigit('f129003',f129003)
  chkDigit('f129004',f129004)
  chkDigit('f130001',f130001)
  chkDigit('f130002',f130002)
  chkDigit('f130003',f130003)
  chkDigit('f130004',f130004)
  chkDigit('f131001',f131001)
  chkDigit('f131002',f131002)
  chkDigit('f131003',f131003)
  chkDigit('f131004',f131004)
  chkDigit('f132001',f132001)
  chkDigit('f132002',f132002)
  chkDigit('f132003',f132003)
  chkDigit('f132004',f132004)
  chkDigit('f133001',f133001)
  chkDigit('f133002',f133002)
  chkDigit('f133003',f133003)
  chkDigit('f133004',f133004)
  chkDigit('f134001',f134001)
  chkDigit('f134002',f134002)
  chkDigit('f134003',f134003)
  chkDigit('f134004',f134004)
  chkDigit('f135001',f135001)
  chkDigit('f135002',f135002)
  chkDigit('f135003',f135003)
  chkDigit('f135004',f135004)
  chkDigit('f136001',f136001)
  chkDigit('f136002',f136002)
  chkDigit('f136003',f136003)
  chkDigit('f136004',f136004)
  chkDigit('f137001',f137001)
  chkDigit('f137002',f137002)
  chkDigit('f137003',f137003)
  chkDigit('f137004',f137004)
  chkDigit('f138001',f138001)
  chkDigit('f138002',f138002)
  chkDigit('f138003',f138003)
  chkDigit('f138004',f138004)
  chkDigit('f139001',f139001)
  chkDigit('f139002',f139002)
  chkDigit('f139003',f139003)
  chkDigit('f139004',f139004)
  chkDigit('f140001',f140001)
  chkDigit('f140002',f140002)
  chkDigit('f140003',f140003)
  chkDigit('f140004',f140004)

if chk.to_s == 'NODUP'
  sql = "INSERT INTO form1(f1year,f1pname,f1pcode,f1hname,f1hcode,"
  sql = sql << "f101001,f101002,f101003,f101004,"
  sql = sql << "f102001,f102002,f102003,f102004,"
  sql = sql << "f103001,f103002,f103003,f103004,"
  sql = sql << "f104001,f104002,f104003,f104004,"
  sql = sql << "f105001,f105002,f105003,f105004,"
  sql = sql << "f106001,f106002,f106003,f106004,"
  sql = sql << "f107001,f107002,f107003,f107004,"
  sql = sql << "f108001,f108002,f108003,f108004,"
  sql = sql << "f109001,f109002,f109003,f109004,"
  sql = sql << "f110001,f110002,f110003,f110004,"
  sql = sql << "f111001,f111002,f111003,f111004,"
  sql = sql << "f112001,f112002,f112003,f112004,"
  sql = sql << "f113001,f113002,f113003,f113004,"
  sql = sql << "f114001,f114002,f114003,f114004,"
  sql = sql << "f115001,f115002,f115003,f115004,"
  sql = sql << "f116001,f116002,f116003,f116004,"
  sql = sql << "f117001,f117002,f117003,f117004,"
  sql = sql << "f118001,f118002,f118003,f118004,"
  sql = sql << "f119001,f119002,f119003,f119004,"
  sql = sql << "f120001,f120002,f120003,f120004,"
  sql = sql << "f121001,f121002,f121003,f121004,"
  sql = sql << "f122001,f122002,f122003,f122004,"
  sql = sql << "f123001,f123002,f123003,f123004,"
  sql = sql << "f124001,f124002,f124003,f124004,"
  sql = sql << "f125001,f125002,f125003,f125004,"
  sql = sql << "f126001,f126002,f126003,f126004,"
  sql = sql << "f127001,f127002,f127003,f127004,"
  sql = sql << "f128001,f128002,f128003,f128004,"
  sql = sql << "f129001,f129002,f129003,f129004,"
  sql = sql << "f130001,f130002,f130003,f130004,"
  sql = sql << "f131001,f131002,f131003,f131004,"
  sql = sql << "f132001,f132002,f132003,f132004,"
  sql = sql << "f133001,f133002,f133003,f133004,"
  sql = sql << "f134001,f134002,f134003,f134004,"
  sql = sql << "f135001,f135002,f135003,f135004,"
  sql = sql << "f136001,f136002,f136003,f136004,"
  sql = sql << "f137001,f137002,f137003,f137004,"
  sql = sql << "f138001,f138002,f138003,f138004,"
  sql = sql << "f139001,f139002,f139003,f139004,"
  sql = sql << "f140001,f140002,f140003,f140004) "

  sql = sql << "VALUES('#{f1year}','#{f1pname}','#{f1pcode}','#{f1hname}','#{f1hcode}',"
  sql = sql << "'#{f101001}','#{f101002}','#{f101003}','#{f101004}',"
  sql = sql << "'#{f102001}','#{f102002}','#{f102003}','#{f102004}',"
  sql = sql << "'#{f103001}','#{f103002}','#{f103003}','#{f103004}',"
  sql = sql << "'#{f104001}','#{f104002}','#{f104003}','#{f104004}',"
  sql = sql << "'#{f105001}','#{f105002}','#{f105003}','#{f105004}',"
  sql = sql << "'#{f106001}','#{f106002}','#{f106003}','#{f106004}',"
  sql = sql << "'#{f107001}','#{f107002}','#{f107003}','#{f107004}',"
  sql = sql << "'#{f108001}','#{f108002}','#{f108003}','#{f108004}',"
  sql = sql << "'#{f109001}','#{f109002}','#{f109003}','#{f109004}',"
  sql = sql << "'#{f110001}','#{f110002}','#{f110003}','#{f110004}',"
  sql = sql << "'#{f111001}','#{f111002}','#{f111003}','#{f111004}',"
  sql = sql << "'#{f112001}','#{f112002}','#{f112003}','#{f112004}',"
  sql = sql << "'#{f113001}','#{f113002}','#{f113003}','#{f113004}',"
  sql = sql << "'#{f114001}','#{f114002}','#{f114003}','#{f114004}',"
  sql = sql << "'#{f115001}','#{f115002}','#{f115003}','#{f115004}',"
  sql = sql << "'#{f116001}','#{f116002}','#{f116003}','#{f116004}',"
  sql = sql << "'#{f117001}','#{f117002}','#{f117003}','#{f117004}',"
  sql = sql << "'#{f118001}','#{f118002}','#{f118003}','#{f118004}',"
  sql = sql << "'#{f119001}','#{f119002}','#{f119003}','#{f119004}',"
  sql = sql << "'#{f120001}','#{f120002}','#{f120003}','#{f120004}',"
  sql = sql << "'#{f121001}','#{f121002}','#{f121003}','#{f121004}',"
  sql = sql << "'#{f122001}','#{f122002}','#{f122003}','#{f122004}',"
  sql = sql << "'#{f123001}','#{f123002}','#{f123003}','#{f123004}',"
  sql = sql << "'#{f124001}','#{f124002}','#{f124003}','#{f124004}',"
  sql = sql << "'#{f125001}','#{f125002}','#{f125003}','#{f125004}',"
  sql = sql << "'#{f126001}','#{f126002}','#{f126003}','#{f126004}',"
  sql = sql << "'#{f127001}','#{f127002}','#{f127003}','#{f127004}',"
  sql = sql << "'#{f128001}','#{f128002}','#{f128003}','#{f128004}',"
  sql = sql << "'#{f129001}','#{f129002}','#{f129003}','#{f129004}',"
  sql = sql << "'#{f130001}','#{f130002}','#{f130003}','#{f130004}',"
  sql = sql << "'#{f131001}','#{f131002}','#{f131003}','#{f131004}',"
  sql = sql << "'#{f132001}','#{f132002}','#{f132003}','#{f132004}',"
  sql = sql << "'#{f133001}','#{f133002}','#{f133003}','#{f133004}',"
  sql = sql << "'#{f134001}','#{f134002}','#{f134003}','#{f134004}',"
  sql = sql << "'#{f135001}','#{f135002}','#{f135003}','#{f135004}',"
  sql = sql << "'#{f136001}','#{f136002}','#{f136003}','#{f136004}',"
  sql = sql << "'#{f137001}','#{f137002}','#{f137003}','#{f137004}',"
  sql = sql << "'#{f138001}','#{f138002}','#{f138003}','#{f138004}',"
  sql = sql << "'#{f139001}','#{f139002}','#{f139003}','#{f139004}',"
  sql = sql << "'#{f140001}','#{f140002}','#{f140003}','#{f140004}')"
  res = con.exec(sql)
elsif chk == 'DUP'
  chkDigit('f101001',f101001)
  sql = "UPDATE form1 SET "
  sql = sql << "f101001='#{f101001.to_s}',f101002='#{f101002.to_s}',"
  sql = sql << "f101003='#{f101003.to_s}',f101004='#{f101004.to_s}',"
  sql = sql << "f102001='#{f102001.to_s}',f102002='#{f102002.to_s}',"
  sql = sql << "f102003='#{f102003.to_s}',f102004='#{f102004.to_s}',"
  sql = sql << "f103001='#{f103001.to_s}',f103002='#{f103002.to_s}',"
  sql = sql << "f103003='#{f103003.to_s}',f103004='#{f103004.to_s}',"
  sql = sql << "f104001='#{f104001.to_s}',f104002='#{f104002.to_s}',"
  sql = sql << "f104003='#{f104003.to_s}',f104004='#{f104004.to_s}',"
  sql = sql << "f105001='#{f105001.to_s}',f105002='#{f105002.to_s}',"
  sql = sql << "f105003='#{f105003.to_s}',f105004='#{f105004.to_s}',"
  sql = sql << "f106001='#{f106001.to_s}',f106002='#{f106002.to_s}',"
  sql = sql << "f106003='#{f106003.to_s}',f106004='#{f106004.to_s}',"
  sql = sql << "f107001='#{f107001.to_s}',f107002='#{f107002.to_s}',"
  sql = sql << "f107003='#{f107003.to_s}',f107004='#{f107004.to_s}',"
  sql = sql << "f108001='#{f108001.to_s}',f108002='#{f108002.to_s}',"
  sql = sql << "f108003='#{f108003.to_s}',f108004='#{f108004.to_s}',"
  sql = sql << "f109001='#{f109001.to_s}',f109002='#{f109002.to_s}',"
  sql = sql << "f109003='#{f109003.to_s}',f109004='#{f109004.to_s}',"
  sql = sql << "f110001='#{f110001.to_s}',f110002='#{f110002.to_s}',"
  sql = sql << "f110003='#{f110003.to_s}',f110004='#{f110004.to_s}',"
  sql = sql << "f111001='#{f111001.to_s}',f111002='#{f111002.to_s}',"
  sql = sql << "f111003='#{f111003.to_s}',f111004='#{f111004.to_s}',"
  sql = sql << "f112001='#{f112001.to_s}',f112002='#{f112002.to_s}',"
  sql = sql << "f112003='#{f112003.to_s}',f112004='#{f112004.to_s}',"
  sql = sql << "f113001='#{f113001.to_s}',f113002='#{f113002.to_s}',"
  sql = sql << "f113003='#{f113003.to_s}',f113004='#{f113004.to_s}',"
  sql = sql << "f114001='#{f114001.to_s}',f114002='#{f114002.to_s}',"
  sql = sql << "f114003='#{f114003.to_s}',f114004='#{f114004.to_s}',"
  sql = sql << "f115001='#{f115001.to_s}',f115002='#{f115002.to_s}',"
  sql = sql << "f115003='#{f115003.to_s}',f115004='#{f115004.to_s}',"
  sql = sql << "f116001='#{f116001.to_s}',f116002='#{f116002.to_s}',"
  sql = sql << "f116003='#{f116003.to_s}',f116004='#{f116004.to_s}',"
  sql = sql << "f117001='#{f117001.to_s}',f117002='#{f117002.to_s}',"
  sql = sql << "f117003='#{f117003.to_s}',f117004='#{f117004.to_s}',"
  sql = sql << "f118001='#{f118001.to_s}',f118002='#{f118002.to_s}',"
  sql = sql << "f118003='#{f118003.to_s}',f118004='#{f118004.to_s}',"
  sql = sql << "f119001='#{f119001.to_s}',f119002='#{f119002.to_s}',"
  sql = sql << "f119003='#{f119003.to_s}',f119004='#{f119004.to_s}',"
  sql = sql << "f120001='#{f120001.to_s}',f120002='#{f120002.to_s}',"
  sql = sql << "f120003='#{f120003.to_s}',f120004='#{f120004.to_s}',"
  sql = sql << "f121001='#{f121001.to_s}',f121002='#{f121002.to_s}',"
  sql = sql << "f121003='#{f121004.to_s}',f121004='#{f121004.to_s}',"
  sql = sql << "f122001='#{f122001.to_s}',f122002='#{f122002.to_s}',"
  sql = sql << "f122003='#{f122003.to_s}',f122004='#{f122004.to_s}',"
  sql = sql << "f123001='#{f123001.to_s}',f123002='#{f123002.to_s}',"
  sql = sql << "f123003='#{f123003.to_s}',f123004='#{f123004.to_s}',"
  sql = sql << "f124001='#{f124001.to_s}',f124002='#{f124002.to_s}',"
  sql = sql << "f124003='#{f124003.to_s}',f124004='#{f124004.to_s}',"
  sql = sql << "f125001='#{f125001.to_s}',f125002='#{f125002.to_s}',"
  sql = sql << "f125003='#{f125003.to_s}',f125004='#{f125004.to_s}',"
  sql = sql << "f126001='#{f126001.to_s}',f126002='#{f126002.to_s}',"
  sql = sql << "f126003='#{f126003.to_s}',f126004='#{f126004.to_s}',"
  sql = sql << "f127001='#{f127001.to_s}',f127002='#{f127002.to_s}',"
  sql = sql << "f127003='#{f127003.to_s}',f127004='#{f127004.to_s}',"
  sql = sql << "f128001='#{f128001.to_s}',f128002='#{f128002.to_s}',"
  sql = sql << "f128003='#{f128003.to_s}',f128004='#{f128004.to_s}',"
  sql = sql << "f129001='#{f129001.to_s}',f129002='#{f129002.to_s}',"
  sql = sql << "f129003='#{f129003.to_s}',f129004='#{f129004.to_s}',"
  sql = sql << "f130001='#{f130001.to_s}',f130002='#{f130002.to_s}',"
  sql = sql << "f130003='#{f130003.to_s}',f130004='#{f130004.to_s}',"
  sql = sql << "f131001='#{f131001.to_s}',f131002='#{f131002.to_s}',"
  sql = sql << "f131003='#{f131003.to_s}',f131004='#{f131004.to_s}',"
  sql = sql << "f132001='#{f132001.to_s}',f132002='#{f132002.to_s}',"
  sql = sql << "f132003='#{f132003.to_s}',f132004='#{f132004.to_s}',"
  sql = sql << "f133001='#{f133001.to_s}',f133002='#{f133002.to_s}',"
  sql = sql << "f133003='#{f133003.to_s}',f133004='#{f133004.to_s}',"
  sql = sql << "f134001='#{f134001.to_s}',f134002='#{f134002.to_s}',"
  sql = sql << "f134003='#{f134003.to_s}',f134004='#{f134004.to_s}',"
  sql = sql << "f135001='#{f135001.to_s}',f135002='#{f135002.to_s}',"
  sql = sql << "f135003='#{f135003.to_s}',f135004='#{f135004.to_s}',"
  sql = sql << "f136001='#{f136001.to_s}',f136002='#{f136002.to_s}',"
  sql = sql << "f136003='#{f136003.to_s}',f136004='#{f136004.to_s}',"
  sql = sql << "f137001='#{f137001.to_s}',f137002='#{f137002.to_s}',"
  sql = sql << "f137003='#{f137003.to_s}',f137004='#{f137004.to_s}',"
  sql = sql << "f138001='#{f138001.to_s}',f138002='#{f138002.to_s}',"
  sql = sql << "f138003='#{f138003.to_s}',f138004='#{f138004.to_s}',"
  sql = sql << "f139001='#{f139001.to_s}',f139002='#{f139002.to_s}',"
  sql = sql << "f139003='#{f139003.to_s}',f139004='#{f139004.to_s}',"
  sql = sql << "f140001='#{f140001.to_s}',f140002='#{f140002.to_s}',"
  sql = sql << "f140003='#{f140003.to_s}',f140004='#{f140004.to_s}' "
  sql = sql << "WHERE f1year='#{f1year}' and f1hcode='#{f1hcode}' "
  res = con.exec(sql)
end

con.close

updateReportMon(f1hcode,f1year,"form1")

#check X for FORM2 if mdtotal = 0
mdtotal = f101001.to_i + f101002.to_i + f101003.to_i + f101004.to_i
comment = "<h3>โปรดบันทึกแบบฟอร์มที่ 2 ต่อไป</h3>"

if (mdtotal == 0)
  checkXForm2(f1hcode)
  comment = "<h3>ไม่ต้องบันทึก Form 2 โปรดข้ามไปบันทึก Form 3 ต่อไป</h3>"
end

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f1hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<meta http-equiv=Content-Type content="text/html; charset=UTF-8" />
<!-- src: form1.rb -->
<body text='blue'>
<center>
<h3>บันทึกแบบฟอร์ม 1 สำหรับ #{ f1hname.to_s }(#{ f1hcode.to_s }) 
เรียบร้อยแล้ว</h3>
#{comment}
<p>
<input type='button' value='Back' onClick='history.back();'>
</center>
</body>
</html>
EOF

