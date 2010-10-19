#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'hr_util.rb'
require 'res_util.rb'

def keepSql(sql)
  log = open("/tmp/resSql","a")
  log.write(sql)
  log.write("\n")
  log.close
  exit
end

allnil = Array.new

c = CGI::new
f2year = c['f2year'].to_s
f2pname = c['f2pname'].to_s
f2pcode = c['f2pcode'].to_s
f2hname = c['f2hname'].to_s
f2hcode = c['f2hcode'].to_s
f201001 = c['f201001'].to_s.tr('-,','')
allnil.push(f201001)
f201001 = '0' if (f201001.to_s.length == 0) # ขรก/พ.ของรัฐ ชาย
f201002 = c['f201002'].to_s.tr('-,','')
allnil.push(f201002)
f201002 = '0' if (f201002.to_s.length == 0) # ขรก/พ.ของรัฐ หญิง
f201003 = c['f201003'].to_s.tr('-,','')
allnil.push(f201003)
f201003 = '0' if (f201003.to_s.length == 0) # ลูกจ้างชาย
f201004 = c['f201004'].to_s.tr('-,','')
allnil.push(f201004)
f201004 = '0' if (f201004.to_s.length == 0) # ลูกจ้างหญิง
f202001 = c['f202001'].to_s.tr('-,','')
allnil.push(f202001)
f202001 = '0' if (f202001.to_s.length == 0)
f202002 = c['f202002'].to_s.tr('-,','')
allnil.push(f202002)
f202002 = '0' if (f202002.to_s.length == 0)
f202003 = c['f202003'].to_s.tr('-,','')
allnil.push(f202003)
f202003 = '0' if (f202003.to_s.length == 0)
f202004 = c['f202004'].to_s.tr('-,','')
allnil.push(f202004)
f202004 = '0' if (f202004.to_s.length == 0)
f203001 = c['f203001'].to_s.tr('-,','')
allnil.push(f203001)
f203001 = '0' if (f203001.to_s.length == 0)
f203002 = c['f203002'].to_s.tr('-,','')
allnil.push(f203002)
f203002 = '0' if (f203002.to_s.length == 0)
f203003 = c['f203003'].to_s.tr('-,','')
allnil.push(f203003)
f203003 = '0' if (f203003.to_s.length == 0)
f203004 = c['f203004'].to_s.tr('-,','')
allnil.push(f203004)
f203004 = '0' if (f203004.to_s.length == 0)
f204001 = c['f204001'].to_s.tr('-,','')
allnil.push(f204001)
f204001 = '0' if (f204001.to_s.length == 0)
f204002 = c['f204002'].to_s.tr('-,','')
allnil.push(f204002)
f204002 = '0' if (f204002.to_s.length == 0)
f204003 = c['f204003'].to_s.tr('-,','')
allnil.push(f204003)
f204003 = '0' if (f204003.to_s.length == 0)
f204004 = c['f204004'].to_s.tr('-,','')
allnil.push(f204004)
f204004 = '0' if (f204004.to_s.length == 0)
f205001 = c['f205001'].to_s.tr('-,','')
allnil.push(f205001)
f205001 = '0' if (f205001.to_s.length == 0)
f205002 = c['f205002'].to_s.tr('-,','')
allnil.push(f205002)
f205002 = '0' if (f205002.to_s.length == 0)
f205003 = c['f205003'].to_s.tr('-,','')
allnil.push(f205003)
f205003 = '0' if (f205003.to_s.length == 0)
f205004 = c['f205004'].to_s.tr('-,','')
allnil.push(f205004)
f205004 = '0' if (f205004.to_s.length == 0)
f206001 = c['f206001'].to_s.tr('-,','')
allnil.push(f206001)
f206001 = '0' if (f206001.to_s.length == 0)
f206002 = c['f206002'].to_s.tr('-,','')
allnil.push(f206002)
f206002 = '0' if (f206002.to_s.length == 0)
f206003 = c['f206003'].to_s.tr('-,','')
allnil.push(f206003)
f206003 = '0' if (f206003.to_s.length == 0)
f206004 = c['f206004'].to_s.tr('-,','')
allnil.push(f206004)
f206004 = '0' if (f206004.to_s.length == 0)
f207001 = c['f207001'].to_s.tr('-,','')
allnil.push(f207001)
f207001 = '0' if (f207001.to_s.length == 0)
f207002 = c['f207002'].to_s.tr('-,','')
allnil.push(f207002)
f207002 = '0' if (f207002.to_s.length == 0)
f207003 = c['f207003'].to_s.tr('-,','')
allnil.push(f207003)
f207003 = '0' if (f207003.to_s.length == 0)
f207004 = c['f207004'].to_s.tr('-,','')
allnil.push(f207004)
f207004 = '0' if (f207004.to_s.length == 0)
f208001 = c['f208001'].to_s.tr('-,','')
allnil.push(f208001)
f208001 = '0' if (f208001.to_s.length == 0)
f208002 = c['f208002'].to_s.tr('-,','')
allnil.push(f208002)
f208002 = '0' if (f208002.to_s.length == 0)
f208003 = c['f208003'].to_s.tr('-,','')
allnil.push(f208003)
f208003 = '0' if (f208003.to_s.length == 0)
f208004 = c['f208004'].to_s.tr('-,','')
allnil.push(f208004)
f208004 = '0' if (f208004.to_s.length == 0)
f209001 = c['f209001'].to_s.tr('-,','')
allnil.push(f209001)
f209001 = '0' if (f209001.to_s.length == 0)
f209002 = c['f209002'].to_s.tr('-,','')
allnil.push(f209002)
f209002 = '0' if (f209002.to_s.length == 0)
f209003 = c['f209003'].to_s.tr('-,','')
allnil.push(f209003)
f209003 = '0' if (f209003.to_s.length == 0)
f209004 = c['f209004'].to_s.tr('-,','')
allnil.push(f209004)
f209004 = '0' if (f209004.to_s.length == 0)
f210001 = c['f210001'].to_s.tr('-,','')
allnil.push(f210001)
f210001 = '0' if (f210001.to_s.length == 0)
f210002 = c['f210002'].to_s.tr('-,','')
allnil.push(f210002)
f210002 = '0' if (f210002.to_s.length == 0)
f210003 = c['f210003'].to_s.tr('-,','')
allnil.push(f210003)
f210003 = '0' if (f210003.to_s.length == 0)
f210004 = c['f210004'].to_s.tr('-,','')
allnil.push(f210004)
f210004 = '0' if (f210004.to_s.length == 0)
f211001 = c['f211001'].to_s.tr('-,','')
allnil.push(f211001)
f211001 = '0' if (f211001.to_s.length == 0)
f211002 = c['f211002'].to_s.tr('-,','')
allnil.push(f211002)
f211002 = '0' if (f211002.to_s.length == 0)
f211003 = c['f211003'].to_s.tr('-,','')
allnil.push(f211003)
f211003 = '0' if (f211003.to_s.length == 0)
f211004 = c['f211004'].to_s.tr('-,','')
allnil.push(f211004)
f211004 = '0' if (f211004.to_s.length == 0)
f212001 = c['f212001'].to_s.tr('-,','')
allnil.push(f212001)
f212001 = '0' if (f212001.to_s.length == 0)
f212002 = c['f212002'].to_s.tr('-,','')
allnil.push(f212002)
f212002 = '0' if (f212002.to_s.length == 0)
f212003 = c['f212003'].to_s.tr('-,','')
allnil.push(f212003)
f212003 = '0' if (f212003.to_s.length == 0)
f212004 = c['f212004'].to_s.tr('-,','')
allnil.push(f212004)
f212004 = '0' if (f212004.to_s.length == 0)
f213001 = c['f213001'].to_s.tr('-,','')
allnil.push(f213001)
f213001 = '0' if (f213001.to_s.length == 0)
f213002 = c['f213002'].to_s.tr('-,','')
allnil.push(f213002)
f213002 = '0' if (f213002.to_s.length == 0)
f213003 = c['f213003'].to_s.tr('-,','')
allnil.push(f213003)
f213003 = '0' if (f213003.to_s.length == 0)
f213004 = c['f213004'].to_s.tr('-,','')
allnil.push(f213004)
f213004 = '0' if (f213004.to_s.length == 0)
f214001 = c['f214001'].to_s.tr('-,','')
allnil.push(f214001)
f214001 = '0' if (f214001.to_s.length == 0)
f214002 = c['f214002'].to_s.tr('-,','')
allnil.push(f214002)
f214002 = '0' if (f214002.to_s.length == 0)
f214003 = c['f214003'].to_s.tr('-,','')
allnil.push(f214003)
f214003 = '0' if (f214003.to_s.length == 0)
f214004 = c['f214004'].to_s.tr('-,','')
allnil.push(f214004)
f214004 = '0' if (f214004.to_s.length == 0)
f215001 = c['f215001'].to_s.tr('-,','')
allnil.push(f215001)
f215001 = '0' if (f215001.to_s.length == 0)
f215002 = c['f215002'].to_s.tr('-,','')
allnil.push(f215002)
f215002 = '0' if (f215002.to_s.length == 0)
f215003 = c['f215003'].to_s.tr('-,','')
allnil.push(f215003)
f215003 = '0' if (f215003.to_s.length == 0)
f215004 = c['f215004'].to_s.tr('-,','')
allnil.push(f215004)
f215004 = '0' if (f215004.to_s.length == 0)
f216001 = c['f216001'].to_s.tr('-,','')
allnil.push(f216001)
f216001 = '0' if (f216001.to_s.length == 0)
f216002 = c['f216002'].to_s.tr('-,','')
allnil.push(f216002)
f216002 = '0' if (f216002.to_s.length == 0)
f216003 = c['f216003'].to_s.tr('-,','')
allnil.push(f216003)
f216003 = '0' if (f216003.to_s.length == 0)
f216004 = c['f216004'].to_s.tr('-,','')
allnil.push(f216004)
f216004 = '0' if (f216004.to_s.length == 0)
f217001 = c['f217001'].to_s.tr('-,','')
allnil.push(f217001)
f217001 = '0' if (f217001.to_s.length == 0)
f217002 = c['f217002'].to_s.tr('-,','')
allnil.push(f217002)
f217002 = '0' if (f217002.to_s.length == 0)
f217003 = c['f217003'].to_s.tr('-,','')
allnil.push(f217003)
f217003 = '0' if (f217003.to_s.length == 0)
f217004 = c['f217004'].to_s.tr('-,','')
allnil.push(f217004)
f217004 = '0' if (f217004.to_s.length == 0)
f218001 = c['f218001'].to_s.tr('-,','')
allnil.push(f218001)
f218001 = '0' if (f218001.to_s.length == 0)
f218002 = c['f218002'].to_s.tr('-,','')
allnil.push(f218002)
f218002 = '0' if (f218002.to_s.length == 0)
f218003 = c['f218003'].to_s.tr('-,','')
allnil.push(f218003)
f218003 = '0' if (f218003.to_s.length == 0)
f218004 = c['f218004'].to_s.tr('-,','')
allnil.push(f218004)
f218004 = '0' if (f218004.to_s.length == 0)
f219001 = c['f219001'].to_s.tr('-,','')
allnil.push(f219001)
f219001 = '0' if (f219001.to_s.length == 0)
f219002 = c['f219002'].to_s.tr('-,','')
allnil.push(f219002)
f219002 = '0' if (f219002.to_s.length == 0)
f219003 = c['f219003'].to_s.tr('-,','')
allnil.push(f219003)
f219003 = '0' if (f219003.to_s.length == 0)
f219004 = c['f219004'].to_s.tr('-,','')
allnil.push(f219004)
f219004 = '0' if (f219004.to_s.length == 0)
f220001 = c['f220001'].to_s.tr('-,','')
allnil.push(f220001)
f220001 = '0' if (f220001.to_s.length == 0)
f220002 = c['f220002'].to_s.tr('-,','')
allnil.push(f220002)
f220002 = '0' if (f220002.to_s.length == 0)
f220003 = c['f220003'].to_s.tr('-,','')
allnil.push(f220003)
f220003 = '0' if (f220003.to_s.length == 0)
f220004 = c['f220004'].to_s.tr('-,','')
allnil.push(f220004)
f220004 = '0' if (f220004.to_s.length == 0)
f221001 = c['f221001'].to_s.tr('-,','')
allnil.push(f221001)
f221001 = '0' if (f221001.to_s.length == 0)
f221002 = c['f221002'].to_s.tr('-,','')
allnil.push(f221002)
f221002 = '0' if (f221002.to_s.length == 0)
f221003 = c['f221003'].to_s.tr('-,','')
allnil.push(f221003)
f221003 = '0' if (f221003.to_s.length == 0)
f221004 = c['f221004'].to_s.tr('-,','')
allnil.push(f221004)
f221004 = '0' if (f221004.to_s.length == 0)
f222001 = c['f222001'].to_s.tr('-,','')
allnil.push(f222001)
f222001 = '0' if (f222001.to_s.length == 0)
f222002 = c['f222002'].to_s.tr('-,','')
allnil.push(f222002)
f222002 = '0' if (f222002.to_s.length == 0)
f222003 = c['f222003'].to_s.tr('-,','')
allnil.push(f222003)
f222003 = '0' if (f222003.to_s.length == 0)
f222004 = c['f222004'].to_s.tr('-,','')
allnil.push(f222004)
f222004 = '0' if (f222004.to_s.length == 0)
f223001 = c['f223001'].to_s.tr('-,','')
allnil.push(f223001)
f223001 = '0' if (f223001.to_s.length == 0)
f223002 = c['f223002'].to_s.tr('-,','')
allnil.push(f223002)
f223002 = '0' if (f223002.to_s.length == 0)
f223003 = c['f223003'].to_s.tr('-,','')
allnil.push(f223003)
f223003 = '0' if (f223003.to_s.length == 0)
f223004 = c['f223004'].to_s.tr('-,','')
allnil.push(f223004)
f223004 = '0' if (f223004.to_s.length == 0)
f224001 = c['f224001'].to_s.tr('-,','')
allnil.push(f224001)
f224001 = '0' if (f224001.to_s.length == 0)
f224002 = c['f224002'].to_s.tr('-,','')
allnil.push(f224002)
f224002 = '0' if (f224002.to_s.length == 0)
f224003 = c['f224003'].to_s.tr('-,','')
allnil.push(f224003)
f224003 = '0' if (f224003.to_s.length == 0)
f224004 = c['f224004'].to_s.tr('-,','')
allnil.push(f224004)
f224004 = '0' if (f224004.to_s.length == 0)
f225001 = c['f225001'].to_s.tr('-,','')
allnil.push(f225001)
f225001 = '0' if (f225001.to_s.length == 0)
f225002 = c['f225002'].to_s.tr('-,','')
allnil.push(f225002)
f225002 = '0' if (f225002.to_s.length == 0)
f225003 = c['f225003'].to_s.tr('-,','')
allnil.push(f225003)
f225003 = '0' if (f225003.to_s.length == 0)
f225004 = c['f225004'].to_s.tr('-,','')
allnil.push(f225004)
f225004 = '0' if (f225004.to_s.length == 0)
f226001 = c['f226001'].to_s.tr('-,','')
allnil.push(f226001)
f226001 = '0' if (f226001.to_s.length == 0)
f226002 = c['f226002'].to_s.tr('-,','')
allnil.push(f226002)
f226002 = '0' if (f226002.to_s.length == 0)
f226003 = c['f226003'].to_s.tr('-,','')
allnil.push(f226003)
f226003 = '0' if (f226003.to_s.length == 0)
f226004 = c['f226004'].to_s.tr('-,','')
allnil.push(f226004)
f226004 = '0' if (f226004.to_s.length == 0)
f227001 = c['f227001'].to_s.tr('-,','')
allnil.push(f227001)
f227001 = '0' if (f227001.to_s.length == 0)
f227002 = c['f227002'].to_s.tr('-,','')
allnil.push(f227002)
f227002 = '0' if (f227002.to_s.length == 0)
f227003 = c['f227003'].to_s.tr('-,','')
allnil.push(f227003)
f227003 = '0' if (f227003.to_s.length == 0)
f227004 = c['f227004'].to_s.tr('-,','')
allnil.push(f227004)
f227004 = '0' if (f227004.to_s.length == 0)
f228001 = c['f228001'].to_s.tr('-,','')
allnil.push(f228001)
f228001 = '0' if (f228001.to_s.length == 0)
f228002 = c['f228002'].to_s.tr('-,','')
allnil.push(f228002)
f228002 = '0' if (f228002.to_s.length == 0)
f228003 = c['f228003'].to_s.tr('-,','')
allnil.push(f228003)
f228003 = '0' if (f228003.to_s.length == 0)
f228004 = c['f228004'].to_s.tr('-,','')
allnil.push(f228004)
f228004 = '0' if (f228004.to_s.length == 0)
f229001 = c['f229001'].to_s.tr('-,','')
allnil.push(f229001)
f229001 = '0' if (f229001.to_s.length == 0)
f229002 = c['f229002'].to_s.tr('-,','')
allnil.push(f229002)
f229002 = '0' if (f229002.to_s.length == 0)
f229003 = c['f229003'].to_s.tr('-,','')
allnil.push(f229003)
f229003 = '0' if (f229003.to_s.length == 0)
f229004 = c['f229004'].to_s.tr('-,','')
allnil.push(f229004)
f229004 = '0' if (f229004.to_s.length == 0)
f230001 = c['f230001'].to_s.tr('-,','')
allnil.push(f230001)
f230001 = '0' if (f230001.to_s.length == 0)
f230002 = c['f230002'].to_s.tr('-,','')
allnil.push(f230002)
f230002 = '0' if (f230002.to_s.length == 0)
f230003 = c['f230003'].to_s.tr('-,','')
allnil.push(f230003)
f230003 = '0' if (f230003.to_s.length == 0)
f230004 = c['f230004'].to_s.tr('-,','')
allnil.push(f230004)
f230004 = '0' if (f230004.to_s.length == 0)
f231001 = c['f231001'].to_s.tr('-,','')
allnil.push(f231001)
f231001 = '0' if (f231001.to_s.length == 0)
f231002 = c['f231002'].to_s.tr('-,','')
allnil.push(f231002)
f231002 = '0' if (f231002.to_s.length == 0)
f231003 = c['f231003'].to_s.tr('-,','')
allnil.push(f231003)
f231003 = '0' if (f231003.to_s.length == 0)
f231004 = c['f231004'].to_s.tr('-,','')
allnil.push(f231004)
f231004 = '0' if (f231004.to_s.length == 0)
f232001 = c['f232001'].to_s.tr('-,','')
allnil.push(f232001)
f232001 = '0' if (f232001.to_s.length == 0)
f232002 = c['f232002'].to_s.tr('-,','')
allnil.push(f232002)
f232002 = '0' if (f232002.to_s.length == 0)
f232003 = c['f232003'].to_s.tr('-,','')
allnil.push(f232003)
f232003 = '0' if (f232003.to_s.length == 0)
f232004 = c['f232004'].to_s.tr('-,','')
allnil.push(f232004)
f232004 = '0' if (f232004.to_s.length == 0)
f233001 = c['f233001'].to_s.tr('-,','')
allnil.push(f233001)
f233001 = '0' if (f233001.to_s.length == 0)
f233002 = c['f233002'].to_s.tr('-,','')
allnil.push(f233002)
f233002 = '0' if (f233002.to_s.length == 0)
f233003 = c['f233003'].to_s.tr('-,','')
allnil.push(f233003)
f233003 = '0' if (f233003.to_s.length == 0)
f233004 = c['f233004'].to_s.tr('-,','')
allnil.push(f233004)
f233004 = '0' if (f233004.to_s.length == 0)
f234001 = c['f234001'].to_s.tr('-,','')
allnil.push(f234001)
f234001 = '0' if (f234001.to_s.length == 0)
f234002 = c['f234002'].to_s.tr('-,','')
allnil.push(f234002)
f234002 = '0' if (f234002.to_s.length == 0)
f234003 = c['f234003'].to_s.tr('-,','')
allnil.push(f234003)
f234003 = '0' if (f234003.to_s.length == 0)
f234004 = c['f234004'].to_s.tr('-,','')
allnil.push(f234004)
f234004 = '0' if (f234004.to_s.length == 0)
f235001 = c['f235001'].to_s.tr('-,','')
allnil.push(f235001)
f235001 = '0' if (f235001.to_s.length == 0)
f235002 = c['f235002'].to_s.tr('-,','')
allnil.push(f235002)
f235002 = '0' if (f235002.to_s.length == 0)
f235003 = c['f235003'].to_s.tr('-,','')
allnil.push(f235003)
f235003 = '0' if (f235003.to_s.length == 0)
f235004 = c['f235004'].to_s.tr('-,','')
allnil.push(f235004)
f235004 = '0' if (f235004.to_s.length == 0)
f236001 = c['f236001'].to_s.tr('-,','')
allnil.push(f236001)
f236001 = '0' if (f236001.to_s.length == 0)
f236002 = c['f236002'].to_s.tr('-,','')
allnil.push(f236002)
f236002 = '0' if (f236002.to_s.length == 0)
f236003 = c['f236003'].to_s.tr('-,','')
allnil.push(f236003)
f236003 = '0' if (f236003.to_s.length == 0)
f236004 = c['f236004'].to_s.tr('-,','')
allnil.push(f236004)
f236004 = '0' if (f236004.to_s.length == 0)
f237001 = c['f237001'].to_s.tr('-,','')
allnil.push(f237001)
f237001 = '0' if (f237001.to_s.length == 0)
f237002 = c['f237002'].to_s.tr('-,','')
allnil.push(f237002)
f237002 = '0' if (f237002.to_s.length == 0)
f237003 = c['f237003'].to_s.tr('-,','')
allnil.push(f237003)
f237003 = '0' if (f237003.to_s.length == 0)
f237004 = c['f237004'].to_s.tr('-,','')
allnil.push(f237004)
f237004 = '0' if (f237004.to_s.length == 0)
f238001 = c['f238001'].to_s.tr('-,','')
allnil.push(f238001)
f238001 = '0' if (f238001.to_s.length == 0)
f238002 = c['f238002'].to_s.tr('-,','')
allnil.push(f238002)
f238002 = '0' if (f238002.to_s.length == 0)
f238003 = c['f238003'].to_s.tr('-,','')
allnil.push(f238003)
f238003 = '0' if (f238003.to_s.length == 0)
f238004 = c['f238004'].to_s.tr('-,','')
allnil.push(f238004)
f238004 = '0' if (f238004.to_s.length == 0)
f239001 = c['f239001'].to_s.tr('-,','')
allnil.push(f239001)
f239001 = '0' if (f239001.to_s.length == 0)
f239002 = c['f239002'].to_s.tr('-,','')
allnil.push(f239002)
f239002 = '0' if (f239002.to_s.length == 0)
f239003 = c['f239003'].to_s.tr('-,','')
allnil.push(f239003)
f239003 = '0' if (f239003.to_s.length == 0)
f239004 = c['f239004'].to_s.tr('-,','')
allnil.push(f239004)
f239004 = '0' if (f239004.to_s.length == 0)
f240001 = c['f240001'].to_s.tr('-,','')
allnil.push(f240001)
f240001 = '0' if (f240001.to_s.length == 0)
f240002 = c['f240002'].to_s.tr('-,','')
allnil.push(f240002)
f240002 = '0' if (f240002.to_s.length == 0)
f240003 = c['f240003'].to_s.tr('-,','')
allnil.push(f240003)
f240003 = '0' if (f240003.to_s.length == 0)
f240004 = c['f240004'].to_s.tr('-,','')
allnil.push(f240004)
f240004 = '0' if (f240004.to_s.length == 0)
f241001 = c['f241001'].to_s.tr('-,','')
allnil.push(f241001)
f241001 = '0' if (f241001.to_s.length == 0)
f241002 = c['f241002'].to_s.tr('-,','')
allnil.push(f241002)
f241002 = '0' if (f241002.to_s.length == 0)
f241003 = c['f241003'].to_s.tr('-,','')
allnil.push(f241003)
f241003 = '0' if (f241003.to_s.length == 0)
f241004 = c['f241004'].to_s.tr('-,','')
allnil.push(f241004)
f241004 = '0' if (f241004.to_s.length == 0)
f242001 = c['f242001'].to_s.tr('-,','')
allnil.push(f242001)
f242001 = '0' if (f242001.to_s.length == 0)
f242002 = c['f242002'].to_s.tr('-,','')
allnil.push(f242002)
f242002 = '0' if (f242002.to_s.length == 0)
f242003 = c['f242003'].to_s.tr('-,','')
allnil.push(f242003)
f242003 = '0' if (f242003.to_s.length == 0)
f242004 = c['f242004'].to_s.tr('-,','')
allnil.push(f242004)
f242004 = '0' if (f242004.to_s.length == 0)
f243001 = c['f243001'].to_s.tr('-,','')
allnil.push(f243001)
f243001 = '0' if (f243001.to_s.length == 0)
f243002 = c['f243002'].to_s.tr('-,','')
allnil.push(f243002)
f243002 = '0' if (f243002.to_s.length == 0)
f243003 = c['f243003'].to_s.tr('-,','')
allnil.push(f243003)
f243003 = '0' if (f243003.to_s.length == 0)
f243004 = c['f243004'].to_s.tr('-,','')
allnil.push(f243004)
f243004 = '0' if (f243004.to_s.length == 0)
f244001 = c['f244001'].to_s.tr('-,','')
allnil.push(f244001)
f244001 = '0' if (f244001.to_s.length == 0)
f244002 = c['f244002'].to_s.tr('-,','')
allnil.push(f244002)
f244002 = '0' if (f244002.to_s.length == 0)
f244003 = c['f244003'].to_s.tr('-,','')
allnil.push(f244003)
f244003 = '0' if (f244003.to_s.length == 0)
f244004 = c['f244004'].to_s.tr('-,','')
allnil.push(f244004)
f244004 = '0' if (f244004.to_s.length == 0)
f245001 = c['f245001'].to_s.tr('-,','')
allnil.push(f245001)
f245001 = '0' if (f245001.to_s.length == 0)
f245002 = c['f245002'].to_s.tr('-,','')
allnil.push(f245002)
f245002 = '0' if (f245002.to_s.length == 0)
f245003 = c['f245003'].to_s.tr('-,','')
allnil.push(f245003)
f245003 = '0' if (f245003.to_s.length == 0)
f245004 = c['f245004'].to_s.tr('-,','')
allnil.push(f245004)
f245004 = '0' if (f245004.to_s.length == 0)
f246001 = c['f246001'].to_s.tr('-,','')
allnil.push(f246001)
f246001 = '0' if (f246001.to_s.length == 0)
f246002 = c['f246002'].to_s.tr('-,','')
allnil.push(f246002)
f246002 = '0' if (f246002.to_s.length == 0)
f246003 = c['f246003'].to_s.tr('-,','')
allnil.push(f246003)
f246003 = '0' if (f246003.to_s.length == 0)
f246004 = c['f246004'].to_s.tr('-,','')
allnil.push(f246004)
f246004 = '0' if (f246004.to_s.length == 0)
f247001 = c['f247001'].to_s.tr('-,','')
allnil.push(f247001)
f247001 = '0' if (f247001.to_s.length == 0)
f247002 = c['f247002'].to_s.tr('-,','')
allnil.push(f247002)
f247002 = '0' if (f247002.to_s.length == 0)
f247003 = c['f247003'].to_s.tr('-,','')
allnil.push(f247003)
f247003 = '0' if (f247003.to_s.length == 0)
f247004 = c['f247004'].to_s.tr('-,','')
allnil.push(f247004)
f247004 = '0' if (f247004.to_s.length == 0)
f248001 = c['f248001'].to_s.tr('-,','')
allnil.push(f248001)
f248001 = '0' if (f248001.to_s.length == 0)
f248002 = c['f248002'].to_s.tr('-,','')
allnil.push(f248002)
f248002 = '0' if (f248002.to_s.length == 0)
f248003 = c['f248003'].to_s.tr('-,','')
allnil.push(f248003)
f248003 = '0' if (f248003.to_s.length == 0)
f248004 = c['f248004'].to_s.tr('-,','')
allnil.push(f248004)
f248004 = '0' if (f248004.to_s.length == 0)
f249001 = c['f249001'].to_s.tr('-,','')
allnil.push(f249001)
f249001 = '0' if (f249001.to_s.length == 0)
f249002 = c['f249002'].to_s.tr('-,','')
allnil.push(f249002)
f249002 = '0' if (f249002.to_s.length == 0)
f249003 = c['f249003'].to_s.tr('-,','')
allnil.push(f249003)
f249003 = '0' if (f249003.to_s.length == 0)
f249004 = c['f249004'].to_s.tr('-,','')
allnil.push(f249004)
f249004 = '0' if (f249004.to_s.length == 0)
f250001 = c['f250001'].to_s.tr('-,','')
allnil.push(f250001)
f250001 = '0' if (f250001.to_s.length == 0)
f250002 = c['f250002'].to_s.tr('-,','')
allnil.push(f250002)
f250002 = '0' if (f250002.to_s.length == 0)
f250003 = c['f250003'].to_s.tr('-,','')
allnil.push(f250003)
f250003 = '0' if (f250003.to_s.length == 0)
f250004 = c['f250004'].to_s.tr('-,','')
allnil.push(f250004)
f250004 = '0' if (f250004.to_s.length == 0)
f251001 = c['f251001'].to_s.tr('-,','')
allnil.push(f251001)
f251001 = '0' if (f251001.to_s.length == 0)
f251002 = c['f251002'].to_s.tr('-,','')
allnil.push(f251002)
f251002 = '0' if (f251002.to_s.length == 0)
f251003 = c['f251003'].to_s.tr('-,','')
allnil.push(f251003)
f251003 = '0' if (f251003.to_s.length == 0)
f251004 = c['f251004'].to_s.tr('-,','')
allnil.push(f251004)
f251004 = '0' if (f251004.to_s.length == 0)
f252001 = c['f252001'].to_s.tr('-,','')
allnil.push(f252001)
f252001 = '0' if (f252001.to_s.length == 0)
f252002 = c['f252002'].to_s.tr('-,','')
allnil.push(f252002)
f252002 = '0' if (f252002.to_s.length == 0)
f252003 = c['f252003'].to_s.tr('-,','')
allnil.push(f252003)
f252003 = '0' if (f252003.to_s.length == 0)
f252004 = c['f252004'].to_s.tr('-,','')
allnil.push(f252004)
f252004 = '0' if (f252004.to_s.length == 0)
f253001 = c['f253001'].to_s.tr('-,','')
allnil.push(f253001)
f253001 = '0' if (f253001.to_s.length == 0)
f253002 = c['f253002'].to_s.tr('-,','')
allnil.push(f253002)
f253002 = '0' if (f253002.to_s.length == 0)
f253003 = c['f253003'].to_s.tr('-,','')
allnil.push(f253003)
f253003 = '0' if (f253003.to_s.length == 0)
f253004 = c['f253004'].to_s.tr('-,','')
allnil.push(f253004)
f253004 = '0' if (f253004.to_s.length == 0)
f254001 = c['f254001'].to_s.tr('-,','')
allnil.push(f254001)
f254001 = '0' if (f254001.to_s.length == 0)
f254002 = c['f254002'].to_s.tr('-,','')
allnil.push(f254002)
f254002 = '0' if (f254002.to_s.length == 0)
f254003 = c['f254003'].to_s.tr('-,','')
allnil.push(f254003)
f254003 = '0' if (f254003.to_s.length == 0)
f254004 = c['f254004'].to_s.tr('-,','')
allnil.push(f254004)
f254004 = '0' if (f254004.to_s.length == 0)
f255001 = c['f255001'].to_s.tr('-,','')
allnil.push(f255001)
f255001 = '0' if (f255001.to_s.length == 0)
f255002 = c['f255002'].to_s.tr('-,','')
allnil.push(f255002)
f255002 = '0' if (f255002.to_s.length == 0)
f255003 = c['f255003'].to_s.tr('-,','')
allnil.push(f255003)
f255003 = '0' if (f255003.to_s.length == 0)
f255004 = c['f255004'].to_s.tr('-,','')
allnil.push(f255004)
f255004 = '0' if (f255004.to_s.length == 0)
f256001 = c['f256001'].to_s.tr('-,','')
allnil.push(f256001)
f256001 = '0' if (f256001.to_s.length == 0)
f256002 = c['f256002'].to_s.tr('-,','')
allnil.push(f256002)
f256002 = '0' if (f256002.to_s.length == 0)
f256003 = c['f256003'].to_s.tr('-,','')
allnil.push(f256003)
f256003 = '0' if (f256003.to_s.length == 0)
f256004 = c['f256004'].to_s.tr('-,','')
allnil.push(f256004)
f256004 = '0' if (f256004.to_s.length == 0)
f257001 = c['f257001'].to_s.tr('-,','')
allnil.push(f257001)
f257001 = '0' if (f257001.to_s.length == 0)
f257002 = c['f257002'].to_s.tr('-,','')
allnil.push(f257002)
f257002 = '0' if (f257002.to_s.length == 0)
f257003 = c['f257003'].to_s.tr('-,','')
allnil.push(f257003)
f257003 = '0' if (f257003.to_s.length == 0)
f257004 = c['f257004'].to_s.tr('-,','')
allnil.push(f257004)
f257004 = '0' if (f257004.to_s.length == 0)
f258001 = c['f258001'].to_s.tr('-,','')
allnil.push(f258001)
f258001 = '0' if (f258001.to_s.length == 0)
f258002 = c['f258002'].to_s.tr('-,','')
allnil.push(f258002)
f258002 = '0' if (f258002.to_s.length == 0)
f258003 = c['f258003'].to_s.tr('-,','')
allnil.push(f258003)
f258003 = '0' if (f258003.to_s.length == 0)
f258004 = c['f258004'].to_s.tr('-,','')
allnil.push(f258004)
f258004 = '0' if (f258004.to_s.length == 0)
f259001 = c['f259001'].to_s.tr('-,','')
allnil.push(f259001)
f259001 = '0' if (f259001.to_s.length == 0)
f259002 = c['f259002'].to_s.tr('-,','')
allnil.push(f259002)
f259002 = '0' if (f259002.to_s.length == 0)
f259003 = c['f259003'].to_s.tr('-,','')
allnil.push(f259003)
f259003 = '0' if (f259003.to_s.length == 0)
f259004 = c['f259004'].to_s.tr('-,','')
allnil.push(f259004)
f259004 = '0' if (f259004.to_s.length == 0)
f260001 = c['f260001'].to_s.tr('-,','')
allnil.push(f260001)
f260001 = '0' if (f260001.to_s.length == 0)
f260002 = c['f260002'].to_s.tr('-,','')
allnil.push(f260002)
f260002 = '0' if (f260002.to_s.length == 0)
f260003 = c['f260003'].to_s.tr('-,','')
allnil.push(f260003)
f260003 = '0' if (f260003.to_s.length == 0)
f260004 = c['f260004'].to_s.tr('-,','')
allnil.push(f260004)
f260004 = '0' if (f260004.to_s.length == 0)
f261001 = c['f261001'].to_s.tr('-,','')
allnil.push(f261001)
f261001 = '0' if (f261001.to_s.length == 0)
f261002 = c['f261002'].to_s.tr('-,','')
allnil.push(f261002)
f261002 = '0' if (f261002.to_s.length == 0)
f261003 = c['f261003'].to_s.tr('-,','')
allnil.push(f261003)
f261003 = '0' if (f261003.to_s.length == 0)
f261004 = c['f261004'].to_s.tr('-,','')
allnil.push(f261004)
f261004 = '0' if (f261004.to_s.length == 0)
f262001 = c['f262001'].to_s.tr('-,','')
allnil.push(f262001)
f262001 = '0' if (f262001.to_s.length == 0)
f262002 = c['f262002'].to_s.tr('-,','')
allnil.push(f262002)
f262002 = '0' if (f262002.to_s.length == 0)
f262003 = c['f262003'].to_s.tr('-,','')
allnil.push(f262003)
f262003 = '0' if (f262003.to_s.length == 0)
f262004 = c['f262004'].to_s.tr('-,','')
allnil.push(f262004)
f262004 = '0' if (f262004.to_s.length == 0)
f263001 = c['f263001'].to_s.tr('-,','')
allnil.push(f263001)
f263001 = '0' if (f263001.to_s.length == 0)
f263002 = c['f263002'].to_s.tr('-,','')
allnil.push(f263002)
f263002 = '0' if (f263002.to_s.length == 0)
f263003 = c['f263003'].to_s.tr('-,','')
allnil.push(f263003)
f263003 = '0' if (f263003.to_s.length == 0)
f263004 = c['f263004'].to_s.tr('-,','')
allnil.push(f263004)
f263004 = '0' if (f263004.to_s.length == 0)
f264001 = c['f264001'].to_s.tr('-,','')
allnil.push(f264001)
f264001 = '0' if (f264001.to_s.length == 0)
f264002 = c['f264002'].to_s.tr('-,','')
allnil.push(f264002)
f264002 = '0' if (f264002.to_s.length == 0)
f264003 = c['f264003'].to_s.tr('-,','')
allnil.push(f264003)
f264003 = '0' if (f264003.to_s.length == 0)
f264004 = c['f264004'].to_s.tr('-,','')
allnil.push(f264004)
f264004 = '0' if (f264004.to_s.length == 0)
f265001 = c['f265001'].to_s.tr('-,','')
allnil.push(f265001)
f265001 = '0' if (f265001.to_s.length == 0)
f265002 = c['f265002'].to_s.tr('-,','')
allnil.push(f265002)
f265002 = '0' if (f265002.to_s.length == 0)
f265003 = c['f265003'].to_s.tr('-,','')
allnil.push(f265003)
f265003 = '0' if (f265003.to_s.length == 0)
f265004 = c['f265004'].to_s.tr('-,','')
allnil.push(f265004)
f265004 = '0' if (f265004.to_s.length == 0)
f266001 = c['f266001'].to_s.tr('-,','')
allnil.push(f266001)
f266001 = '0' if (f266001.to_s.length == 0)
f266002 = c['f266002'].to_s.tr('-,','')
allnil.push(f266002)
f266002 = '0' if (f266002.to_s.length == 0)
f266003 = c['f266003'].to_s.tr('-,','')
allnil.push(f266003)
f266003 = '0' if (f266003.to_s.length == 0)
f266004 = c['f266004'].to_s.tr('-,','')
allnil.push(f266004)
f266004 = '0' if (f266004.to_s.length == 0)
f267001 = c['f267001'].to_s.tr('-,','')
allnil.push(f267001)
f267001 = '0' if (f267001.to_s.length == 0)
f267002 = c['f267002'].to_s.tr('-,','')
allnil.push(f267002)
f267002 = '0' if (f267002.to_s.length == 0)
f267003 = c['f267003'].to_s.tr('-,','')
allnil.push(f267003)
f267003 = '0' if (f267003.to_s.length == 0)
f267004 = c['f267004'].to_s.tr('-,','')
allnil.push(f267004)
f267004 = '0' if (f267004.to_s.length == 0)
f268001 = c['f268001'].to_s.tr('-,','')
allnil.push(f268001)
f268001 = '0' if (f268001.to_s.length == 0)
f268002 = c['f268002'].to_s.tr('-,','')
allnil.push(f268002)
f268002 = '0' if (f268002.to_s.length == 0)
f268003 = c['f268003'].to_s.tr('-,','')
allnil.push(f268003)
f268003 = '0' if (f268003.to_s.length == 0)
f268004 = c['f268004'].to_s.tr('-,','')
allnil.push(f268004)
f268004 = '0' if (f268004.to_s.length == 0)
f269001 = c['f269001'].to_s.tr('-,','')
allnil.push(f269001)
f269001 = '0' if (f269001.to_s.length == 0)
f269002 = c['f269002'].to_s.tr('-,','')
allnil.push(f269002)
f269002 = '0' if (f269002.to_s.length == 0)
f269003 = c['f269003'].to_s.tr('-,','')
allnil.push(f269003)
f269003 = '0' if (f269003.to_s.length == 0)
f269004 = c['f269004'].to_s.tr('-,','')
allnil.push(f269004)
f269004 = '0' if (f269004.to_s.length == 0)
f270001 = c['f270001'].to_s.tr('-,','')
allnil.push(f270001)
f270001 = '0' if (f270001.to_s.length == 0)
f270002 = c['f270002'].to_s.tr('-,','')
allnil.push(f270002)
f270002 = '0' if (f270002.to_s.length == 0)
f270003 = c['f270003'].to_s.tr('-,','')
allnil.push(f270003)
f270003 = '0' if (f270003.to_s.length == 0)
f270004 = c['f270004'].to_s.tr('-,','')
allnil.push(f270004)
f270004 = '0' if (f270004.to_s.length == 0)
f271001 = c['f271001'].to_s.tr('-,','')
allnil.push(f271001)
f271001 = '0' if (f271001.to_s.length == 0)
f271002 = c['f271002'].to_s.tr('-,','')
allnil.push(f271002)
f271002 = '0' if (f271002.to_s.length == 0)
f271003 = c['f271003'].to_s.tr('-,','')
allnil.push(f271003)
f271003 = '0' if (f271003.to_s.length == 0)
f271004 = c['f271004'].to_s.tr('-,','')
allnil.push(f271004)
f271004 = '0' if (f271004.to_s.length == 0)
f272001 = c['f272001'].to_s.tr('-,','')
allnil.push(f272001)
f272001 = '0' if (f272001.to_s.length == 0)
f272002 = c['f272002'].to_s.tr('-,','')
allnil.push(f272002)
f272002 = '0' if (f272002.to_s.length == 0)
f272003 = c['f272003'].to_s.tr('-,','')
allnil.push(f272003)
f272003 = '0' if (f272003.to_s.length == 0)
f272004 = c['f272004'].to_s.tr('-,','')
allnil.push(f272004)
f272004 = '0' if (f272004.to_s.length == 0)
f273001 = c['f273001'].to_s.tr('-,','')
allnil.push(f273001)
f273001 = '0' if (f273001.to_s.length == 0)
f273002 = c['f273002'].to_s.tr('-,','')
allnil.push(f273002)
f273002 = '0' if (f273002.to_s.length == 0)
f273003 = c['f273003'].to_s.tr('-,','')
allnil.push(f273003)
f273003 = '0' if (f273003.to_s.length == 0)
f273004 = c['f273004'].to_s.tr('-,','')
allnil.push(f273004)
f273004 = '0' if (f273004.to_s.length == 0)
f274001 = c['f274001'].to_s.tr('-,','')
allnil.push(f274001)
f274001 = '0' if (f274001.to_s.length == 0)
f274002 = c['f274002'].to_s.tr('-,','')
allnil.push(f274002)
f274002 = '0' if (f274002.to_s.length == 0)
f274003 = c['f274003'].to_s.tr('-,','')
allnil.push(f274003)
f274003 = '0' if (f274003.to_s.length == 0)
f274004 = c['f274004'].to_s.tr('-,','')
allnil.push(f274004)
f274004 = '0' if (f274004.to_s.length == 0)
f275001 = c['f275001'].to_s.tr('-,','')
allnil.push(f275001)
f275001 = '0' if (f275001.to_s.length == 0)
f275002 = c['f275002'].to_s.tr('-,','')
allnil.push(f275002)
f275002 = '0' if (f275002.to_s.length == 0)
f275003 = c['f275003'].to_s.tr('-,','')
allnil.push(f275003)
f275003 = '0' if (f275003.to_s.length == 0)
f275004 = c['f275004'].to_s.tr('-,','')
allnil.push(f275004)
f275004 = '0' if (f275004.to_s.length == 0)
f276001 = c['f276001'].to_s.tr('-,','')
allnil.push(f276001)
f276001 = '0' if (f276001.to_s.length == 0)
f276002 = c['f276002'].to_s.tr('-,','')
allnil.push(f276002)
f276002 = '0' if (f276002.to_s.length == 0)
f276003 = c['f276003'].to_s.tr('-,','')
allnil.push(f276003)
f276003 = '0' if (f276003.to_s.length == 0)
f276004 = c['f276004'].to_s.tr('-,','')
allnil.push(f276004)
f276004 = '0' if (f276004.to_s.length == 0)
f277001 = c['f277001'].to_s.tr('-,','')
allnil.push(f277001)
f277001 = '0' if (f277001.to_s.length == 0)
f277002 = c['f277002'].to_s.tr('-,','')
allnil.push(f277002)
f277002 = '0' if (f277002.to_s.length == 0)
f277003 = c['f277003'].to_s.tr('-,','')
allnil.push(f277003)
f277003 = '0' if (f277003.to_s.length == 0)
f277004 = c['f277004'].to_s.tr('-,','')
allnil.push(f277004)
f277004 = '0' if (f277004.to_s.length == 0)
f278001 = c['f278001'].to_s.tr('-,','')
allnil.push(f278001)
f278001 = '0' if (f278001.to_s.length == 0)
f278002 = c['f278002'].to_s.tr('-,','')
allnil.push(f278002)
f278002 = '0' if (f278002.to_s.length == 0)
f278003 = c['f278003'].to_s.tr('-,','')
allnil.push(f278003)
f278003 = '0' if (f278003.to_s.length == 0)
f278004 = c['f278004'].to_s.tr('-,','')
allnil.push(f278004)
f278004 = '0' if (f278004.to_s.length == 0)
f279001 = c['f279001'].to_s.tr('-,','')
allnil.push(f279001)
f279001 = '0' if (f279001.to_s.length == 0)
f279002 = c['f279002'].to_s.tr('-,','')
allnil.push(f279002)
f279002 = '0' if (f279002.to_s.length == 0)
f279003 = c['f279003'].to_s.tr('-,','')
allnil.push(f279003)
f279003 = '0' if (f279003.to_s.length == 0)
f279004 = c['f279004'].to_s.tr('-,','')
allnil.push(f279004)
f279004 = '0' if (f279004.to_s.length == 0)

