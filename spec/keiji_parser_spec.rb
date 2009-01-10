$KCODE="UTF8"
require 'spec'
require 'hpricot'
require 'lib/keiji_parser'
require 'nkf'

describe "KeijiParser" do
  before(:each) do
    html = <<-EOF
      <table border="2" cellpadding="3" cellspacing="0" width="90%">
      <tbody>
      <tr>
        <td bgcolor="#99bbff">
          <table cellpadding="0" cellspacing="0" width="100%">
            <tbody>
              <tr>
                <td><input name="del" value="5960" type="checkbox">5960．<b><font color="#000000">にっぽん丸クリスマスのショウ</font></b></td>
                <td align="right">
                  <a href="/cgi/reply?id=fujiwara&amp;dd=33&amp;re=5960">返信</a> &nbsp;
                  <a href="/cgi/reply?id=fujiwara&amp;dd=33&amp;re=5960&amp;qu=1">引用</a>&nbsp;
                </td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
      <tr>
        <td bgcolor="#ccddff">名前：<b><font color="#000000">hiroshi</font></b> &nbsp;&nbsp; 日付：1月4日(日) 6時37分</td>
      </tr>
      <tr>
        <td bgcolor="#ffffff">
        <table cellpadding="12" width="100%">
        <tbody>
          <tr>
            <td>
              <a href="/33/fujiwara/img/1230984583_1.jpg" target="_blank">
              <img src="/33/fujiwara/img/1230984583_1s.jpg" border="1" height="179" alt="Original Size: 610 x 457, 114KB" width="240" /></a>
              <wbr> 
                <a href="/33/fujiwara/img/1230984583_2.jpg" target="_blank">
                  <img src="/33/fujiwara/img/1230984583_2s.jpg" border="1" height="179" alt="Original Size: 610 x 457, 114KB" width="240" />
                </a>
              </wbr>
              <p>
                <font color="#008080">藤原さん、桑原さん、<br /><br />ご指摘どおり、同じ出演者ですね。藤原さんのお写真を拝見すると。<br />しかし、今シーズン最後のクリスマス・クルーズ、にっぽん丸の神戸発ワンナイトでは、概して、乗客の評判は良かったですよ。<br />少々乗客に媚びすぎなのが、個人的には鼻につきましたけれども。<br /><br />同じく個人的な意見ですが、同じ出演者が別の船で似たステージを翌年にまた行おうが、時折外国船でもある、アンコール・ショーと銘打ったステージが乗船中に二夜行われようと、要は、乗客を楽しませてくれるならば、それで及第点なのではないでしょうか。<br />　</font>
                <a href="http://ya170519su.at.webry.info/%20" target="_blank">http://ya170519su.at.webry.info/ </a>
              </p>
              <table cellpadding="3" cellspacing="0" width="100%">
              <tbody>
                <tr>
                  <td rowspan="3" width="32"><br /></td>
                  <td><input name="del" value="5961" type="checkbox">5961．<b><font color="#000000">Re: (untitled)</font></b></td>
                </tr>
                <tr>
                  <td>名前：<b><font color="#000000">hiroshi</font></b> &nbsp;&nbsp; 日付：1月3日(土) 21時11分</td>
                </tr>
                <tr>
                  <td>
                  <font color="#000000">すみません。<br />間違って、別スレを立ててしまいました。<br /><br />ＰＶさんの続きです。</font>
                  </td>
                </tr>
                </tbody>
              </table>
      
              <table cellpadding="3" cellspacing="0" width="100%">
              <tbody>
                <tr>
                  <td rowspan="3" width="32"><br /></td>
                </tr>
              </tbody>
              </table>
            </td>
          </tr>
        </tbody>
        </table>
        </td>
      </tr>  
      </tbody>
      </table>
    EOF
    @page = Page.new(html)
  end
  
  describe Page do
    it "should get all topics" do
      @page.topics.size.should == 1
      @page.topics.first.class.should == Topic
    end
  end
  
  describe Topic do
    before(:each) do
      @topic = @page.topics.first
    end
    it "should have id" do
      @topic.thread_id.should == "5960"
    end
    
    it "should have title" do
      @topic.title.should == "にっぽん丸クリスマスのショウ"
    end
    
    it "should have date" do
      @topic.date.should == "1月4日(日) 6時37分"
    end
    
    it "should have name" do
      @topic.user.should == "hiroshi"
    end

    it "should have context" do
      @topic.context.should == (<<-EOF

              <a href="/33/fujiwara/img/1230984583_1.jpg" target="_blank">
              <img src="/33/fujiwara/img/1230984583_1s.jpg" border="1" height="179" alt="Original Size: 610 x 457, 114KB" width="240" /></a>
              <wbr> 
                <a href="/33/fujiwara/img/1230984583_2.jpg" target="_blank">
                  <img src="/33/fujiwara/img/1230984583_2s.jpg" border="1" height="179" alt="Original Size: 610 x 457, 114KB" width="240" />
                </a>
              </wbr>
              <p>
                <font color="#008080">藤原さん、桑原さん、<br /><br />ご指摘どおり、同じ出演者ですね。藤原さんのお写真を拝見すると。<br />しかし、今シーズン最後のクリスマス・クルーズ、にっぽん丸の神戸発ワンナイトでは、概して、乗客の評判は良かったですよ。<br />少々乗客に媚びすぎなのが、個人的には鼻につきましたけれども。<br /><br />同じく個人的な意見ですが、同じ出演者が別の船で似たステージを翌年にまた行おうが、時折外国船でもある、アンコール・ショーと銘打ったステージが乗船中に二夜行われようと、要は、乗客を楽しませてくれるならば、それで及第点なのではないでしょうか。<br />　</font>
                <a href="http://ya170519su.at.webry.info/%20" target="_blank">http://ya170519su.at.webry.info/ </a>
              </p>
      EOF
      ).rstrip
    end
    
    it "should have photo urls" do
      
    end
    
    it "should have photo thumbnail urls" do
      
    end
    
    it "should have comments" do
      @topic.comments.size.should == 1
    end
  end
  
  describe Comment do
    it "should description" do
      
    end
  end
  # it "should fetch title" do
  #   # @doc.search('table[@width="90%"]').each do |thread|
  #   #   thread.search('input[@name=del]').first.attributes['value'].should == "5665"
  #   # end
  # end
end