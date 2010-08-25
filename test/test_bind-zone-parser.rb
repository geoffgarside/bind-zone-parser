require 'helper'

class TestBindZoneParser < Test::Unit::TestCase
  # context "#parse" do
  #   setup do
  #     @bind = BindZoneParser.file('m247.db')
  #   end
  #   should "parse the file" do
  #     assert @bind.parse
  #   end
  # end
  context "#parse_string" do
    setup do
      @bind = BindZoneParser.new
    end
    context "Comments" do
      should "parse comment" do
        assert @bind.parse_string(";$; Updated with Simple DNS Plus record editor 2 Aug 2010 13:57:42\n; Zone database file for m247.com zone\n")
      end
    end
    context "Host Record" do
      should "parse subdomain" do
        assert @bind.parse_string("www    IN  A   192.168.1.68\n")
      end
      should "parse dotted subdomain" do
        assert @bind.parse_string("a.mx   IN  A   192.168.1.69\n")
      end
      should "parse qualified owner" do
        assert @bind.parse_string("www.example.com. IN A  192.168.1.70\n")
      end
      should "parse @ origin owner" do
        assert @bind.parse_string("@      IN  A   192.168.1.71\n")
      end
      should "parse blank owner" do
        assert @bind.parse_string("       IN  A   192.168.1.72\n")
      end
      should "parse with ttl" do
        assert @bind.parse_string("  300  IN  A   192.168.1.73\n")
      end
      should "parse with ending comment" do
        assert @bind.parse_string("       IN  A   192.168.1.74  ; Example record\n")
      end
      should "parse with out IN defined" do
        assert @bind.parse_string("           A   192.168.1.76\n")
      end
    end
    context "Name Server Record" do
      should "parse @ origin owner, subdomain host" do
        assert @bind.parse_string("@      IN  NS  ns1\n")
      end
      should "parse @ origin owner, dotted subdomain host" do
        assert @bind.parse_string("@      IN  NS  a.ns\n")
      end
      should "parse @ origin owner, qualified host" do
        assert @bind.parse_string("@      IN  NS  a.ns.example.com.\n")
      end
      should "parse blank owner, subdomain host" do
        assert @bind.parse_string("       IN  NS  ns1\n")
      end
      should "parse blank owner, dotted subdomain host" do
        assert @bind.parse_string("       IN  NS  a.ns\n")
      end
      should "parse blank owner, qualified host" do
        assert @bind.parse_string("       IN  NS  a.ns.example.com.\n")
      end
      should "parse sub delegation, subdomain host" do
        assert @bind.parse_string("hr     IN  NS  hr-ns1\n")
      end
      should "parse sub delegation, dotted subdomain host" do
        assert @bind.parse_string("hr     IN  NS  a.ns-hr\n")
      end
      should "parse sub delegation, qualified host" do
        assert @bind.parse_string("hr     IN  NS  hr-ns1.example.com\n")
      end
      should "parse qualified delegation" do
        assert @bind.parse_string("another.com. IN  NS  ns1\n")
      end
    end
    context "Mail Exchange Record" do
      should "parse @ origin owner, subdomain host" do
        assert @bind.parse_string("@      IN  MX  10    mx1\n")
      end
      should "parse @ origin owner, dotted subdomain host" do
        assert @bind.parse_string("@      IN  MX  10    a.mx\n")
      end
      should "parse @ origin owner, qualified host" do
        assert @bind.parse_string("@      IN  MX  10    a.mx.example.com.\n")
      end
      should "parse blank owner, subdomain host" do
        assert @bind.parse_string("       IN  MX  10    mx1\n")
      end
      should "parse blank owner, dotted subdomain host" do
        assert @bind.parse_string("       IN  MX  10    a.mx\n")
      end
      should "parse blank owner, qualified host" do
        assert @bind.parse_string("       IN  MX  10    a.mx.example.com.\n")
      end
    end
    context "Text Record" do
      should "parse subdomain owner" do
        assert @bind.parse_string("mail      IN  TXT \"v=spf1 a mx ip4:192.168.1.75 ?all\"\n")
      end
      should "parse dotted subdomain owner" do
        assert @bind.parse_string("a.mx      IN  TXT \"v=spf1 a mx ip4:192.168.1.75 ?all\"\n")
      end
      should "parse qualified owner" do
        assert @bind.parse_string("example.com. IN  TXT \"v=spf1 a mx ip4:192.168.1.75 ?all\"\n")
      end
      should "parse @ origin owner" do
        assert @bind.parse_string("@        IN  TXT \"v=spf1 a mx ip4:192.168.1.75 ?all\"\n")
      end
      should "parse blank owner" do
        assert @bind.parse_string("         IN  TXT \"v=spf1 a mx ip4:192.168.1.75 ?all\"\n")
      end
    end
    context "Pointer Record" do
      should "parse octet owner" do
        assert @bind.parse_string("69                         IN PTR a.mx.example.com.\n")
      end
      should "parse multiple octet owner" do
        assert @bind.parse_string("69.1                       IN PTR a.mx.example.com.\n")
      end
      should "parse qualified in-addr.arpa" do
        assert @bind.parse_string("69.1.168.192.in-addr.arpa. IN PTR a.mx.example.com.\n")
      end
    end
    context "CNAME Record" do
      should "parse subdomain to subdomain" do
        assert @bind.parse_string("webmail  IN  CNAME   mail\n")
      end
      should "parse subdomain to qualified domain" do
        assert @bind.parse_string("webmail  IN  CNAME   mail.example.com.\n")
      end
    end
    context "SRV Record" do
      should "parse subdomain to subdomain" do
        assert @bind.parse_string("_jabber._tcp		IN  SRV	10 10  5269 jabber\n")
      end
      should "parse qualified to subdomain" do
        assert @bind.parse_string("_xmpp-client._tcp.example.com. IN	SRV	10 10  5222 jabber\n")
      end
      should "parse qualified to qualified" do
        assert @bind.parse_string("_xmpp-server._tcp.example.com.	IN	SRV	10 10  5269 jabber.example.com.\n")
      end
    end
    context "SOA Record" do
      should "parse single, @ origin owner, short source, short mbox" do
        assert @bind.parse_string("@  IN  SOA ns1 hostmaster (1282731423 16384 2048 1048576 2560)\n")
      end
      should "parse single, @ origin owner, short source, qualified mbox" do
        assert @bind.parse_string("@  IN  SOA ns1 dns.example.com. (1282731423 16384 2048 1048576 2560)\n")
      end
      should "parse single, @ origin owner, qualified source, qualified mbox" do
        assert @bind.parse_string("@  IN  SOA ns1.dns.com. dns.example.com. (1282731423 16384 2048 1048576 2560)\n")
      end
      should "parse single, qualified origin, source and mbox" do
        assert @bind.parse_string("example.com. IN  SOA ns1.dns.com. dns.example.com. (1282731423 16384 2048 1048576 2560)\n")
      end
      should "parse multiline rdata" do
        multiline = <<-EOF
@	86400	IN SOA	ns1.example.com. hostmaster (
          			 1282731423   ; Serial number
          			 16384        ; Refresh
          			 2048         ; Retry
          			 1048576      ; Expire
          			 2560       ) ; Minimum TTL
EOF
        assert @bind.parse_string(multiline)
      end
    end
  end
end