if (allnil.to_s.length == 0)
  errMsg("กรุณาบันทึก 0 ในช่องใดช่องหนึ่ง ก่อนกดปุ่ม [บันทึกข้อมูล]")
  exit
end

chk = checkDup("form2", "f2year", "f2hcode", f2year, f2hcode)

  chkDigit('f201001',f201001)
  chkDigit('f201002',f201002)
  chkDigit('f201003',f201003)
  chkDigit('f201004',f201004)
  chkDigit('f202001',f202001)
  chkDigit('f202002',f202002)
  chkDigit('f202003',f202003)
  chkDigit('f202004',f202004)
  chkDigit('f203001',f203001)
  chkDigit('f203002',f203002)
  chkDigit('f203003',f203003)
  chkDigit('f203004',f203004)
  chkDigit('f204001',f204001)
  chkDigit('f204002',f204002)
  chkDigit('f204003',f204003)
  chkDigit('f204004',f204004)
  chkDigit('f205001',f205001)
  chkDigit('f205002',f205002)
  chkDigit('f205003',f205003)
  chkDigit('f205004',f205004)
  chkDigit('f206001',f206001)
  chkDigit('f206002',f206002)
  chkDigit('f206003',f206003)
  chkDigit('f206004',f206004)
  chkDigit('f207001',f207001)
  chkDigit('f207002',f207002)
  chkDigit('f207003',f207003)
  chkDigit('f207004',f207004)
  chkDigit('f208001',f208001)
  chkDigit('f208002',f208002)
  chkDigit('f208003',f208003)
  chkDigit('f208004',f208004)
  chkDigit('f209001',f209001)
  chkDigit('f209002',f209002)
  chkDigit('f209003',f209003)
  chkDigit('f209004',f209004)
  chkDigit('f210001',f210001)
  chkDigit('f210002',f210002)
  chkDigit('f210003',f210003)
  chkDigit('f210004',f210004)
  chkDigit('f211001',f211001)
  chkDigit('f211002',f211002)
  chkDigit('f211003',f211003)
  chkDigit('f211004',f211004)
  chkDigit('f212001',f212001)
  chkDigit('f212002',f212002)
  chkDigit('f212003',f212003)
  chkDigit('f212004',f212004)
  chkDigit('f213001',f213001)
  chkDigit('f213002',f213002)
  chkDigit('f213003',f213003)
  chkDigit('f213004',f213004)
  chkDigit('f214001',f214001)
  chkDigit('f214002',f214002)
  chkDigit('f214003',f214003)
  chkDigit('f214004',f214004)
  chkDigit('f215001',f215001)
  chkDigit('f215002',f215002)
  chkDigit('f215003',f215003)
  chkDigit('f215004',f215004)
  chkDigit('f216001',f216001)
  chkDigit('f216002',f216002)
  chkDigit('f216003',f216003)
  chkDigit('f216004',f216004)
  chkDigit('f217001',f217001)
  chkDigit('f217002',f217002)
  chkDigit('f217003',f217003)
  chkDigit('f217004',f217004)
  chkDigit('f218001',f218001)
  chkDigit('f218002',f218002)
  chkDigit('f218003',f218003)
  chkDigit('f218004',f218004)
  chkDigit('f219001',f219001)
  chkDigit('f219002',f219002)
  chkDigit('f219003',f219003)
  chkDigit('f219004',f219004)
  chkDigit('f220001',f220001)
  chkDigit('f220002',f220002)
  chkDigit('f220003',f220003)
  chkDigit('f220004',f220004)
  chkDigit('f221001',f221001)
  chkDigit('f221002',f221002)
  chkDigit('f221003',f221003)
  chkDigit('f221004',f221004)
  chkDigit('f222001',f222001)
  chkDigit('f222002',f222002)
  chkDigit('f222003',f222003)
  chkDigit('f222004',f222004)
  chkDigit('f223001',f223001)
  chkDigit('f223002',f223002)
  chkDigit('f223003',f223003)
  chkDigit('f223004',f223004)
  chkDigit('f224001',f224001)
  chkDigit('f224002',f224002)
  chkDigit('f224003',f224003)
  chkDigit('f224004',f224004)
  chkDigit('f225001',f225001)
  chkDigit('f225002',f225002)
  chkDigit('f225003',f225003)
  chkDigit('f225004',f225004)
  chkDigit('f226001',f226001)
  chkDigit('f226002',f226002)
  chkDigit('f226003',f226003)
  chkDigit('f226004',f226004)
  chkDigit('f227001',f227001)
  chkDigit('f227002',f227002)
  chkDigit('f227003',f227003)
  chkDigit('f227004',f227004)
  chkDigit('f228001',f228001)
  chkDigit('f228002',f228002)
  chkDigit('f228003',f228003)
  chkDigit('f228004',f228004)
  chkDigit('f229001',f229001)
  chkDigit('f229002',f229002)
  chkDigit('f229003',f229003)
  chkDigit('f229004',f229004)
  chkDigit('f230001',f230001)
  chkDigit('f230002',f230002)
  chkDigit('f230003',f230003)
  chkDigit('f230004',f230004)
  chkDigit('f231001',f231001)
  chkDigit('f231002',f231002)
  chkDigit('f231003',f231003)
  chkDigit('f231004',f231004)
  chkDigit('f232001',f232001)
  chkDigit('f232002',f232002)
  chkDigit('f232003',f232003)
  chkDigit('f232004',f232004)
  chkDigit('f233001',f233001)
  chkDigit('f233002',f233002)
  chkDigit('f233003',f233003)
  chkDigit('f233004',f233004)
  chkDigit('f234001',f234001)
  chkDigit('f234002',f234002)
  chkDigit('f234003',f234003)
  chkDigit('f234004',f234004)
  chkDigit('f235001',f235001)
  chkDigit('f235002',f235002)
  chkDigit('f235003',f235003)
  chkDigit('f235004',f235004)
  chkDigit('f236001',f236001)
  chkDigit('f236002',f236002)
  chkDigit('f236003',f236003)
  chkDigit('f236004',f236004)
  chkDigit('f237001',f237001)
  chkDigit('f237002',f237002)
  chkDigit('f237003',f237003)
  chkDigit('f237004',f237004)
  chkDigit('f238001',f238001)
  chkDigit('f238002',f238002)
  chkDigit('f238003',f238003)
  chkDigit('f238004',f238004)
  chkDigit('f239001',f239001)
  chkDigit('f239002',f239002)
  chkDigit('f239003',f239003)
  chkDigit('f239004',f239004)
  chkDigit('f240001',f240001)
  chkDigit('f240002',f240002)
  chkDigit('f240003',f240003)
  chkDigit('f240004',f240004)
  chkDigit('f241001',f241001)
  chkDigit('f241002',f241002)
  chkDigit('f241003',f241003)
  chkDigit('f241004',f241004)
  chkDigit('f242001',f242001)
  chkDigit('f242002',f242002)
  chkDigit('f242003',f242003)
  chkDigit('f242004',f242004)
  chkDigit('f243001',f243001)
  chkDigit('f243002',f243002)
  chkDigit('f243003',f243003)
  chkDigit('f243004',f243004)
  chkDigit('f244001',f244001)
  chkDigit('f244002',f244002)
  chkDigit('f244003',f244003)
  chkDigit('f244004',f244004)
  chkDigit('f245001',f245001)
  chkDigit('f245002',f245002)
  chkDigit('f245003',f245003)
  chkDigit('f245004',f245004)
  chkDigit('f246001',f246001)
  chkDigit('f246002',f246002)
  chkDigit('f246003',f246003)
  chkDigit('f246004',f246004)
  chkDigit('f247001',f247001)
  chkDigit('f247002',f247002)
  chkDigit('f247003',f247003)
  chkDigit('f247004',f247004)
  chkDigit('f248001',f248001)
  chkDigit('f248002',f248002)
  chkDigit('f248003',f248003)
  chkDigit('f248004',f248004)
  chkDigit('f249001',f249001)
  chkDigit('f249002',f249002)
  chkDigit('f249003',f249003)
  chkDigit('f249004',f249004)
  chkDigit('f250001',f250001)
  chkDigit('f250002',f250002)
  chkDigit('f250003',f250003)
  chkDigit('f250004',f250004)
  chkDigit('f251001',f251001)
  chkDigit('f251002',f251002)
  chkDigit('f251003',f251003)
  chkDigit('f251004',f251004)
  chkDigit('f252001',f252001)
  chkDigit('f252002',f252002)
  chkDigit('f252003',f252003)
  chkDigit('f252004',f252004)
  chkDigit('f253001',f253001)
  chkDigit('f253002',f253002)
  chkDigit('f253003',f253003)
  chkDigit('f253004',f253004)
  chkDigit('f254001',f254001)
  chkDigit('f254002',f254002)
  chkDigit('f254003',f254003)
  chkDigit('f254004',f254004)
  chkDigit('f255001',f255001)
  chkDigit('f255002',f255002)
  chkDigit('f255003',f255003)
  chkDigit('f255004',f255004)
  chkDigit('f256001',f256001)
  chkDigit('f256002',f256002)
  chkDigit('f256003',f256003)
  chkDigit('f256004',f256004)
  chkDigit('f257001',f257001)
  chkDigit('f257002',f257002)
  chkDigit('f257003',f257003)
  chkDigit('f257004',f257004)
  chkDigit('f258001',f258001)
  chkDigit('f258002',f258002)
  chkDigit('f258003',f258003)
  chkDigit('f258004',f258004)
  chkDigit('f259001',f259001)
  chkDigit('f259002',f259002)
  chkDigit('f259003',f259003)
  chkDigit('f259004',f259004)
  chkDigit('f260001',f260001)
  chkDigit('f260002',f260002)
  chkDigit('f260003',f260003)
  chkDigit('f260004',f260004)
  chkDigit('f261001',f261001)
  chkDigit('f261002',f261002)
  chkDigit('f261003',f261003)
  chkDigit('f261004',f261004)
  chkDigit('f262001',f262001)
  chkDigit('f262002',f262002)
  chkDigit('f262003',f262003)
  chkDigit('f262004',f262004)
  chkDigit('f263001',f263001)
  chkDigit('f263002',f263002)
  chkDigit('f263003',f263003)
  chkDigit('f263004',f263004)
  chkDigit('f264001',f264001)
  chkDigit('f264002',f264002)
  chkDigit('f264003',f264003)
  chkDigit('f264004',f264004)
  chkDigit('f265001',f265001)
  chkDigit('f265002',f265002)
  chkDigit('f265003',f265003)
  chkDigit('f265004',f265004)
  chkDigit('f266001',f266001)
  chkDigit('f266002',f266002)
  chkDigit('f266003',f266003)
  chkDigit('f266004',f266004)
  chkDigit('f267001',f267001)
  chkDigit('f267002',f267002)
  chkDigit('f267003',f267003)
  chkDigit('f267004',f267004)
  chkDigit('f268001',f268001)
  chkDigit('f268002',f268002)
  chkDigit('f268003',f268003)
  chkDigit('f268004',f268004)
  chkDigit('f269001',f269001)
  chkDigit('f269002',f269002)
  chkDigit('f269003',f269003)
  chkDigit('f269004',f269004)
  chkDigit('f270001',f270001)
  chkDigit('f270002',f270002)
  chkDigit('f270003',f270003)
  chkDigit('f270004',f270004)
  chkDigit('f271001',f271001)
  chkDigit('f271002',f271002)
  chkDigit('f271003',f271003)
  chkDigit('f271004',f271004)
  chkDigit('f272001',f272001)
  chkDigit('f272002',f272002)
  chkDigit('f272003',f272003)
  chkDigit('f272004',f272004)
  chkDigit('f273001',f273001)
  chkDigit('f273002',f273002)
  chkDigit('f273003',f273003)
  chkDigit('f273004',f273004)
  chkDigit('f274001',f274001)
  chkDigit('f274002',f274002)
  chkDigit('f274003',f274003)
  chkDigit('f274004',f274004)
  chkDigit('f275001',f275001)
  chkDigit('f275002',f275002)
  chkDigit('f275003',f275003)
  chkDigit('f275004',f275004)
  chkDigit('f276001',f276001)
  chkDigit('f276002',f276002)
  chkDigit('f276003',f276003)
  chkDigit('f276004',f276004)
  chkDigit('f277001',f277001)
  chkDigit('f277002',f277002)
  chkDigit('f277003',f277003)
  chkDigit('f277004',f277004)
  chkDigit('f278001',f278001)
  chkDigit('f278002',f278002)
  chkDigit('f278003',f278003)
  chkDigit('f278004',f278004)
  chkDigit('f279001',f279001)
  chkDigit('f279002',f279002)
  chkDigit('f279003',f279003)
  chkDigit('f279004',f279004)

