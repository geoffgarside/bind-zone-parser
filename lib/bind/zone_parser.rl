%%{
  machine bind_parser;

  action read_number    { num = (num * 10) + (fc - ?0) }
  action clear_number   { num = 0 }
  action clear_str_p    { str_p = p }

  action store_dist     { record[:dist] = num }
  action store_ttl      { record[:ttl] = num }
  action store_priority { record[:priority] = num }
  action store_weight   { record[:weight] = num }
  action store_port     { record[:port] = num }
  action store_serial   { record[:serial] = num }
  action store_refresh  { record[:refresh] = num }
  action store_retry    { record[:retry] = num }
  action store_expire   { record[:expire] = num }
  action store_minimum  { record[:minimum] = num }

  action store_owner    { record[:owner] = data[str_p..p].pack('c*').strip }
  action store_target   { record[:target] = data[str_p..p].pack('c*').strip }
  action store_mbox     { record[:mbox] = data[str_p..p].pack('c*').strip }
  action store_text     { record[:text] = data[(str_p+1)..(p-2)].pack('c*').strip }
  action store_ipv4     { record[:address] = data[str_p..p].pack('c*').strip }
  action store_name     { record[:domain] = data[str_p..p].pack('c*').strip }

  action a              { record[:type] = :a }
  action ns             { record[:type] = :ns }
  action mx             { record[:type] = :mx }
  action txt            { record[:type] = :txt }
  action ptr            { record[:type] = :ptr }
  action soa            { record[:type] = :soa }
  action srv            { record[:type] = :srv }
  action cname          { record[:type] = :cname }

  action store_opt_ttl  { @ttl = record[:ttl]; record = Hash.new }
  action store_opt_origin { @origin = record[:domain]; record = Hash.new }

  sp           = space+;
  newline      = "\n";
  comment      = space* ";" [^\n]* newline;
  endofline    = comment | newline @{ records << record; record = Hash.new };

  escapes      = ('\\' [^0-9\n]) | ('\\' digit{3});
  quotedstr    = ('"' ([^"\n\\]|escapes)* '"') >clear_str_p %store_text;

  ipv4_octet   = ("25" [0-5] | "2" [01234] [0-9] | [01]? [0-9]{1,2});
  ipv4_address = (ipv4_octet "." ipv4_octet "." ipv4_octet "." ipv4_octet) >clear_str_p %store_ipv4;

  origin       = "@";
  alnumhyphen  = (alnum | "-");
  dname        = (alnumhyphen+ ".")* alnumhyphen+ "."?;
  fqdname      = dname >clear_str_p %store_name;
  owner        = (sp | origin | dname) >clear_str_p %store_owner;
  dist         = (digit @read_number)+ >clear_number %store_dist;
  ttl          = (digit @read_number)+ >clear_number %store_ttl;
  priority     = (digit @read_number)+ >clear_number %store_priority;
  weight       = (digit @read_number)+ >clear_number %store_weight;
  port         = (digit @read_number)+ >clear_number %store_port;
  serial       = (digit @read_number)+ >clear_number %store_serial;
  refresh      = (digit @read_number)+ >clear_number %store_refresh;
  retry        = (digit @read_number)+ >clear_number %store_retry;
  expire       = (digit @read_number)+ >clear_number %store_expire;
  minimum      = (digit @read_number)+ >clear_number %store_minimum;
  target       = ("." | dname) >clear_str_p %store_target;
  srv_o        = ("_" alnumhyphen+ "." ("_tcp" | "_udp") ("." dname)?) >clear_str_p %store_owner;
  mbox         = dname >clear_str_p %store_mbox;

  eol_or_sp    = sp | (endofline sp);
  soa_rdata    = "(" sp? serial eol_or_sp refresh eol_or_sp retry eol_or_sp expire eol_or_sp minimum sp? ")";

  host_record  = owner (sp ttl)? (sp "IN")? sp ("A" @a) sp ipv4_address endofline;
  ns_record    = owner (sp ttl)? (sp "IN")? sp ("NS" @ns) sp fqdname endofline;
  mx_record    = owner (sp ttl)? (sp "IN")? sp ("MX" @mx) sp dist sp fqdname endofline;
  txt_record   = owner (sp ttl)? (sp "IN")? sp ("TXT" @txt) sp quotedstr endofline;
  ptr_record   = owner (sp ttl)? (sp "IN")? sp ("PTR" @ptr) sp fqdname endofline;
  cname_record = owner (sp ttl)? (sp "IN")? sp ("CNAME" @cname) sp fqdname endofline;
  soa_record   = owner (sp ttl)?  sp "IN"   sp ("SOA" @soa) sp fqdname sp mbox sp soa_rdata endofline;
  srv_record   = srv_o (sp ttl)? (sp "IN")? sp ("SRV" @srv) sp priority sp weight sp port sp target endofline;

  record       = host_record
               | ns_record
               | mx_record
               | txt_record
               | ptr_record
               | cname_record
               | soa_record
               | srv_record;

  opt_ttl      = "$TTL" sp ttl %store_opt_ttl;
  opt_origin   = "$ORIGIN" sp fqdname %store_opt_origin;
  option       = (opt_ttl | opt_origin) newline;

  main        := (newline | comment | option | record)*;
}%%

module Bind
  class ZoneParser
    attr_reader :ttl, :origin

    def self.parse(zone)
      new.parse(zone)
    end
    def parse(zone)
      data = zone.unpack('c*')
      records = []
      record = {}

      %% write data;
      %% write init;
      %% write exec;

      return records if p == pe && cs == bind_parser_first_final
      raise "cs: #{cs} p: #{p} pe: #{pe} data[p]: #{data[p] ? data[p].chr.inspect : 'nil'}"
    end
  end
end
