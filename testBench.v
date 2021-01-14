module test_pci;
reg rw;
reg ntrdy;
reg frame;
reg irdy;
wire DEVSEL,TRDY;
reg [31:0]ad;
wire [31:0]AD;
reg r;
reg [3:0]cbe;
initial
begin
r <= 1;
frame <= 1;
irdy <= 1;
//write state
#5
r<=0;
frame<=0;
ad<=0;
cbe<=4'b0111;
rw=1;

#10 //data1

ad<=4'b1101; 
cbe<=4'b1111;
irdy<=0;

#10 //data 2
frame <=0;
ad<=4'b1000;
cbe<=4'b1101;

#10 //data 3
frame <=1;
ad<=4'b1010;
cbe<=4'b0101;


#10 
irdy <=1;
ad<=32'hzzzzzzzz;
cbe <= 4'bzzzz;

#10 //turn around

//read operation

#10
r<=0;
ntrdy <=0;
frame<=0;
ad<=0;
cbe<=4'b0110;
rw <=1;


#10 //turn around
ad = 32'hzzzzzzzz;
rw = 0;
cbe=4'b1111;
irdy=0;

#10 
frame <=0;
cbe=4'b1111;

#10 //data 2
irdy = 0;
cbe<=4'b1101;

#10
irdy = 0;
frame <= 1;
cbe<=4'b0101;

#10
irdy <=1;
cbe <= 4'bzzzz;

#10 //turn around
//read operation not normal

#10
r<=0;
ntrdy <=0;
frame<=0;
ad<=0;
cbe<=4'b0110;
rw<=1;


#10 //turn around
ad = 32'hzzzzzzzz;
rw = 0;
cbe=4'b1111;
irdy=0;

#10 //data1
frame <=0;
cbe<=4'b1111;

#10 //data 2
irdy = 1;
cbe<=4'b1101;

#10
irdy = 0;

#10 //data 3

frame <= 1;
cbe<=4'b0101;

#10
irdy <=1;
cbe <= 4'bzzzz;

#10 //turn around

//target_scenario not ready

#10
r<=0;
frame<=0;
ad<=0;
cbe<=4'b0110;
ntrdy <=1;
rw <=1;


#10 //turn around
ad = 32'hzzzzzzzz;
rw = 0;
cbe=4'b1111;
irdy=0;

#10 //data1
frame <=0;
cbe<=4'b1111;

#10 //data 2
irdy <= 0;
cbe<=4'b1111;

#10
irdy = 0;
cbe<=4'b1101;
#10 //data 3

frame <= 1;
cbe<=4'b0101;

#10
irdy <=1;
cbe <= 4'bzzzz;


#10 //turn around

//over flow,taret not ready in write
#10 frame<=0;
ad<=0;
cbe<=4'b0111;
rw=1;

#10 //data1

ad<=4'b1101; 
cbe<=4'b1111;
irdy<=0;

#10 //data 2
frame <=0;
ad<=4'b1000;
cbe<=4'b1101;

#10 //data 3
ad<=4'b1010;
cbe<=4'b1111;

#10 //data4
ad <= 4'b1111;
cbe <= 4'b0101;
#5 if(TRDY)begin
#5;
end
#10 //data 5
frame <=1;
ad<=4'b0101;
#5 
if(!TRDY)begin
#5;
irdy <=1;
ad<=32'hzzzzzzzz;
cbe <= 4'bzzzz;
end

#10 //turn around

//irdy not ready in write
#10
frame<=0;
ad<=1;
cbe<=4'b0111;
rw=1;

#10 //data1
ad<=4'b1101; 
cbe<=4'b1111;
irdy<=0;

#10
irdy = 1;
ad<=32'hzzzzzzzz;
cbe <= 4'bzzzz;

#10 //data 2
frame <=0;
ad<=4'b1000;
cbe<=4'b1111;
irdy <=0;

#10 //data 3
frame <=1;
ad<=4'b1010;
cbe<=4'b1111;


#10 
irdy <=1;
ad<=32'hzzzzzzzz;
cbe <= 4'bzzzz;

#10;
end 

assign AD=(rw==1?ad:32'hzzzzzzzz);
Clock k(clk);
targetll t(clk,r,frame,AD,DEVSEL,cbe,irdy,TRDY,rw,ntrdy);
endmodule