md1 = chkMD001Form1(f2hcode)
md2 = chkMD002Form1(f2hcode)
md3 = chkMD003Form1(f2hcode)
md4 = chkMD004Form1(f2hcode)

md1tot = f201001.to_i+f202001.to_i+f203001.to_i+f204001.to_i+f205001.to_i+f206001.to_i+f207001.to_i+f208001.to_i+f209001.to_i+f210001.to_i+f211001.to_i+f212001.to_i+f213001.to_i+f214001.to_i+f215001.to_i+f216001.to_i+f217001.to_i+f218001.to_i+f219001.to_i+f220001.to_i+f221001.to_i+f222001.to_i+f223001.to_i+f224001.to_i+f225001.to_i+f226001.to_i+f227001.to_i+f228001.to_i+f229001.to_i+f230001.to_i+f231001.to_i+f232001.to_i+f233001.to_i+f234001.to_i+f235001.to_i+f236001.to_i+f237001.to_i+f238001.to_i+f239001.to_i+f240001.to_i+f241001.to_i+f242001.to_i+f243001.to_i+f244001.to_i+f245001.to_i+f246001.to_i+f247001.to_i+f248001.to_i+f249001.to_i+f250001.to_i+f251001.to_i+f252001.to_i+f253001.to_i+f254001.to_i+f255001.to_i+f256001.to_i+f257001.to_i+f258001.to_i+f259001.to_i+f260001.to_i+f261001.to_i+f262001.to_i+f263001.to_i+f264001.to_i+f265001.to_i+f266001.to_i+f267001.to_i+f268001.to_i+f269001.to_i+f270001.to_i+f271001.to_i+f272001.to_i+f273001.to_i+f274001.to_i+f275001.to_i+f276001.to_i+f277001.to_i+f278001.to_i+f279001.to_i
md2tot = f201002.to_i+f202002.to_i+f203002.to_i+f204002.to_i+f205002.to_i+f206002.to_i+f207002.to_i+f208002.to_i+f209002.to_i+f210002.to_i+f211002.to_i+f212002.to_i+f213002.to_i+f214002.to_i+f215002.to_i+f216002.to_i+f217002.to_i+f218002.to_i+f219002.to_i+f220002.to_i+f221002.to_i+f222002.to_i+f223002.to_i+f224002.to_i+f225002.to_i+f226002.to_i+f227002.to_i+f228002.to_i+f229002.to_i+f230002.to_i+f231002.to_i+f232002.to_i+f233002.to_i+f234002.to_i+f235002.to_i+f236002.to_i+f237002.to_i+f238002.to_i+f239002.to_i+f240002.to_i+f241002.to_i+f242002.to_i+f243002.to_i+f244002.to_i+f245002.to_i+f246002.to_i+f247002.to_i+f248002.to_i+f249002.to_i+f250002.to_i+f251002.to_i+f252002.to_i+f253002.to_i+f254002.to_i+f255002.to_i+f256002.to_i+f257002.to_i+f258002.to_i+f259002.to_i+f260002.to_i+f261002.to_i+f262002.to_i+f263002.to_i+f264002.to_i+f265002.to_i+f266002.to_i+f267002.to_i+f268002.to_i+f269002.to_i+f270002.to_i+f271002.to_i+f272002.to_i+f273002.to_i+f274002.to_i+f275002.to_i+f276002.to_i+f277002.to_i+f278002.to_i+f279002.to_i
md3tot = f201003.to_i+f202003.to_i+f203003.to_i+f204003.to_i+f205003.to_i+f206003.to_i+f207003.to_i+f208003.to_i+f209003.to_i+f210003.to_i+f211003.to_i+f212003.to_i+f213003.to_i+f214003.to_i+f215003.to_i+f216003.to_i+f217003.to_i+f218003.to_i+f219003.to_i+f220003.to_i+f221003.to_i+f222003.to_i+f223003.to_i+f224003.to_i+f225003.to_i+f226003.to_i+f227003.to_i+f228003.to_i+f229003.to_i+f230003.to_i+f231003.to_i+f232003.to_i+f233003.to_i+f234003.to_i+f235003.to_i+f236003.to_i+f237003.to_i+f238003.to_i+f239003.to_i+f240003.to_i+f241003.to_i+f242003.to_i+f243003.to_i+f244003.to_i+f245003.to_i+f246003.to_i+f247003.to_i+f248003.to_i+f249003.to_i+f250003.to_i+f251003.to_i+f252003.to_i+f253003.to_i+f254003.to_i+f255003.to_i+f256003.to_i+f257003.to_i+f258003.to_i+f259003.to_i+f260003.to_i+f261003.to_i+f262003.to_i+f263003.to_i+f264003.to_i+f265003.to_i+f266003.to_i+f267003.to_i+f268003.to_i+f269003.to_i+f270003.to_i+f271003.to_i+f272003.to_i+f273003.to_i+f274003.to_i+f275003.to_i+f276003.to_i+f277003.to_i+f278003.to_i+f279003.to_i
md4tot = f201004.to_i+f202004.to_i+f203004.to_i+f204004.to_i+f205004.to_i+f206004.to_i+f207004.to_i+f208004.to_i+f209004.to_i+f210004.to_i+f211004.to_i+f212004.to_i+f213004.to_i+f214004.to_i+f215004.to_i+f216004.to_i+f217004.to_i+f218004.to_i+f219004.to_i+f220004.to_i+f221004.to_i+f222004.to_i+f223004.to_i+f224004.to_i+f225004.to_i+f226004.to_i+f227004.to_i+f228004.to_i+f229004.to_i+f230004.to_i+f231004.to_i+f232004.to_i+f233004.to_i+f234004.to_i+f235004.to_i+f236004.to_i+f237004.to_i+f238004.to_i+f239004.to_i+f240004.to_i+f241004.to_i+f242004.to_i+f243004.to_i+f244004.to_i+f245004.to_i+f246004.to_i+f247004.to_i+f248004.to_i+f249004.to_i+f250004.to_i+f251004.to_i+f252004.to_i+f253004.to_i+f254004.to_i+f255004.to_i+f256004.to_i+f257004.to_i+f258004.to_i+f259004.to_i+f260004.to_i+f261004.to_i+f262004.to_i+f263004.to_i+f264004.to_i+f265004.to_i+f266004.to_i+f267004.to_i+f268004.to_i+f269004.to_i+f270004.to_i+f271004.to_i+f272004.to_i+f273004.to_i+f274004.to_i+f275004.to_i+f276004.to_i+f277004.to_i+f278004.to_i+f279004.to_i

