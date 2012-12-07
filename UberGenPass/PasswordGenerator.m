//
//  PasswordGenerator.m
//  UberGenPass
//
//  Created by Mark Smith on 10/23/12.
//  Copyright (c) 2012 Camazotz Limited. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "Keychain.h"
#import "NSData+Base64.h"
#import "PasswordGenerator.h"

static NSArray *TLDs;

@interface PasswordGenerator ()
@property (retain, readwrite, nonatomic) NSString *masterPassword;
@property (copy, readwrite, nonatomic) NSData *hash;
@property (retain, readwrite, nonatomic) NSRegularExpression *lowerCasePattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *upperCasePattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *digitPattern;
@property (retain, readwrite, nonatomic) NSRegularExpression *domainPattern;
@end

@implementation PasswordGenerator

#pragma mark Lifecycle

+ (void)initialize {
  if (self == PasswordGenerator.class) {
    TLDs = @[@"ac.ac", @"com.ac", @"edu.ac", @"gov.ac", @"net.ac", @"mil.ac", @"org.ac", @"com.ae", @"net.ae", @"org.ae", @"gov.ae", @"ac.ae", @"co.ae", @"sch.ae", @"pro.ae", @"com.ai", @"org.ai", @"edu.ai", @"gov.ai", @"com.ar", @"net.ar", @"org.ar", @"gov.ar", @"mil.ar", @"edu.ar", @"int.ar", @"co.at", @"ac.at", @"or.at", @"gv.at", @"priv.at", @"com.au", @"gov.au", @"org.au", @"edu.au", @"id.au", @"oz.au", @"info.au", @"net.au", @"asn.au", @"csiro.au", @"telememo.au", @"conf.au", @"otc.au", @"id.au", @"com.az", @"net.az", @"org.az", @"com.bb", @"net.bb", @"org.bb", @"ac.be", @"belgie.be", @"dns.be", @"fgov.be", @"com.bh", @"gov.bh", @"net.bh", @"edu.bh", @"org.bh", @"com.bm", @"edu.bm", @"gov.bm", @"org.bm", @"net.bm", @"adm.br", @"adv.br", @"agr.br", @"am.br", @"arq.br", @"art.br", @"ato.br", @"bio.br", @"bmd.br", @"cim.br", @"cng.br", @"cnt.br", @"com.br", @"coop.br", @"ecn.br", @"edu.br", @"eng.br", @"esp.br", @"etc.br", @"eti.br", @"far.br", @"fm.br", @"fnd.br", @"fot.br", @"fst.br", @"g12.br", @"ggf.br", @"gov.br", @"imb.br", @"ind.br", @"inf.br", @"jor.br", @"lel.br", @"mat.br", @"med.br", @"mil.br", @"mus.br", @"net.br", @"nom.br", @"not.br", @"ntr.br", @"odo.br", @"org.br", @"ppg.br", @"pro.br", @"psc.br", @"psi.br", @"qsl.br", @"rec.br", @"slg.br", @"srv.br", @"tmp.br", @"trd.br", @"tur.br", @"tv.br", @"vet.br", @"zlg.br", @"com.bs", @"net.bs", @"org.bs", @"ab.ca", @"bc.ca", @"mb.ca", @"nb.ca", @"nf.ca", @"nl.ca", @"ns.ca", @"nt.ca", @"nu.ca", @"on.ca", @"pe.ca", @"qc.ca", @"sk.ca", @"yk.ca", @"gc.ca", @"co.ck", @"net.ck", @"org.ck", @"edu.ck", @"gov.ck", @"com.cn", @"edu.cn", @"gov.cn", @"net.cn", @"org.cn", @"ac.cn", @"ah.cn", @"bj.cn", @"cq.cn", @"gd.cn", @"gs.cn", @"gx.cn", @"gz.cn", @"hb.cn", @"he.cn", @"hi.cn", @"hk.cn", @"hl.cn", @"hn.cn", @"jl.cn", @"js.cn", @"ln.cn", @"mo.cn", @"nm.cn", @"nx.cn", @"qh.cn", @"sc.cn", @"sn.cn", @"sh.cn", @"sx.cn", @"tj.cn", @"tw.cn", @"xj.cn", @"xz.cn", @"yn.cn", @"zj.cn", @"arts.co", @"com.co", @"edu.co", @"firm.co", @"gov.co", @"info.co", @"int.co", @"nom.co", @"mil.co", @"org.co", @"rec.co", @"store.co", @"web.co", @"ac.cr", @"co.cr", @"ed.cr", @"fi.cr", @"go.cr", @"or.cr", @"sa.cr", @"com.cu", @"net.cu", @"org.cu", @"ac.cy", @"com.cy", @"gov.cy", @"net.cy", @"org.cy", @"co.dk", @"art.do", @"com.do", @"edu.do", @"gov.do", @"gob.do", @"org.do", @"mil.do", @"net.do", @"sld.do", @"web.do", @"com.dz", @"org.dz", @"net.dz", @"gov.dz", @"edu.dz", @"ass.dz", @"pol.dz", @"art.dz", @"com.ec", @"k12.ec", @"edu.ec", @"fin.ec", @"med.ec", @"gov.ec", @"mil.ec", @"org.ec", @"net.ec", @"com.ee", @"pri.ee", @"fie.ee", @"org.ee", @"med.ee", @"com.eg", @"edu.eg", @"eun.eg", @"gov.eg", @"net.eg", @"org.eg", @"sci.eg", @"com.er", @"net.er", @"org.er", @"edu.er", @"mil.er", @"gov.er", @"ind.er", @"com.es", @"org.es", @"gob.es", @"edu.es", @"nom.es", @"com.et", @"gov.et", @"org.et", @"edu.et", @"net.et", @"biz.et", @"name.et", @"info.et", @"ac.fj", @"com.fj", @"gov.fj", @"id.fj", @"org.fj", @"school.fj", @"com.fk", @"ac.fk", @"gov.fk", @"net.fk", @"nom.fk", @"org.fk", @"asso.fr", @"nom.fr", @"barreau.fr", @"com.fr", @"prd.fr", @"presse.fr", @"tm.fr", @"aeroport.fr", @"assedic.fr", @"avocat.fr", @"avoues.fr", @"cci.fr", @"chambagri.fr", @"chirurgiens-dentistes.fr", @"experts-comptables.fr", @"geometre-expert.fr", @"gouv.fr", @"greta.fr", @"huissier-justice.fr", @"medecin.fr", @"notaires.fr", @"pharmacien.fr", @"port.fr", @"veterinaire.fr", @"com.ge", @"edu.ge", @"gov.ge", @"mil.ge", @"net.ge", @"org.ge", @"pvt.ge", @"co.gg", @"org.gg", @"sch.gg", @"ac.gg", @"gov.gg", @"ltd.gg", @"ind.gg", @"net.gg", @"alderney.gg", @"guernsey.gg", @"sark.gg", @"com.gr", @"edu.gr", @"gov.gr", @"net.gr", @"org.gr", @"com.gt", @"edu.gt", @"net.gt", @"gob.gt", @"org.gt", @"mil.gt", @"ind.gt", @"com.gu", @"edu.gu", @"net.gu", @"org.gu", @"gov.gu", @"mil.gu", @"com.hk", @"net.hk", @"org.hk", @"idv.hk", @"gov.hk", @"edu.hk", @"co.hu", @"2000.hu", @"erotika.hu", @"jogasz.hu", @"sex.hu", @"video.hu", @"info.hu", @"agrar.hu", @"film.hu", @"konyvelo.hu", @"shop.hu", @"org.hu", @"bolt.hu", @"forum.hu", @"lakas.hu", @"suli.hu", @"priv.hu", @"casino.hu", @"games.hu", @"media.hu", @"szex.hu", @"sport.hu", @"city.hu", @"hotel.hu", @"news.hu", @"tozsde.hu", @"tm.hu", @"erotica.hu", @"ingatlan.hu", @"reklam.hu", @"utazas.hu", @"ac.id", @"co.id", @"go.id", @"mil.id", @"net.id", @"or.id", @"co.il", @"net.il", @"org.il", @"ac.il", @"gov.il", @"k12.il", @"muni.il", @"idf.il", @"co.im", @"net.im", @"org.im", @"ac.im", @"lkd.co.im", @"gov.im", @"nic.im", @"plc.co.im", @"co.in", @"net.in", @"ac.in", @"ernet.in", @"gov.in", @"nic.in", @"res.in", @"gen.in", @"firm.in", @"mil.in", @"org.in", @"ind.in", @"ac.ir", @"co.ir", @"gov.ir", @"id.ir", @"net.ir", @"org.ir", @"sch.ir", @"ac.je", @"co.je", @"net.je", @"org.je", @"gov.je", @"ind.je", @"jersey.je", @"ltd.je", @"sch.je", @"com.jo", @"org.jo", @"net.jo", @"gov.jo", @"edu.jo", @"mil.jo", @"ad.jp", @"ac.jp", @"co.jp", @"go.jp", @"or.jp", @"ne.jp", @"gr.jp", @"ed.jp", @"lg.jp", @"net.jp", @"org.jp", @"gov.jp", @"hokkaido.jp", @"aomori.jp", @"iwate.jp", @"miyagi.jp", @"akita.jp", @"yamagata.jp", @"fukushima.jp", @"ibaraki.jp", @"tochigi.jp", @"gunma.jp", @"saitama.jp", @"chiba.jp", @"tokyo.jp", @"kanagawa.jp", @"niigata.jp", @"toyama.jp", @"ishikawa.jp", @"fukui.jp", @"yamanashi.jp", @"nagano.jp", @"gifu.jp", @"shizuoka.jp", @"aichi.jp", @"mie.jp", @"shiga.jp", @"kyoto.jp", @"osaka.jp", @"hyogo.jp", @"nara.jp", @"wakayama.jp", @"tottori.jp", @"shimane.jp", @"okayama.jp", @"hiroshima.jp", @"yamaguchi.jp", @"tokushima.jp", @"kagawa.jp", @"ehime.jp", @"kochi.jp", @"fukuoka.jp", @"saga.jp", @"nagasaki.jp", @"kumamoto.jp", @"oita.jp", @"miyazaki.jp", @"kagoshima.jp", @"okinawa.jp", @"sapporo.jp", @"sendai.jp", @"yokohama.jp", @"kawasaki.jp", @"nagoya.jp", @"kobe.jp", @"kitakyushu.jp", @"utsunomiya.jp", @"kanazawa.jp", @"takamatsu.jp", @"matsuyama.jp", @"com.kh", @"net.kh", @"org.kh", @"per.kh", @"edu.kh", @"gov.kh", @"mil.kh", @"ac.kr", @"co.kr", @"go.kr", @"ne.kr", @"or.kr", @"pe.kr", @"re.kr", @"seoul.kr", @"kyonggi.kr", @"com.kw", @"net.kw", @"org.kw", @"edu.kw", @"gov.kw", @"com.la", @"net.la", @"org.la", @"com.lb", @"org.lb", @"net.lb", @"edu.lb", @"gov.lb", @"mil.lb", @"com.lc", @"edu.lc", @"gov.lc", @"net.lc", @"org.lc", @"com.lv", @"net.lv", @"org.lv", @"edu.lv", @"gov.lv", @"mil.lv", @"id.lv", @"asn.lv", @"conf.lv", @"com.ly", @"net.ly", @"org.ly", @"co.ma", @"net.ma", @"org.ma", @"press.ma", @"ac.ma", @"com.mk", @"com.mm", @"net.mm", @"org.mm", @"edu.mm", @"gov.mm", @"com.mn", @"org.mn", @"edu.mn", @"gov.mn", @"museum.mn", @"com.mo", @"net.mo", @"org.mo", @"edu.mo", @"gov.mo", @"com.mt", @"net.mt", @"org.mt", @"edu.mt", @"tm.mt", @"uu.mt", @"com.mx", @"net.mx", @"org.mx", @"gob.mx", @"edu.mx", @"com.my", @"org.my", @"gov.my", @"edu.my", @"net.my", @"com.na", @"org.na", @"net.na", @"alt.na", @"edu.na", @"cul.na", @"unam.na", @"telecom.na", @"com.nc", @"net.nc", @"org.nc", @"ac.ng", @"edu.ng", @"sch.ng", @"com.ng", @"gov.ng", @"org.ng", @"net.ng", @"gob.ni", @"com.ni", @"net.ni", @"edu.ni", @"nom.ni", @"org.ni", @"com.np", @"net.np", @"org.np", @"gov.np", @"edu.np", @"ac.nz", @"co.nz", @"cri.nz", @"gen.nz", @"geek.nz", @"govt.nz", @"iwi.nz", @"maori.nz", @"mil.nz", @"net.nz", @"org.nz", @"school.nz", @"com.om", @"co.om", @"edu.om", @"ac.om", @"gov.om", @"net.om", @"org.om", @"mod.om", @"museum.om", @"biz.om", @"pro.om", @"med.om", @"com.pa", @"net.pa", @"org.pa", @"edu.pa", @"ac.pa", @"gob.pa", @"sld.pa", @"edu.pe", @"gob.pe", @"nom.pe", @"mil.pe", @"org.pe", @"com.pe", @"net.pe", @"com.pg", @"net.pg", @"ac.pg", @"com.ph", @"net.ph", @"org.ph", @"mil.ph", @"ngo.ph", @"aid.pl", @"agro.pl", @"atm.pl", @"auto.pl", @"biz.pl", @"com.pl", @"edu.pl", @"gmina.pl", @"gsm.pl", @"info.pl", @"mail.pl", @"miasta.pl", @"media.pl", @"mil.pl", @"net.pl", @"nieruchomosci.pl", @"nom.pl", @"org.pl", @"pc.pl", @"powiat.pl", @"priv.pl", @"realestate.pl", @"rel.pl", @"sex.pl", @"shop.pl", @"sklep.pl", @"sos.pl", @"szkola.pl", @"targi.pl", @"tm.pl", @"tourism.pl", @"travel.pl", @"turystyka.pl", @"com.pk", @"net.pk", @"edu.pk", @"org.pk", @"fam.pk", @"biz.pk", @"web.pk", @"gov.pk", @"gob.pk", @"gok.pk", @"gon.pk", @"gop.pk", @"gos.pk", @"edu.ps", @"gov.ps", @"plo.ps", @"sec.ps", @"com.pt", @"edu.pt", @"gov.pt", @"int.pt", @"net.pt", @"nome.pt", @"org.pt", @"publ.pt", @"com.py", @"net.py", @"org.py", @"edu.py", @"com.qa", @"net.qa", @"org.qa", @"edu.qa", @"gov.qa", @"asso.re", @"com.re", @"nom.re", @"com.ro", @"org.ro", @"tm.ro", @"nt.ro", @"nom.ro", @"info.ro", @"rec.ro", @"arts.ro", @"firm.ro", @"store.ro", @"www.ro", @"com.ru", @"net.ru", @"org.ru", @"gov.ru", @"pp.ru", @"com.sa", @"edu.sa", @"sch.sa", @"med.sa", @"gov.sa", @"net.sa", @"org.sa", @"pub.sa", @"com.sb", @"net.sb", @"org.sb", @"edu.sb", @"gov.sb", @"com.sd", @"net.sd", @"org.sd", @"edu.sd", @"sch.sd", @"med.sd", @"gov.sd", @"tm.se", @"press.se", @"parti.se", @"brand.se", @"fh.se", @"fhsk.se", @"fhv.se", @"komforb.se", @"kommunalforbund.se", @"komvux.se", @"lanarb.se", @"lanbib.se", @"naturbruksgymn.se", @"sshn.se", @"org.se", @"pp.se", @"com.sg", @"net.sg", @"org.sg", @"edu.sg", @"gov.sg", @"per.sg", @"com.sh", @"net.sh", @"org.sh", @"edu.sh", @"gov.sh", @"mil.sh", @"gov.st", @"saotome.st", @"principe.st", @"consulado.st", @"embaixada.st", @"org.st", @"edu.st", @"net.st", @"com.st", @"store.st", @"mil.st", @"co.st", @"com.sv", @"org.sv", @"edu.sv", @"gob.sv", @"red.sv", @"com.sy", @"net.sy", @"org.sy", @"gov.sy", @"ac.th", @"co.th", @"go.th", @"net.th", @"or.th", @"com.tn", @"net.tn", @"org.tn", @"edunet.tn", @"gov.tn", @"ens.tn", @"fin.tn", @"nat.tn", @"ind.tn", @"info.tn", @"intl.tn", @"rnrt.tn", @"rnu.tn", @"rns.tn", @"tourism.tn", @"com.tr", @"net.tr", @"org.tr", @"edu.tr", @"gov.tr", @"mil.tr", @"bbs.tr", @"k12.tr", @"gen.tr", @"co.tt", @"com.tt", @"org.tt", @"net.tt", @"biz.tt", @"info.tt", @"pro.tt", @"int.tt", @"coop.tt", @"jobs.tt", @"mobi.tt", @"travel.tt", @"museum.tt", @"aero.tt", @"name.tt", @"gov.tt", @"edu.tt", @"nic.tt", @"us.tt", @"uk.tt", @"ca.tt", @"eu.tt", @"es.tt", @"fr.tt", @"it.tt", @"se.tt", @"dk.tt", @"be.tt", @"de.tt", @"at.tt", @"au.tt", @"co.tv", @"com.tw", @"net.tw", @"org.tw", @"edu.tw", @"idv.tw", @"gov.tw", @"com.ua", @"net.ua", @"org.ua", @"edu.ua", @"gov.ua", @"ac.ug", @"co.ug", @"or.ug", @"go.ug", @"co.uk", @"me.uk", @"org.uk", @"edu.uk", @"ltd.uk", @"plc.uk", @"net.uk", @"sch.uk", @"nic.uk", @"ac.uk", @"gov.uk", @"nhs.uk", @"police.uk", @"mod.uk", @"dni.us", @"fed.us", @"com.uy", @"edu.uy", @"net.uy", @"org.uy", @"gub.uy", @"mil.uy", @"com.ve", @"net.ve", @"org.ve", @"co.ve", @"edu.ve", @"gov.ve", @"mil.ve", @"arts.ve", @"bib.ve", @"firm.ve", @"info.ve", @"int.ve", @"nom.ve", @"rec.ve", @"store.ve", @"tec.ve", @"web.ve", @"co.vi", @"net.vi", @"org.vi", @"com.vn", @"biz.vn", @"edu.vn", @"gov.vn", @"net.vn", @"org.vn", @"int.vn", @"ac.vn", @"pro.vn", @"info.vn", @"health.vn", @"name.vn", @"com.vu", @"edu.vu", @"net.vu", @"org.vu", @"de.vu", @"ch.vu", @"fr.vu", @"com.ws", @"net.ws", @"org.ws", @"gov.ws", @"edu.ws", @"ac.yu", @"co.yu", @"edu.yu", @"org.yu", @"com.ye", @"net.ye", @"org.ye", @"gov.ye", @"edu.ye", @"mil.ye", @"ac.za", @"alt.za", @"bourse.za", @"city.za", @"co.za", @"edu.za", @"gov.za", @"law.za", @"mil.za", @"net.za", @"ngo.za", @"nom.za", @"org.za", @"school.za", @"tm.za", @"web.za", @"co.zw", @"ac.zw", @"org.zw", @"gov.zw", @"eu.org", @"au.com", @"br.com", @"cn.com", @"de.com", @"de.net", @"eu.com", @"gb.com", @"gb.net", @"hu.com", @"no.com", @"qc.com", @"ru.com", @"sa.com", @"se.com", @"uk.com", @"uk.net", @"us.com", @"uy.com", @"za.com", @"dk.org", @"tel.no", @"fax.nr", @"mob.nr", @"mobil.nr", @"mobile.nr", @"tel.nr", @"tlf.nr", @"e164.arpa"];
  }
}

