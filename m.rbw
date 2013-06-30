#coding: utf-8
require 'rubygems'
require 'gosu'
class SArray
  def initialize
    @array=[]
        @vacancy=[]
  end
  def <<(element)
     if @vacancy.empty?
           @array<<element
         else
           @array[@vacancy.pop]=element
         end
  end
  def size
    @array.size
  end
  def each
    for i in 0..@array.size-1
      yield @array[i]
        end
  end
  def reject_hit(x,y)
    for i in 0..@array.size-1
          @array[i] and
          if @array[i].detect(x,y)
            @array[i]=nil
                @vacancy<<i
                return true
          end
    end
    return false
  end
  def reject_out
    for i in 0..@array.size-1
          @array[i] and
          if @array[i].y>300
            @array[i]=nil
                @vacancy<<i
          end
    end
  end
end
class Knife
  def initialize(window,x=rand(630))
    @image=Gosu::Image.new(window,"./knife.bmp",true)
    @x=x
        @y=-30

        @half_w=5
        @half_h=15

        @v=0
  end
  def move
    @y+=@v
        @v+=0.2
  end
  def y
    @y
  end
  def detect(x,y)
    if (@x+@half_w-x-25).abs<=18 && @y>=195
          true
        end
  end
  def draw
    @image.draw(@x,@y,2)
  end
end
class Man
  attr_accessor :x,:y
  def initialize(window)
    @ske=Gosu::Image.new(window,"./man.bmp",true)
        @up=Gosu::Image.new(window,"./Up.bmp",true)
        @down=Gosu::Image.new(window,"./Down.bmp",true)
        @x=200-25
        @y=300-82
        @half_w=25
        @half_h=41
        @v=3
  end
  def move(dir)
    case dir
        when 1
          @x>0 and @x-=@v
        when 3
          @x<349 and @x+=@v
        end
  end
  def draw
    @down.draw(@x,@y+55,0,1,1,0x77ffffff,:default)
        @up.draw(@x,@y,0,1,1,0x77ffffff,:default)
        @ske.draw(@x,@y,1)
  end
end
class GW < Gosu::Window
  def initialize
    super(400,300,false)
    self.caption="幽靈躲符咒"
        #@bg=Gosu::Image.new(self,"./Blue hills.jpg",true)

        @man=Man.new(self)
        @knife=SArray.new
        @begin=Time.now
        @time=0.0

        @start=false
        @end=false
        @finalize=false
        @string=""
        @tip=["按下S鍵開始","按下R鍵重玩"]

        @font20=Gosu::Font.new(self,Gosu::default_font_name,20)
        @font40=Gosu::Font.new(self,Gosu::default_font_name,40)

        @high=0.0
        begin
          FileTest.exist?("hs.data") and
          open("hs.data","r+"){|file|
            @high=(file.read).unpack("f")[0]
          }
        end



  end
  def update
    if @start
      unless @end
        if button_down? Gosu::KbLeft
              @man.move(1)
            elsif button_down? Gosu::KbRight
              @man.move(3)
            elsif button_down? Gosu::KbEscape
              exit
            end
            rand(8)==1 and @knife<<Knife.new(self)
                rand(40)==1 and @knife<<Knife.new(self,@man.x+25)
            @knife.each{|k| k and k.move}
            @end=@knife.reject_hit(@man.x,@man.y)
            @knife.reject_out
            @time=Time.now-@begin
          else
            unless @finalize
              if @high.to_i<@time.to_i
                @string="高分紀錄！"
                    File.open("hs.data","w+"){|file|
                      file.print([@time].pack("f"))
                   }
              else
                @string="遊戲結束.."
              end
                end
            button_down? Gosu::KbEscape and exit
            if button_down? Gosu::KbR
              @man=Man.new(self)
              @knife=SArray.new
              @begin=Time.now
              @time=0.0

                  @string=""
                  @end=false
              @finalize=false

                  @high=0.0
              begin
                 FileTest.exist?("hs.data") and
                 open("hs.data","r+"){|file|
                @high=(file.read).unpack("f")[0]
              }
              end
            end
    end
    else
          button_down? Gosu::KbS and @start=true
      button_down? Gosu::KbEscape and exit
        end
  end
  def draw
        #@bg.draw(0,0,0,0.5,0.5)
        @man.draw
        @knife.each{|k| k and k.draw}
        @font20.draw("高分：#{@high}",0,20,4,1,1,0xff8080ff)
        @font20.draw("時間已過：#{@time}",0,0,4,1,1,0xff8080ff)
        @end and @font40.draw(@string,120,130,4,1,1,0xff9bc8ff)
        @start or@font20.draw(@tip[0],145,175,4,1,1,0xff9bc8ff)
        @end and @font20.draw(@tip[1],145,175,4,1,1,0xff9bc8ff)
  end
end
window=GW.new
window.show