f2allow = checkForm2Allow(f2hcode)
statusMsg = nil
otype = getOtype(f2hcode)

if (f2allow && otype != 'M')
  if (md1tot > 0 && md1 == 0)
    statusMsg = "#{statusMsg}Form1 จำนวนข้าราชการแพทย์ชายเป็น 0 แต่ Form2 รวมแพทย์เฉพาะทางได้ #{md1tot}<br>"
  end
  if (md2tot > 0 && md2 == 0)
    statusMsg = "#{statusMsg}Form1 จำนวนข้าราชการแพทย์หญิงเป็น 0 แต่ Form2 รวมแพทย์เฉพาะทางได้ #{md2tot}<br>"
  end
  if (md3tot > 0 && md3 == 0)
    statusMsg = "#{statusMsg}Form1 จำนวนลูกจ้างแพทย์ชายเป็น 0 แต่ Form2 รวมแพทย์เฉพาะทางได้ #{md3tot}<br>"
  end
  if (md4tot > 0 && md4 == 0)
    statusMsg = "#{statusMsg}Form1 จำนวนลูกจ้างแพทย์หญิงเป็น 0 แต่ Form2 รวมแพทย์เฉพาะทางได้ #{md4tot}<br>"
  end

  if (statusMsg.to_s.length > 0)
    statusMsg = "<h4>พบข้อผิดพลาด:</h4>#{statusMsg}"
    errMsg(statusMsg)
  end