#pragma mark Public

+ (PasswordGenerator *)sharedGenerator {
  static PasswordGenerator *instance;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    instance = [[PasswordGenerator alloc] init];
  });
  
  return instance;
}

+ (NSData *)md5:(NSString *)str {
  const char *cStr = [str UTF8String];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5(cStr, strlen(cStr), digest);
  
  return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

+ (NSData *)sha256:(NSString *)str {
  const char *cStr = [str UTF8String];
  unsigned char digest[CC_SHA256_DIGEST_LENGTH];
  
  CC_SHA256(cStr, strlen(cStr), digest);
  
  return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

- (id)init {
  if ((self = [super init]) != nil) {
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"Installed"]) {
      [Keychain removeStringForKey:@"Hash"];
      [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"Installed"];
    }
    else {
      self.hash = [NSData dataFromBase64String:[Keychain stringForKey:@"Hash"]];
    }
    
    self.lowerCasePattern = [NSRegularExpression regularExpressionWithPattern:@"[a-z]" options:0 error:nil];
    self.upperCasePattern = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]" options:0 error:nil];
    self.digitPattern = [NSRegularExpression regularExpressionWithPattern:@"[\\d]" options:0 error:nil];
    self.domainPattern = [NSRegularExpression regularExpressionWithPattern:@".+[.].+" options:0 error:nil];
  }
  
  return self;
}

