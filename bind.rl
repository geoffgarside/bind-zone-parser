%%{
  machine bind_parser;

  sp           = space+;
  newline      = "\n";
  comment      = space* ";" [^\n]* newline;
  endofline    = comment | newline;

  escapes      = ('\\' [^0-9\n]) | ('\\' digit{3});
  quotedstr    = ('"' ([^"\n\\]|escapes)* '"');

  ipv4_octet   = ("25" [0-5] | "2" [01234] [0-9] | [01]? [0-9]{1,2});
  ipv4_address = (ipv4_octet "." ipv4_octet "." ipv4_octet "." ipv4_octet);

  origin       = "@";
  alnumhyphen  = alnum | "-";
  dname        = (alnumhyphen+ ".")* alnumhyphen+;
  fqdname      = dname | dname ".";
  owner        = sp | origin | fqdname;
  dist         = digit+;
  ttl          = digit+;
  priority     = digit+;
  weight       = digit+;
  port         = digit+;
  serial       = digit+;
  refresh      = digit+;
  retry        = digit+;
  expire       = digit+;
  minimum      = digit+;
  target       = "." | fqdname;
  srv_o        = "_" alnumhyphen+ "." ("_tcp" | "_udp") ("." fqdname)?;
  mbox         = fqdname;

  eol_or_sp    = sp | (endofline sp);
  soa_rdata    = "(" sp? serial eol_or_sp refresh eol_or_sp retry eol_or_sp expire eol_or_sp minimum sp? ")";

  host_record  = owner (sp ttl)? (sp "IN")? sp "A"     sp ipv4_address endofline;
  ns_record    = owner (sp ttl)? (sp "IN")? sp "NS"    sp fqdname endofline;
  mx_record    = owner (sp ttl)? (sp "IN")? sp "MX"    sp dist sp fqdname endofline;
  txt_record   = owner (sp ttl)? (sp "IN")? sp "TXT"   sp quotedstr endofline;
  ptr_record   = owner (sp ttl)? (sp "IN")? sp "PTR"   sp fqdname endofline;
  cname_record = owner (sp ttl)? (sp "IN")? sp "CNAME" sp fqdname endofline;
  soa_record   = owner (sp ttl)?  sp "IN"   sp "SOA"   sp fqdname sp mbox sp soa_rdata endofline;
  srv_record   = srv_o (sp ttl)? (sp "IN")? sp "SRV"   sp priority sp weight sp port sp target endofline;

  record       = host_record
               | ns_record
               | mx_record
               | txt_record
               | ptr_record
               | cname_record
               | soa_record
               | srv_record;

  main        := (newline | comment | record)*;
}%%

class Bind
  def initialize(content = nil)
    @content = content && (File.exists?(content) ? File.read(content) : content)
  end
  def parse
    parse_string(@content)
  end
  def parse_string(data = nil)
    data = data.unpack('c*')

    %% write data;
    %% write init;
    %% write exec;

    return true if p == pe && cs == bind_parser_first_final
    raise "cs: #{cs} p: #{p} pe: #{pe} data[p]: #{data[p] ? data[p].chr.inspect : 'nil'}"      
  end
end