end

con = PGconn.connect("localhost",5432,nil,nil,"resource53")

if chk.to_s == 'NODUP'

# Check otype if 'M' --> UPDATE reportmon --> form1 = 'X' (no need form1)
if (otype == 'M')
  sql = "UPDATE reportmon SET form1='X' "
  sql += "WHERE hcode='#{f2hcode}' "
  res = con.exec(sql)
end

sql = "INSERT INTO form2(f2year,f2pname,f2pcode,f2hname,f2hcode,"
sql = sql << "f201001,f201002,f201003,f201004,"
sql = sql << "f202001,f202002,f202003,f202004,"
sql = sql << "f203001,f203002,f203003,f203004,"
sql = sql << "f204001,f204002,f204003,f204004,"
sql = sql << "f205001,f205002,f205003,f205004,"
sql = sql << "f206001,f206002,f206003,f206004,"
sql = sql << "f207001,f207002,f207003,f207004,"
sql = sql << "f208001,f208002,f208003,f208004,"
sql = sql << "f209001,f209002,f209003,f209004,"
sql = sql << "f210001,f210002,f210003,f210004,"
sql = sql << "f211001,f211002,f211003,f211004,"
sql = sql << "f212001,f212002,f212003,f212004,"
sql = sql << "f213001,f213002,f213003,f213004,"
sql = sql << "f214001,f214002,f214003,f214004,"
sql = sql << "f215001,f215002,f215003,f215004,"
sql = sql << "f216001,f216002,f216003,f216004,"
sql = sql << "f217001,f217002,f217003,f217004,"
sql = sql << "f218001,f218002,f218003,f218004,"
sql = sql << "f219001,f219002,f219003,f219004,"
sql = sql << "f220001,f220002,f220003,f220004,"
sql = sql << "f221001,f221002,f221003,f221004,"
sql = sql << "f222001,f222002,f222003,f222004,"
sql = sql << "f223001,f223002,f223003,f223004,"
sql = sql << "f224001,f224002,f224003,f224004,"
sql = sql << "f225001,f225002,f225003,f225004,"
sql = sql << "f226001,f226002,f226003,f226004,"
sql = sql << "f227001,f227002,f227003,f227004,"
sql = sql << "f228001,f228002,f228003,f228004,"
sql = sql << "f229001,f229002,f229003,f229004,"
sql = sql << "f230001,f230002,f230003,f230004,"
sql = sql << "f231001,f231002,f231003,f231004,"
sql = sql << "f232001,f232002,f232003,f232004,"
sql = sql << "f233001,f233002,f233003,f233004,"
sql = sql << "f234001,f234002,f234003,f234004,"
sql = sql << "f235001,f235002,f235003,f235004,"
sql = sql << "f236001,f236002,f236003,f236004,"
sql = sql << "f237001,f237002,f237003,f237004,"
sql = sql << "f238001,f238002,f238003,f238004,"
sql = sql << "f239001,f239002,f239003,f239004,"
sql = sql << "f240001,f240002,f240003,f240004,"
sql = sql << "f241001,f241002,f241003,f241004,"
sql = sql << "f242001,f242002,f242003,f242004,"
sql = sql << "f243001,f243002,f243003,f243004,"
sql = sql << "f244001,f244002,f244003,f244004,"
sql = sql << "f245001,f245002,f245003,f245004,"
sql = sql << "f246001,f246002,f246003,f246004,"
sql = sql << "f247001,f247002,f247003,f247004,"
sql = sql << "f248001,f248002,f248003,f248004,"
sql = sql << "f249001,f249002,f249003,f249004,"
sql = sql << "f250001,f250002,f250003,f250004,"
sql = sql << "f251001,f251002,f251003,f251004,"
sql = sql << "f252001,f252002,f252003,f252004,"
sql = sql << "f253001,f253002,f253003,f253004,"
sql = sql << "f254001,f254002,f254003,f254004,"
sql = sql << "f255001,f255002,f255003,f255004,"
sql = sql << "f256001,f256002,f256003,f256004,"
sql = sql << "f257001,f257002,f257003,f257004,"
sql = sql << "f258001,f258002,f258003,f258004,"
sql = sql << "f259001,f259002,f259003,f259004,"
sql = sql << "f260001,f260002,f260003,f260004,"
sql = sql << "f261001,f261002,f261003,f261004,"
sql = sql << "f262001,f262002,f262003,f262004,"
sql = sql << "f263001,f263002,f263003,f263004,"
sql = sql << "f264001,f264002,f264003,f264004,"
sql = sql << "f265001,f265002,f265003,f265004,"
sql = sql << "f266001,f266002,f266003,f266004,"
sql = sql << "f267001,f267002,f267003,f267004,"
sql = sql << "f268001,f268002,f268003,f268004,"
sql = sql << "f269001,f269002,f269003,f269004,"
sql = sql << "f270001,f270002,f270003,f270004,"
sql = sql << "f271001,f271002,f271003,f271004,"
sql = sql << "f272001,f272002,f272003,f272004,"
sql = sql << "f273001,f273002,f273003,f273004,"
sql = sql << "f274001,f274002,f274003,f274004,"
sql = sql << "f275001,f275002,f275003,f275004,"
sql = sql << "f276001,f276002,f276003,f276004,"
sql = sql << "f277001,f277002,f277003,f277004,"
sql = sql << "f278001,f278002,f278003,f278004,"
sql = sql << "f279001,f279002,f279003,f279004) "
sql = sql << "VALUES ('#{f2year}','#{f2pname}','#{f2pcode}','#{f2hname}','#{f2hcode}',"
sql = sql << "'#{f201001}','#{f201002}','#{f201003}','#{f201004}',"
sql = sql << "'#{f202001}','#{f202002}','#{f202003}','#{f202004}',"
sql = sql << "'#{f203001}','#{f203002}','#{f203003}','#{f203004}',"
sql = sql << "'#{f204001}','#{f204002}','#{f204003}','#{f204004}',"
sql = sql << "'#{f205001}','#{f205002}','#{f205003}','#{f205004}',"
sql = sql << "'#{f206001}','#{f206002}','#{f206003}','#{f206004}',"
sql = sql << "'#{f207001}','#{f207002}','#{f207003}','#{f207004}',"
sql = sql << "'#{f208001}','#{f208002}','#{f208003}','#{f208004}',"
sql = sql << "'#{f209001}','#{f209002}','#{f209003}','#{f209004}',"
sql = sql << "'#{f210001}','#{f210002}','#{f210003}','#{f210004}',"
sql = sql << "'#{f211001}','#{f211002}','#{f211003}','#{f211004}',"
sql = sql << "'#{f212001}','#{f212002}','#{f212003}','#{f212004}',"
sql = sql << "'#{f213001}','#{f213002}','#{f213003}','#{f213004}',"
sql = sql << "'#{f214001}','#{f214002}','#{f214003}','#{f214004}',"
sql = sql << "'#{f215001}','#{f215002}','#{f215003}','#{f215004}',"
sql = sql << "'#{f216001}','#{f216002}','#{f216003}','#{f216004}',"
sql = sql << "'#{f217001}','#{f217002}','#{f217003}','#{f217004}',"
sql = sql << "'#{f218001}','#{f218002}','#{f218003}','#{f218004}',"
sql = sql << "'#{f219001}','#{f219002}','#{f219003}','#{f219004}',"
sql = sql << "'#{f220001}','#{f220002}','#{f220003}','#{f220004}',"
sql = sql << "'#{f221001}','#{f221002}','#{f221003}','#{f221004}',"
sql = sql << "'#{f222001}','#{f222002}','#{f222003}','#{f222004}',"
sql = sql << "'#{f223001}','#{f223002}','#{f223003}','#{f223004}',"
sql = sql << "'#{f224001}','#{f224002}','#{f224003}','#{f224004}',"
sql = sql << "'#{f225001}','#{f225002}','#{f225003}','#{f225004}',"
sql = sql << "'#{f226001}','#{f226002}','#{f226003}','#{f226004}',"
sql = sql << "'#{f227001}','#{f227002}','#{f227003}','#{f227004}',"
sql = sql << "'#{f228001}','#{f228002}','#{f228003}','#{f228004}',"
sql = sql << "'#{f229001}','#{f229002}','#{f229003}','#{f229004}',"
sql = sql << "'#{f230001}','#{f230002}','#{f230003}','#{f230004}',"
sql = sql << "'#{f231001}','#{f231002}','#{f231003}','#{f231004}',"
sql = sql << "'#{f232001}','#{f232002}','#{f232003}','#{f232004}',"
sql = sql << "'#{f233001}','#{f233002}','#{f233003}','#{f233004}',"
sql = sql << "'#{f234001}','#{f234002}','#{f234003}','#{f234004}',"
sql = sql << "'#{f235001}','#{f235002}','#{f235003}','#{f235004}',"
sql = sql << "'#{f236001}','#{f236002}','#{f236003}','#{f236004}',"
sql = sql << "'#{f237001}','#{f237002}','#{f237003}','#{f237004}',"
sql = sql << "'#{f238001}','#{f238002}','#{f238003}','#{f238004}',"
sql = sql << "'#{f239001}','#{f239002}','#{f239003}','#{f239004}',"
sql = sql << "'#{f240001}','#{f240002}','#{f240003}','#{f240004}',"
sql = sql << "'#{f241001}','#{f241002}','#{f241003}','#{f241004}',"
sql = sql << "'#{f242001}','#{f242002}','#{f242003}','#{f242004}',"
sql = sql << "'#{f243001}','#{f243002}','#{f243003}','#{f243004}',"
sql = sql << "'#{f244001}','#{f244002}','#{f244003}','#{f244004}',"
sql = sql << "'#{f245001}','#{f245002}','#{f245003}','#{f245004}',"
sql = sql << "'#{f246001}','#{f246002}','#{f246003}','#{f246004}',"
sql = sql << "'#{f247001}','#{f247002}','#{f247003}','#{f247004}',"
sql = sql << "'#{f248001}','#{f248002}','#{f248003}','#{f248004}',"
sql = sql << "'#{f249001}','#{f249002}','#{f249003}','#{f249004}',"
sql = sql << "'#{f250001}','#{f250002}','#{f250003}','#{f250004}',"
sql = sql << "'#{f251001}','#{f251002}','#{f251003}','#{f251004}',"
sql = sql << "'#{f252001}','#{f252002}','#{f252003}','#{f252004}',"
sql = sql << "'#{f253001}','#{f253002}','#{f253003}','#{f253004}',"
sql = sql << "'#{f254001}','#{f254002}','#{f254003}','#{f254004}',"
sql = sql << "'#{f255001}','#{f255002}','#{f255003}','#{f255004}',"
sql = sql << "'#{f256001}','#{f256002}','#{f256003}','#{f256004}',"
sql = sql << "'#{f257001}','#{f257002}','#{f257003}','#{f257004}',"
sql = sql << "'#{f258001}','#{f258002}','#{f258003}','#{f258004}',"
sql = sql << "'#{f259001}','#{f259002}','#{f259003}','#{f259004}',"
sql = sql << "'#{f260001}','#{f260002}','#{f260003}','#{f260004}',"
sql = sql << "'#{f261001}','#{f261002}','#{f261003}','#{f261004}',"
sql = sql << "'#{f262001}','#{f262002}','#{f262003}','#{f262004}',"
sql = sql << "'#{f263001}','#{f263002}','#{f263003}','#{f263004}',"
sql = sql << "'#{f264001}','#{f264002}','#{f264003}','#{f264004}',"
sql = sql << "'#{f265001}','#{f265002}','#{f265003}','#{f265004}',"
sql = sql << "'#{f266001}','#{f266002}','#{f266003}','#{f266004}',"
sql = sql << "'#{f267001}','#{f267002}','#{f267003}','#{f267004}',"
sql = sql << "'#{f268001}','#{f268002}','#{f268003}','#{f268004}',"
sql = sql << "'#{f269001}','#{f269002}','#{f269003}','#{f269004}',"
sql = sql << "'#{f270001}','#{f270002}','#{f270003}','#{f270004}',"
sql = sql << "'#{f271001}','#{f271002}','#{f271003}','#{f271004}',"
sql = sql << "'#{f272001}','#{f272002}','#{f272003}','#{f272004}',"
sql = sql << "'#{f273001}','#{f273002}','#{f273003}','#{f273004}',"
sql = sql << "'#{f274001}','#{f274002}','#{f274003}','#{f274004}',"
sql = sql << "'#{f275001}','#{f275002}','#{f275003}','#{f275004}',"
sql = sql << "'#{f276001}','#{f276002}','#{f276003}','#{f276004}',"
sql = sql << "'#{f277001}','#{f277002}','#{f277003}','#{f277004}',"
sql = sql << "'#{f278001}','#{f278002}','#{f278003}','#{f278004}',"
sql = sql << "'#{f279001}','#{f279002}','#{f279003}','#{f279004}' )"