- (NSString *)passwordForURL:(NSString *)url length:(int)length {
  if (url == nil) {
    return nil;
  }
  
  NSString *domain = [self domainFromURL:url];
  
  if (domain == nil) {
    return nil;
  }
  
  NSString *password = [NSString stringWithFormat:@"%@:%@", self.masterPassword, domain];
  int count = 0;
  
  while (count < 10 || ![self isValidPassword:[password substringToIndex:length]]) {
    NSData *md5 = [PasswordGenerator md5:password];
    password = [md5 base64EncodedString];
    password = [password stringByReplacingOccurrencesOfString:@"=" withString:@"A"];
    password = [password stringByReplacingOccurrencesOfString:@"+" withString:@"9"];
    password = [password stringByReplacingOccurrencesOfString:@"/" withString:@"8"];
    count += 1;
  }
  
  return [password substringToIndex:length];
}

- (NSString *)domainFromURL:(NSString *)urlStr {
  if (urlStr == nil) {
    return nil;
  }
  
  if ([self.domainPattern numberOfMatchesInString:urlStr options:0 range:NSMakeRange(0, urlStr.length)] == 0) {
    return nil;
  }

  if ([urlStr rangeOfString:@"://"].location == NSNotFound) {
    urlStr = [@"//" stringByAppendingString:urlStr];
  }

  NSString *domain = nil;
  NSURL *url = [NSURL URLWithString:urlStr];
  NSString *host = [url.host lowercaseString];

  if ([urlStr hasPrefix:@"//"]) {
    domain = host;
  }
  else {
    NSArray *parts = [host componentsSeparatedByString:@"."];

    if (parts.count >= 2) {
      domain = [[parts subarrayWithRange:NSMakeRange((parts.count - 2), 2)] componentsJoinedByString:@"."];
      
      if ([TLDs containsObject:domain]) {
        if (parts.count >= 3) {
          domain = [[parts subarrayWithRange:NSMakeRange((parts.count - 3), 3)] componentsJoinedByString:@"."];
        }
        else {
          domain = nil;
        }
      }
    }
  }
  
  return domain;
}

- (BOOL)hasPassword {
  return self.masterPassword != nil;
}

- (BOOL)storesHash {
  return [Keychain stringForKey:@"Hash"] != nil;
}

- (void)updatePassword:(NSString *)password {
  self.masterPassword = password;
  self.hash = [PasswordGenerator sha256:password];
}

#pragma mark Private

- (BOOL)isValidPassword:(NSString *)password {
  NSRange range = NSMakeRange(0, password.length);
  
  return [self.lowerCasePattern rangeOfFirstMatchInString:password options:0 range:range].location == 0 &&
         [self.upperCasePattern numberOfMatchesInString:password options:0 range:range] != 0 &&
         [self.digitPattern numberOfMatchesInString:password options:0 range:range] != 0;
}

@end
