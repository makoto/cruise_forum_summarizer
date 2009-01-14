$KCODE="UTF8"

require 'spec'
require 'hpricot'
require 'lib/keiji_parser'
require 'nkf'

describe "KeijiParser" do
  before(:each) do
    
    Time.stub!(:now).and_return(Time.parse('2009/1/10'))
    
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
    @topic = @page.topics.first
    @comment = @topic.comments.first
  end
  
  describe Page do
    it "should get all topics" do
      @page.topics.size.should == 1
      @page.topics.first.class.should == Topic
    end
  end
  
  describe Topic do
    before(:each) do
    end
    it "should have id" do
      @topic.thread_id.should == "5960"
    end
    
    it "should have title" do
      @topic.title.should == "にっぽん丸クリスマスのショウ"
    end
    
    it "should have url" do
      @topic.url.should == "/cgi/reply?id=fujiwara&dd=33&re=5960"
    end
    
    it "should have date" do
      JPDate.generate(@topic.date).should == "2009年01月04日(日) 06時37分"
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
      @topic.photos.size.should == 2
      @topic.photos.first.url == "/33/fujiwara/img/1230984583_1.jpg"
    end
    
    it "should have photo thumbnail urls" do
      @topic.photos.first.thumbnail_url == "/33/fujiwara/img/1230984583_1s.jpg"
    end

    it "should fetch photos" do
      @topic.photos.first.fetch
      Dir.glob(OUTDIR + "/1230984583_1.jpg").should == [OUTDIR + "/1230984583_1.jpg"]
    end
    it "should have comments" do
      @topic.comments.size.should == 1
    end
  end

  describe Comment do
    it "should have thread id" do
      @comment.thread_id.should == "5961"
    end
    
    it "should have thread title" do
      @comment.title.should == "Re: (untitled)"
    end
    
    it "should have thread user" do
      @comment.user.should == "hiroshi"
    end

    it "should have thread date" do
      JPDate.generate(@comment.date).should == "2009年01月03日(土) 21時11分"
    end
    
    it "should have thread context" do
      @comment.context.should == '<font color="#000000">すみません。<br />間違って、別スレを立ててしまいました。<br /><br />ＰＶさんの続きです。</font>'
    end
  end
  
  describe JPDate do
    before(:each) do
    end
    
    describe "parse" do
      it "should handle 2 digits min and hour" do
        JPDate.parse("12月27日(土) 10時31分").to_s.should == "Sat Dec 27 10:31:00 +0000 2008"
      end
      it "should handle 1 digit min and hour" do
        JPDate.parse("12月27日(土) 1時3分").to_s.should == "Sat Dec 27 01:03:00 +0000 2008"
      end

      it "should handle this year" do
        Time.stub!(:now).and_return(Time.parse('2009/1/10'))
        JPDate.parse("1月2日(土) 1時3分").to_s.should == "Fri Jan 02 01:03:00 +0000 2009"
      end
    end
    
    describe "generate" do
      it "should generate dates in Japanese" do
        JPDate.generate(Time.parse('2009/1/10 13:03')).should == "2009年01月10日(土) 13時03分"
      end
    end
  end
  
  describe "Summary" do
    before(:each) do
      @summary = Summary.new(:date => Date.new(2009,1,10))
    end

    it "should display summary page name" do
      @summary.this_month.should == "200901"
    end

    it "should display previous month page name" do
      @summary.last_month.should == "200812"
    end

    it "should display next month if privious month" do
      Date.stub!(:today).and_return(Date.new(2009, 2, 18))
      @summary.next_month.should == "200902"
    end

    it "should not display next month if current month" do
      Date.stub!(:today).and_return(Date.new(2009, 1, 18))
      @summary.next_month.should be_nil
    end
    
  end
  
    
    
    describe "Coverage" do
      before(:each) do
        # Time.stub!(:now).and_return(Time.parse('2009/11/10')
        # @this_month_comment = mock Comment
        # @last_month_comment = mock Comment
        # @this_month_comment.stub!(:date).and_return(Time.now)
        # @last_month_comment.stub!(:date).and_return('2009/10/10')
        # 
        # @this_month_topic = mock Topic
        # @mixed_month_topic = mock Topic
        # @last_month_topic = mock Topic
        # 
        # @this_month_topic.stub!(:comment).and_return([@this_month_comment, @this_month_comment])
        # @mixed_month_topic.stub!(:comment).and_return([@last_month_comment, @this_month_comment])
        # @last_month_topic.stub!(:comment).and_return([@last_month_comment, @last_month_comment])
      end
      
      it "should cover only this month" do
        @page_one = mock Page
        @page_two = mock Page
        @page_three = mock Page
        @page_four = mock Page
        
        @page_one.stub!(:topic).and_return([@this_month_topic, @this_month_topic, @this_month_topic])
        @page_two.stub!(:topic).and_return([@this_month_topic, @mixed_month_topic, @last_month_topic])
        @page_three.stub!(:topic).and_return([@last_month_topic, @last_month_topic, @last_month_topic])
        @page_four.stub!(:topic).and_return([@last_month_topic, @last_month_topic, @last_month_topic])
        
      end
    end
    
    describe "Header" do
      it "should not have previous page link if this is first page" do
        
      end
      
      it "should not have next page link if this is last page" do
        
      end
      
      it "should have next and previous page if it's not first nor last" do
        
      end
    end
    
  
end