res = con.exec(sql)

elsif chk == 'DUP'

sql = "UPDATE form2 SET "
sql = sql << "f201001='#{f201001}',f201002='#{f201002}',f201003='#{f201003}',f201004='#{f201004}',"
sql = sql << "f202001='#{f202001}',f202002='#{f202002}',f202003='#{f202003}',f202004='#{f202004}',"
sql = sql << "f203001='#{f203001}',f203002='#{f203002}',f203003='#{f203003}',f203004='#{f203004}',"
sql = sql << "f204001='#{f204001}',f204002='#{f204002}',f204003='#{f204003}',f204004='#{f204004}',"
sql = sql << "f205001='#{f205001}',f205002='#{f205002}',f205003='#{f205003}',f205004='#{f205004}',"
sql = sql << "f206001='#{f206001}',f206002='#{f206002}',f206003='#{f206003}',f206004='#{f206004}',"
sql = sql << "f207001='#{f207001}',f207002='#{f207002}',f207003='#{f207003}',f207004='#{f207004}',"
sql = sql << "f208001='#{f208001}',f208002='#{f208002}',f208003='#{f208003}',f208004='#{f208004}',"
sql = sql << "f209001='#{f209001}',f209002='#{f209002}',f209003='#{f209003}',f209004='#{f209004}',"
sql = sql << "f210001='#{f210001}',f210002='#{f210002}',f210003='#{f210003}',f210004='#{f210004}',"
sql = sql << "f211001='#{f211001}',f211002='#{f211002}',f211003='#{f211003}',f211004='#{f211004}',"
sql = sql << "f212001='#{f212001}',f212002='#{f212002}',f212003='#{f212003}',f212004='#{f212004}',"
sql = sql << "f213001='#{f213001}',f213002='#{f213002}',f213003='#{f213003}',f213004='#{f213004}',"
sql = sql << "f214001='#{f214001}',f214002='#{f214002}',f214003='#{f214003}',f214004='#{f214004}',"
sql = sql << "f215001='#{f215001}',f215002='#{f215002}',f215003='#{f215003}',f215004='#{f215004}',"
sql = sql << "f216001='#{f216001}',f216002='#{f216002}',f216003='#{f216003}',f216004='#{f216004}',"
sql = sql << "f217001='#{f217001}',f217002='#{f217002}',f217003='#{f217003}',f217004='#{f217004}',"
sql = sql << "f218001='#{f218001}',f218002='#{f218002}',f218003='#{f218003}',f218004='#{f218004}',"
sql = sql << "f219001='#{f219001}',f219002='#{f219002}',f219003='#{f219003}',f219004='#{f219004}',"
sql = sql << "f220001='#{f220001}',f220002='#{f220002}',f220003='#{f220003}',f220004='#{f220004}',"
sql = sql << "f221001='#{f221001}',f221002='#{f221002}',f221003='#{f221003}',f221004='#{f221004}',"
sql = sql << "f222001='#{f222001}',f222002='#{f222002}',f222003='#{f222003}',f222004='#{f222004}',"
sql = sql << "f223001='#{f223001}',f223002='#{f223002}',f223003='#{f223003}',f223004='#{f223004}',"
sql = sql << "f224001='#{f224001}',f224002='#{f224002}',f224003='#{f224003}',f224004='#{f224004}',"
sql = sql << "f225001='#{f225001}',f225002='#{f225002}',f225003='#{f225003}',f225004='#{f225004}',"
sql = sql << "f226001='#{f226001}',f226002='#{f226002}',f226003='#{f226003}',f226004='#{f226004}',"
sql = sql << "f227001='#{f227001}',f227002='#{f227002}',f227003='#{f227003}',f227004='#{f227004}',"
sql = sql << "f228001='#{f228001}',f228002='#{f228002}',f228003='#{f228003}',f228004='#{f228004}',"
sql = sql << "f229001='#{f229001}',f229002='#{f229002}',f229003='#{f229003}',f229004='#{f229004}',"
sql = sql << "f230001='#{f230001}',f230002='#{f230002}',f230003='#{f230003}',f230004='#{f230004}',"
sql = sql << "f231001='#{f231001}',f231002='#{f231002}',f231003='#{f231003}',f231004='#{f231004}',"
sql = sql << "f232001='#{f232001}',f232002='#{f232002}',f232003='#{f232003}',f232004='#{f232004}',"
sql = sql << "f233001='#{f233001}',f233002='#{f233002}',f233003='#{f233003}',f233004='#{f233004}',"
sql = sql << "f234001='#{f234001}',f234002='#{f234002}',f234003='#{f234003}',f234004='#{f234004}',"
sql = sql << "f235001='#{f235001}',f235002='#{f235002}',f235003='#{f235003}',f235004='#{f235004}',"
sql = sql << "f236001='#{f236001}',f236002='#{f236002}',f236003='#{f236003}',f236004='#{f236004}',"
sql = sql << "f237001='#{f237001}',f237002='#{f237002}',f237003='#{f237003}',f237004='#{f237004}',"
sql = sql << "f238001='#{f238001}',f238002='#{f238002}',f238003='#{f238003}',f238004='#{f238004}',"
sql = sql << "f239001='#{f239001}',f239002='#{f239002}',f239003='#{f239003}',f239004='#{f239004}',"
sql = sql << "f240001='#{f240001}',f240002='#{f240002}',f240003='#{f240003}',f240004='#{f240004}',"
sql = sql << "f241001='#{f241001}',f241002='#{f241002}',f241003='#{f241003}',f241004='#{f241004}',"
sql = sql << "f242001='#{f242001}',f242002='#{f242002}',f242003='#{f242003}',f242004='#{f242004}',"
sql = sql << "f243001='#{f243001}',f243002='#{f243002}',f243003='#{f243003}',f243004='#{f243004}',"
sql = sql << "f244001='#{f244001}',f244002='#{f244002}',f244003='#{f244003}',f244004='#{f244004}',"
sql = sql << "f245001='#{f245001}',f245002='#{f245002}',f245003='#{f245003}',f245004='#{f245004}',"
sql = sql << "f246001='#{f246001}',f246002='#{f246002}',f246003='#{f246003}',f246004='#{f246004}',"
sql = sql << "f247001='#{f247001}',f247002='#{f247002}',f247003='#{f247003}',f247004='#{f247004}',"
sql = sql << "f248001='#{f248001}',f248002='#{f248002}',f248003='#{f248003}',f248004='#{f248004}',"
sql = sql << "f249001='#{f249001}',f249002='#{f249002}',f249003='#{f249003}',f249004='#{f249004}',"
sql = sql << "f250001='#{f250001}',f250002='#{f250002}',f250003='#{f250003}',f250004='#{f250004}',"
sql = sql << "f251001='#{f251001}',f251002='#{f251002}',f251003='#{f251003}',f251004='#{f251004}',"
sql = sql << "f252001='#{f252001}',f252002='#{f252002}',f252003='#{f252003}',f252004='#{f252004}',"
sql = sql << "f253001='#{f253001}',f253002='#{f253002}',f253003='#{f253003}',f253004='#{f253004}',"
sql = sql << "f254001='#{f254001}',f254002='#{f254002}',f254003='#{f254003}',f254004='#{f254004}',"
sql = sql << "f255001='#{f255001}',f255002='#{f255002}',f255003='#{f255003}',f255004='#{f255004}',"
sql = sql << "f256001='#{f256001}',f256002='#{f256002}',f256003='#{f256003}',f256004='#{f256004}',"
sql = sql << "f257001='#{f257001}',f257002='#{f257002}',f257003='#{f257003}',f257004='#{f257004}',"
sql = sql << "f258001='#{f258001}',f258002='#{f258002}',f258003='#{f258003}',f258004='#{f258004}',"
sql = sql << "f259001='#{f259001}',f259002='#{f259002}',f259003='#{f259003}',f259004='#{f259004}',"
sql = sql << "f260001='#{f260001}',f260002='#{f260002}',f260003='#{f260003}',f260004='#{f260004}',"
sql = sql << "f261001='#{f261001}',f261002='#{f261002}',f261003='#{f261003}',f261004='#{f261004}',"
sql = sql << "f262001='#{f262001}',f262002='#{f262002}',f262003='#{f262003}',f262004='#{f262004}',"
sql = sql << "f263001='#{f263001}',f263002='#{f263002}',f263003='#{f263003}',f263004='#{f263004}',"
sql = sql << "f264001='#{f264001}',f264002='#{f264002}',f264003='#{f264003}',f264004='#{f264004}',"
sql = sql << "f265001='#{f265001}',f265002='#{f265002}',f265003='#{f265003}',f265004='#{f265004}',"
sql = sql << "f266001='#{f266001}',f266002='#{f266002}',f266003='#{f266003}',f266004='#{f266004}',"
sql = sql << "f267001='#{f267001}',f267002='#{f267002}',f267003='#{f267003}',f267004='#{f267004}',"
sql = sql << "f268001='#{f268001}',f268002='#{f268002}',f268003='#{f268003}',f268004='#{f268004}',"
sql = sql << "f269001='#{f269001}',f269002='#{f269002}',f269003='#{f269003}',f269004='#{f269004}',"
sql = sql << "f270001='#{f270001}',f270002='#{f270002}',f270003='#{f270003}',f270004='#{f270004}',"
sql = sql << "f271001='#{f271001}',f271002='#{f271002}',f271003='#{f271003}',f271004='#{f271004}',"
sql = sql << "f272001='#{f272001}',f272002='#{f272002}',f272003='#{f272003}',f272004='#{f272004}',"
sql = sql << "f273001='#{f273001}',f273002='#{f273002}',f273003='#{f273003}',f273004='#{f273004}',"
sql = sql << "f274001='#{f274001}',f274002='#{f274002}',f274003='#{f274003}',f274004='#{f274004}',"
sql = sql << "f275001='#{f275001}',f275002='#{f275002}',f275003='#{f275003}',f275004='#{f275004}',"
sql = sql << "f276001='#{f276001}',f276002='#{f276002}',f276003='#{f276003}',f276004='#{f276004}',"
sql = sql << "f277001='#{f277001}',f277002='#{f277002}',f277003='#{f277003}',f277004='#{f277004}',"
sql = sql << "f278001='#{f278001}',f278002='#{f278002}',f278003='#{f278003}',f278004='#{f278004}',"
sql = sql << "f279001='#{f279001}',f279002='#{f279002}',f279003='#{f279003}',f279004='#{f279004}' "
sql = sql << "WHERE f2year='#{f2year}' and f2hcode='#{f2hcode}' "
res = con.exec(sql)

end

con.close

updateReportMon(f2hcode,f2year,"form2")

# Routine check if all forms (f1-f4 or f5-f8) for hcode is complete?
checkComplete(f2hcode)

print <<EOF
Content-type: text/html
Pragma: no-cache

<html>
<body text='blue'>
<center>
<h2>บันทึกแบบฟอร์ม 2 สำหรับ #{ f2hname.to_s }(#{ f2hcode.to_s }) เรียบร้อยแล้ว</h2>
<h3>โปรดบันทึกแบบฟอร์มที่ 3 ต่อไป</h3>
<input type='button' value='Back' onClick='history.back();'>
</center>
</body>
</html>
EOF
